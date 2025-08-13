//
//  MockContourDetectionManager.swift
//  apus
//
//  Created by Rovo Dev on 9/8/2025.
//

import Foundation
import UIKit
import Combine

#if DEBUG || targetEnvironment(simulator)
final class MockContourDetectionManager: ContourDetectionProtocol {
    @Published var isDetecting = false
    @Published var lastDetectedContours: [DetectedContour] = []

    func detectContours(in image: UIImage, completion: @escaping (Result<[DetectedContour], Error>) -> Void) {
        isDetecting = true

        // Simulate processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isDetecting = false

            // Generate varied mock contours based on image characteristics
            let mockContours = self.generateMockContours(for: image)

            self.lastDetectedContours = mockContours
            completion(.success(mockContours))
        }
    }

    private func generateMockContours(for image: UIImage) -> [DetectedContour] {
        // Create a simple hash based on image properties to ensure different results
        let imageHash = self.simpleImageHash(image)

        // Define different contour patterns based on image characteristics
        let contourSets: [[DetectedContour]] = [
            MockContourScenarios.createDocumentContours(),
            MockContourScenarios.createNaturalContours(),
            MockContourScenarios.createGeometricContours(),
            MockContourScenarios.createEdgeHeavyContours(),
            MockContourScenarios.createSimpleContours(),
            MockContourScenarios.createComplexSceneContours()
        ]

        // Select contour set based on image hash
        let selectedIndex = imageHash % contourSets.count
        var selectedContours = contourSets[selectedIndex]

        // Add some randomness to positions and confidence scores
        selectedContours = selectedContours.map { contour in
            let positionVariation = Float.random(in: -0.05...0.05)
            let confidenceVariation = Float.random(in: -0.1...0.1)

            let adjustedPoints = contour.points.map { point in
                CGPoint(
                    x: max(0, min(1, point.x + CGFloat(positionVariation))),
                    y: max(0, min(1, point.y + CGFloat(positionVariation)))
                )
            }

            let adjustedConfidence = max(0.1, min(0.99, contour.confidence + confidenceVariation))

            return DetectedContour(
                points: adjustedPoints,
                boundingBox: contour.boundingBox,
                confidence: adjustedConfidence,
                aspectRatio: contour.aspectRatio,
                area: contour.area
            )
        }

        return selectedContours
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
#endif
