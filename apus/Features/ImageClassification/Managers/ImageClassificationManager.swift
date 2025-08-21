//
//  ImageClassificationManager.swift
//  apus
//
//  Created by Rovo Dev on 28/7/2025.
//

// Real Vision framework implementation (available in all build configurations)
import Foundation
import Vision
import UIKit
import CoreML

class ImageClassificationManager: ObservableObject, ImageClassificationProtocol {
    @Published var isClassifying = false
    @Published var lastClassificationResults: [ClassificationResult] = []

    init() {
        // No setup needed for VNClassifyImageRequest
    }

    func classifyImage(_ image: UIImage, completion: @escaping (Result<[ClassificationResult], Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(ClassificationError.invalidImage))
            return
        }

        DispatchQueue.main.async {
            self.isClassifying = true
        }

        // Use Vision's built-in image classification request
        let request = VNClassifyImageRequest { [weak self] request, error in
            DispatchQueue.main.async {
                self?.isClassifying = false

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let observations = request.results as? [VNClassificationObservation] else {
                    completion(.failure(ClassificationError.processingFailed))
                    return
                }

                // Get top 5 results with confidence > 0.05 for more variety
                let results = observations
                    .filter { $0.confidence > 0.05 }
                    .prefix(5)
                    .map { ClassificationResult(identifier: $0.identifier, confidence: $0.confidence) }

                let classificationResults = Array(results)
                self?.lastClassificationResults = classificationResults
                completion(.success(classificationResults))
            }
        }

        // Handle image orientation properly for better classification
        let orientation = CGImagePropertyOrientation(from: image.imageOrientation)
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isClassifying = false
                    completion(.failure(error))
                }
            }
        }
    }

}

enum ClassificationError: Error, LocalizedError {
    case modelNotLoaded
    case invalidImage
    case processingFailed

    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "Classification model could not be loaded"
        case .invalidImage:
            return "Invalid image for classification"
        case .processingFailed:
            return "Image classification processing failed"
        }
    }
}

// CGImagePropertyOrientation extension is defined in VisionObjectDetectionManager.swift

