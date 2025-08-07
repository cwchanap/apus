#if !DEBUG && !targetEnvironment(simulator)
import Foundation
import TensorFlowLite
import CoreVideo
import UIKit
import QuartzCore

class ObjectDetectionManager: ObservableObject, ObjectDetectionProtocol {
    private var interpreter: Interpreter?
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
            self.setupInterpreter()
            self.loadLabels()

            DispatchQueue.main.async {
                self.isModelLoading = false
                completion(self.isInitialized)
            }
        }
    }

    private func setupInterpreter() {
        guard let modelPath = Bundle.main.path(forResource: "efficientdet_lite0", ofType: "tflite") else {
            print("Failed to find model file")
            return
        }

        do {
            var options = Interpreter.Options()
            options.threadCount = 2

            // Enable GPU acceleration if available
            #if !targetEnvironment(simulator)
            if let gpuDelegate = MetalDelegate() {
                options.delegates = [gpuDelegate]
            }
            #endif

            interpreter = try Interpreter(modelPath: modelPath, options: options)
            try interpreter?.allocateTensors()

            isInitialized = true
            print("TensorFlow Lite model loaded successfully")
        } catch {
            print("Failed to create interpreter: \(error.localizedDescription)")
        }
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
            guard let self = self, success, let interpreter = self.interpreter else {
                self?.isProcessing = false
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let inputData = try self.preprocessImage(pixelBuffer: pixelBuffer)
                    try interpreter.copy(inputData, toInputAt: 0)
                    try interpreter.invoke()

                    let outputTensor = try interpreter.output(at: 0)
                    let results = try self.parseResults(outputTensor: outputTensor)

                    DispatchQueue.main.async {
                        self.detections = results
                        self.isProcessing = false
                    }
                } catch {
                    print("Detection error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.isProcessing = false
                    }
                }
            }
        }
    }

    private func preprocessImage(pixelBuffer: CVPixelBuffer) throws -> Data {
        let targetSize = CGSize(width: 320, height: 320)

        guard let resizedPixelBuffer = pixelBuffer.resized(to: targetSize) else {
            throw NSError(domain: "ObjectDetectionManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to resize pixel buffer"])
        }

        CVPixelBufferLockBaseAddress(resizedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        defer { CVPixelBufferUnlockBaseAddress(resizedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0)) }

        let width = CVPixelBufferGetWidth(resizedPixelBuffer)
        let height = CVPixelBufferGetHeight(resizedPixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(resizedPixelBuffer)

        guard let baseAddress = CVPixelBufferGetBaseAddress(resizedPixelBuffer) else {
            throw NSError(domain: "ObjectDetectionManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to get base address"])
        }

        let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)
        var inputData = Data()

        for yCoord in 0..<height {
            for xCoord in 0..<width {
                let offset = yCoord * bytesPerRow + xCoord * 4
                let red = buffer[offset + 2]
                let green = buffer[offset + 1]
                let blue = buffer[offset]

                var normalizedRed = Float(red) / 255.0
                var normalizedGreen = Float(green) / 255.0
                var normalizedBlue = Float(blue) / 255.0

                inputData.append(Data(bytes: &normalizedRed, count: 4))
                inputData.append(Data(bytes: &normalizedGreen, count: 4))
                inputData.append(Data(bytes: &normalizedBlue, count: 4))
            }
        }

        return inputData
    }

    private func parseResults(outputTensor: Tensor) throws -> [Detection] {
        let data = outputTensor.data
        let dataCount = data.count / 4

        var detections: [Detection] = []

        for index in stride(from: 0, to: dataCount, by: 7) {
            _ = data.withUnsafeBytes { $0.load(fromByteOffset: i * 4, as: Float32.self) }
            let classId = data.withUnsafeBytes { $0.load(fromByteOffset: (i + 1) * 4, as: Float32.self) }
            let score = data.withUnsafeBytes { $0.load(fromByteOffset: (i + 2) * 4, as: Float32.self) }
            let xMin = data.withUnsafeBytes { $0.load(fromByteOffset: (i + 3) * 4, as: Float32.self) }
            let yMin = data.withUnsafeBytes { $0.load(fromByteOffset: (i + 4) * 4, as: Float32.self) }
            let xMax = data.withUnsafeBytes { $0.load(fromByteOffset: (i + 5) * 4, as: Float32.self) }
            let yMax = data.withUnsafeBytes { $0.load(fromByteOffset: (i + 6) * 4, as: Float32.self) }

            if score > 0.5 {
                let boundingBox = CGRect(
                    x: CGFloat(xMin),
                    y: CGFloat(yMin),
                    width: CGFloat(xMax - xMin),
                    height: CGFloat(yMax - yMin)
                )

                let className = Int(classId) < labels.count ? labels[Int(classId)] : "Unknown"

                let detection = Detection(
                    boundingBox: boundingBox,
                    className: className,
                    confidence: score
                )

                detections.append(detection)
            }
        }

        return detections
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
#endif
