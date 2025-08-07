//
//  ImageClassificationProtocol.swift
//  apus
//
//  Created by Rovo Dev on 28/7/2025.
//

import Foundation
import UIKit

struct ClassificationResult {
    let identifier: String
    let confidence: Float
}

protocol ImageClassificationProtocol: ObservableObject {
    var isClassifying: Bool { get }
    var lastClassificationResults: [ClassificationResult] { get }

    func classifyImage(_ image: UIImage, completion: @escaping (Result<[ClassificationResult], Error>) -> Void)
}

#if DEBUG || targetEnvironment(simulator)
// Mock implementation for simulator and debug builds
class MockImageClassificationManager: ImageClassificationProtocol {
    @Published var isClassifying = false
    @Published var lastClassificationResults: [ClassificationResult] = []

    func classifyImage(_ image: UIImage, completion: @escaping (Result<[ClassificationResult], Error>) -> Void) {
        isClassifying = true

        // Simulate processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isClassifying = false

            // Generate varied mock results based on image characteristics
            let mockResults = self.generateMockResults(for: image)

            self.lastClassificationResults = mockResults
            completion(.success(mockResults))
        }
    }

    private func generateMockResults(for image: UIImage) -> [ClassificationResult] {
        // Create a simple hash based on image properties to ensure different results
        let imageHash = self.simpleImageHash(image)

        // Define different result sets
        let resultSets: [[ClassificationResult]] = [
            [
                ClassificationResult(identifier: "dog", confidence: 0.85),
                ClassificationResult(identifier: "animal", confidence: 0.72),
                ClassificationResult(identifier: "pet", confidence: 0.68)
            ],
            [
                ClassificationResult(identifier: "cat", confidence: 0.91),
                ClassificationResult(identifier: "feline", confidence: 0.78),
                ClassificationResult(identifier: "domestic animal", confidence: 0.65)
            ],
            [
                ClassificationResult(identifier: "car", confidence: 0.88),
                ClassificationResult(identifier: "vehicle", confidence: 0.75),
                ClassificationResult(identifier: "automobile", confidence: 0.62)
            ],
            [
                ClassificationResult(identifier: "tree", confidence: 0.82),
                ClassificationResult(identifier: "plant", confidence: 0.69),
                ClassificationResult(identifier: "nature", confidence: 0.58)
            ],
            [
                ClassificationResult(identifier: "building", confidence: 0.79),
                ClassificationResult(identifier: "architecture", confidence: 0.66),
                ClassificationResult(identifier: "structure", confidence: 0.54)
            ],
            [
                ClassificationResult(identifier: "person", confidence: 0.93),
                ClassificationResult(identifier: "human", confidence: 0.81),
                ClassificationResult(identifier: "individual", confidence: 0.67)
            ],
            [
                ClassificationResult(identifier: "food", confidence: 0.86),
                ClassificationResult(identifier: "meal", confidence: 0.73),
                ClassificationResult(identifier: "cuisine", confidence: 0.61)
            ],
            [
                ClassificationResult(identifier: "flower", confidence: 0.89),
                ClassificationResult(identifier: "bloom", confidence: 0.76),
                ClassificationResult(identifier: "botanical", confidence: 0.63)
            ]
        ]

        // Select result set based on image hash
        let selectedIndex = imageHash % resultSets.count
        var selectedResults = resultSets[selectedIndex]

        // Add some randomness to confidence scores
        selectedResults = selectedResults.map { result in
            let variation = Float.random(in: -0.1...0.1)
            let newConfidence = max(0.1, min(0.99, result.confidence + variation))
            return ClassificationResult(identifier: result.identifier, confidence: newConfidence)
        }

        return selectedResults
    }

    private func simpleImageHash(_ image: UIImage) -> Int {
        // Create a simple hash based on image properties
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let scale = Int(image.scale * 100)
        let orientation = image.imageOrientation.rawValue

        // Simple hash combination
        return (width * 31 + height * 17 + scale * 7 + orientation * 3) % 1000
    }
}

typealias ImageClassificationProvider = MockImageClassificationManager
#else
// Use real Vision framework implementation for device builds
typealias ImageClassificationProvider = ImageClassificationManager
#endif
