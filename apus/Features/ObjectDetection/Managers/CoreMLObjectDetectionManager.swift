//
//  CoreMLObjectDetectionManager.swift
//  apus
//
//  Created by Agent on 24/8/2025.
//

import Foundation
import UIKit
import Vision

class CoreMLObjectDetectionManager: ObservableObject, UnifiedObjectDetectionProtocol {
    @Published var isDetecting = false
    @Published var lastDetectedObjects: [DetectedObject] = []
    let framework: ObjectDetectionFramework = .coreML

    private var isModelLoaded = false
    private var isModelLoading = false
    private let modelLoadingQueue = DispatchQueue(label: "com.apus.coreml.modelLoading", qos: .userInitiated)

    init() {
        // Don't load model immediately - do it lazily when first needed
    }

    func preload() {
        // Trigger model loading in background without blocking UI
        ensureModelLoaded { _ in }
    }

    private func ensureModelLoaded(completion: @escaping (Bool) -> Void) {
        // If already loaded, return immediately
        if isModelLoaded {
            completion(true)
            return
        }

        // If currently loading, wait for completion
        if isModelLoading {
            modelLoadingQueue.async {
                // Poll in the background and return when done without blocking UI
                while self.isModelLoading {
                    usleep(50_000) // 50ms
                }
                DispatchQueue.main.async {
                    completion(self.isModelLoaded)
                }
            }
            return
        }

        // Start loading
        isModelLoading = true

        modelLoadingQueue.async {
            // For Vision framework, model is always available
            let success = true

            DispatchQueue.main.async {
                self.isModelLoading = false
                self.isModelLoaded = success
                completion(success)
            }
        }
    }

    func detectObjects(in image: UIImage, completion: @escaping (Result<[DetectedObject], Error>) -> Void) {
        DispatchQueue.main.async {
            self.isDetecting = true
        }

        // Ensure model is loaded before proceeding
        ensureModelLoaded { [weak self] success in
            guard let self = self else {
                completion(.failure(CoreMLError.modelNotLoaded))
                return
            }

            guard success else {
                DispatchQueue.main.async {
                    self.isDetecting = false
                }
                completion(.failure(CoreMLError.modelNotLoaded))
                return
            }

            guard let cgImage = image.cgImage else {
                DispatchQueue.main.async {
                    self.isDetecting = false
                }
                completion(.failure(CoreMLError.invalidImage))
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                self.performObjectRecognition(cgImage: cgImage, imageSize: image.size, completion: completion)
            }
        }
    }

    private func performObjectRecognition(cgImage: CGImage, imageSize: CGSize, completion: @escaping (Result<[DetectedObject], Error>) -> Void) {
        // Use Vision's classification request since VNRecognizeObjectsRequest is not available
        // This provides object classification without bounding boxes
        let request = VNClassifyImageRequest { [weak self] request, error in
            DispatchQueue.main.async {
                self?.isDetecting = false

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let observations = request.results as? [VNClassificationObservation] else {
                    completion(.failure(CoreMLError.processingFailed))
                    return
                }

                // Process observations and convert to DetectedObject
                let detections = self?.processClassificationObservations(observations) ?? []
                self?.lastDetectedObjects = detections
                completion(.success(detections))
            }
        }

        // Handle image orientation properly
        let orientation = CGImagePropertyOrientation(from: UIImage(cgImage: cgImage).imageOrientation)
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])

        do {
            try handler.perform([request])
        } catch {
            DispatchQueue.main.async {
                self.isDetecting = false
                completion(.failure(error))
            }
        }
    }

    private func processClassificationObservations(_ observations: [VNClassificationObservation]) -> [DetectedObject] {
        var detections: [DetectedObject] = []

        for observation in observations {
            // Filter by confidence threshold (similar to TensorFlow Lite implementation)
            guard observation.confidence > 0.3 else { continue }

            // Create DetectedObject with full image bounding box since classification doesn't provide location
            // This is a limitation of using VNClassifyImageRequest instead of a custom Core ML model
            let detection = DetectedObject(
                boundingBox: CGRect(x: 0, y: 0, width: 1, height: 1), // Full image
                className: observation.identifier,
                confidence: observation.confidence,
                framework: .coreML
            )

            detections.append(detection)
        }

        // Sort by confidence and return top detections (same as TensorFlow Lite implementation)
        return Array(detections
                        .sorted { $0.confidence > $1.confidence }
                        .prefix(8))
    }
}

enum CoreMLError: Error, LocalizedError {
    case modelNotLoaded
    case invalidImage
    case processingFailed

    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "Core ML model not loaded"
        case .invalidImage:
            return "Invalid image for Core ML object detection"
        case .processingFailed:
            return "Core ML object detection processing failed"
        }
    }
}
