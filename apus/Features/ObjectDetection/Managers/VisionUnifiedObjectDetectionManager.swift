//
//  VisionUnifiedObjectDetectionManager.swift
//  apus
//
//  Created by Rovo Dev on 1/8/2025.
//

// Real Vision framework implementation (available in all build configurations)
import Foundation
import Vision
import UIKit

class VisionUnifiedObjectDetectionManager: ObservableObject, UnifiedObjectDetectionProtocol {
    @Published var isDetecting = false
    @Published var lastDetectedObjects: [DetectedObject] = []
    let framework: ObjectDetectionFramework = .vision

    func detectObjects(in image: UIImage, completion: @escaping (Result<[DetectedObject], Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(ObjectDetectionError.invalidImage))
            return
        }

        DispatchQueue.main.async {
            self.isDetecting = true
        }

        // Use Vision's built-in object recognition request
        let request = VNClassifyImageRequest { [weak self] request, error in
            DispatchQueue.main.async {
                self?.isDetecting = false

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let observations = request.results as? [VNClassificationObservation] else {
                    completion(.failure(ObjectDetectionError.processingFailed))
                    return
                }

                // Process observations and convert to DetectedObject
                let detections = self?.processVisionObservations(observations) ?? []
                self?.lastDetectedObjects = detections
                completion(.success(detections))
            }
        }

        // Configure the request for better results
        // VNClassifyImageRequest doesn't have maximumObservations property

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

    private func processVisionObservations(_ observations: [VNClassificationObservation]) -> [DetectedObject] {
        var detections: [DetectedObject] = []

        for observation in observations {
            // Filter by confidence threshold
            guard observation.confidence > 0.3 else { continue }

            // Create DetectedObject with full image bounding box since classification doesn't provide location
            let detection = DetectedObject(
                boundingBox: CGRect(x: 0, y: 0, width: 1, height: 1), // Full image
                className: observation.identifier,
                confidence: observation.confidence,
                framework: .vision
            )

            detections.append(detection)
        }

        // Sort by confidence and return top detections
        return Array(detections
                        .sorted { $0.confidence > $1.confidence }
                        .prefix(5))
    }
}

enum ObjectDetectionError: Error, LocalizedError {
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

// CGImagePropertyOrientation extension is defined in VisionObjectDetectionManager.swift
