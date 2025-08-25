// Legacy ObjectDetectionManager (deprecated - use UnifiedObjectDetectionProtocol instead)
// Updated to use Core ML instead of TensorFlow Lite for compatibility
import Foundation
import CoreVideo
import UIKit
import QuartzCore
import CoreML
import Vision

class ObjectDetectionManager: ObservableObject, ObjectDetectionProtocol {
    private var model: MLModel?
    private var labels: [String] = []
    private var isProcessing = false
    private var lastProcessingTime: TimeInterval = 0
    private let processingInterval: TimeInterval = 0.1 // Process every 100ms

    @Published var detections: [Detection] = []
    @Published var isInitialized = false

    private var isModelLoading = false
    private let modelLoadingQueue = DispatchQueue(label: "com.apus.objectdetection.modelLoading", qos: .userInitiated)

    init() {
        // Don't load model immediately - do it lazily when first needed
    }

    // Proactively load heavy resources off the main thread
    func preload() {
        modelLoadingQueue.async {
            self.ensureModelLoaded { _ in /* no-op */ }
        }
    }

    private func ensureModelLoaded(completion: @escaping (Bool) -> Void) {
        // If already loaded, return immediately
        if isInitialized {
            completion(true)
            return
        }

        // If currently loading, wait for completion
        if isModelLoading {
            modelLoadingQueue.async {
                // Wait for loading to complete
                while self.isModelLoading {
                    Thread.sleep(forTimeInterval: 0.1)
                }
                DispatchQueue.main.async {
                    completion(self.isInitialized)
                }
            }
            return
        }

        // Start loading
        isModelLoading = true

        modelLoadingQueue.async {
            self.setupModel()
            self.loadLabels()

            // Flip loading flag and notify on a background thread to avoid
            // briefly congesting the main thread right after heavy work.
            self.isModelLoading = false
            completion(self.isInitialized)
        }
    }

    private func setupModel() {
        // For now, use a simple Vision-based object detection as fallback
        // This provides basic functionality while maintaining the same interface
        isInitialized = true
        print("Core ML-based object detection initialized (using Vision framework)")
    }

    private func loadLabels() {
        guard let labelPath = Bundle.main.path(forResource: "coco_labels", ofType: "txt") else {
            print("Failed to find labels file")
            return
        }

        do {
            let content = try String(contentsOfFile: labelPath, encoding: .utf8)
            labels = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
            print("Loaded \(labels.count) labels")
        } catch {
            print("Failed to load labels: \(error.localizedDescription)")
        }
    }

    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        // Throttle processing to avoid overwhelming the system
        let currentTime = CACurrentMediaTime()
        guard !isProcessing && (currentTime - lastProcessingTime) > processingInterval else {
            return
        }

        isProcessing = true
        lastProcessingTime = currentTime

        // Ensure model is loaded before processing
        ensureModelLoaded { [weak self] success in
            guard let self = self, success else {
                self?.isProcessing = false
                return
            }

            // Convert CVPixelBuffer to UIImage for Vision processing
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
                return
            }
            let image = UIImage(cgImage: cgImage)

            DispatchQueue.global(qos: .userInitiated).async {
                self.detectObjectsInImage(image) { results in
                    DispatchQueue.main.async {
                        self.detections = results
                        self.isProcessing = false
                    }
                }
            }
        }
    }

    private func detectObjectsInImage(_ image: UIImage, completion: @escaping ([Detection]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }

        // Use Vision's classification request for basic detection
        let request = VNClassifyImageRequest { request, error in
            if let error = error {
                print("Object detection error: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let observations = request.results as? [VNClassificationObservation] else {
                completion([])
                return
            }

            let detections = observations.compactMap { observation -> Detection? in
                guard observation.confidence > 0.3 else { return nil }

                // Classification provides class name directly
                let className = observation.identifier

                // Classification doesn't provide bounding boxes, so use full image
                let fullImageBox = CGRect(x: 0, y: 0, width: 1, height: 1)

                return Detection(
                    boundingBox: fullImageBox,
                    className: className,
                    confidence: observation.confidence
                )
            }

            completion(detections)
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Vision request error: \(error.localizedDescription)")
            completion([])
        }
    }
}

extension CVPixelBuffer {
    func resized(to targetSize: CGSize) -> CVPixelBuffer? {
        _ = CVPixelBufferGetWidth(self)
        _ = CVPixelBufferGetHeight(self)

        let attributes: [NSString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]

        var resizedPixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(targetSize.width),
            Int(targetSize.height),
            kCVPixelFormatType_32BGRA,
            attributes as CFDictionary,
            &resizedPixelBuffer
        )

        guard status == kCVReturnSuccess, let resizedBuffer = resizedPixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        CVPixelBufferLockBaseAddress(resizedBuffer, CVPixelBufferLockFlags(rawValue: 0))

        defer {
            CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
            CVPixelBufferUnlockBaseAddress(resizedBuffer, CVPixelBufferLockFlags(rawValue: 0))
        }

        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(resizedBuffer),
            width: Int(targetSize.width),
            height: Int(targetSize.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(resizedBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )

        guard let cgContext = context else { return nil }

        let ciImage = CIImage(cvPixelBuffer: self)
        let ciContext = CIContext()

        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }

        cgContext.draw(cgImage, in: CGRect(origin: .zero, size: targetSize))

        return resizedBuffer
    }
}
