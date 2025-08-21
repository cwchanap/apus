//
//  VisionObjectDetectionManager.swift
//  apus
//
//  Created by Rovo Dev on 1/8/2025.
//

// Real Vision framework implementation (available in all build configurations)
import Foundation
import Vision
import UIKit
import CoreML

class VisionObjectDetectionManager: ObservableObject, VisionObjectDetectionProtocol {
    @Published var isDetecting = false
    @Published var lastDetectedObjects: [VisionDetection] = []

    init() {
        // No setup needed for VNRecognizeObjectsRequest
    }

    func detectObjects(in image: UIImage, completion: @escaping (Result<[VisionDetection], Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(VisionObjectDetectionError.invalidImage))
            return
        }

        DispatchQueue.main.async {
            self.isDetecting = true
        }

        // Use Vision's classification request (VNRecognizeObjectsRequest doesn't exist)
        // For now, we'll use a simple approach that works with Vision framework
        let request = VNClassifyImageRequest { [weak self] request, error in
            DispatchQueue.main.async {
                self?.isDetecting = false

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let observations = request.results as? [VNClassificationObservation] else {
                    completion(.failure(VisionObjectDetectionError.processingFailed))
                    return
                }

                // Process observations and convert to VisionDetection objects
                let detections = self?.processClassificationObservations(observations, imageSize: image.size) ?? []
                self?.lastDetectedObjects = detections
                completion(.success(detections))
            }
        }

        // VNClassifyImageRequest doesn't have maximumObservations property
        // It automatically returns top classifications

        // Handle image orientation properly
        let orientation = CGImagePropertyOrientation(from: image.imageOrientation)
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isDetecting = false
                    completion(.failure(error))
                }
            }
        }
    }

    private func processClassificationObservations(_ observations: [VNClassificationObservation], imageSize: CGSize) -> [VisionDetection] {
        var detections: [VisionDetection] = []

        for observation in observations {
            // Filter by confidence threshold
            guard observation.confidence > 0.3 else { continue }

            // Create VisionDetection object with full image bounding box since classification doesn't provide location
            let detection = VisionDetection(
                boundingBox: CGRect(x: 0, y: 0, width: 1, height: 1), // Full image
                className: observation.identifier,
                confidence: observation.confidence
            )

            detections.append(detection)
        }

        // Sort by confidence and return top detections
        return Array(detections
                        .sorted { $0.confidence > $1.confidence }
                        .prefix(5))
    }
}

enum VisionObjectDetectionError: Error, LocalizedError {
    case invalidImage
    case processingFailed
    case noObjectsFound

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image for object detection"
        case .processingFailed:
            return "Object detection processing failed"
        case .noObjectsFound:
            return "No objects found in the image"
        }
    }
}

// MARK: - CGImagePropertyOrientation Extension
extension CGImagePropertyOrientation {
    init(from uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}

