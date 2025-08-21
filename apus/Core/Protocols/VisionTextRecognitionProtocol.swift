//
//  VisionTextRecognitionProtocol.swift
//  apus
//
//  Created by Rovo Dev on 3/8/2025.
//

import Foundation
import UIKit
import Vision

/// Represents detected text with bounding box and confidence
struct DetectedText: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let boundingBox: CGRect // Normalized coordinates (0-1) with top-left origin
    let confidence: Float
    let characterBoxes: [CGRect] // Individual character bounding boxes

    static func == (lhs: DetectedText, rhs: DetectedText) -> Bool {
        lhs.id == rhs.id
    }

    /// Convert bounding box to display coordinates (same logic as DetectedObject)
    func displayBoundingBox(imageSize: CGSize, displaySize: CGSize) -> CGRect {
        // Calculate how the image is actually displayed within the view bounds
        let imageAspectRatio = imageSize.width / imageSize.height
        let displayAspectRatio = displaySize.width / displaySize.height

        var imageDisplaySize: CGSize
        var imageOffset: CGPoint

        if imageAspectRatio > displayAspectRatio {
            // Image is wider - fit to width
            imageDisplaySize = CGSize(
                width: displaySize.width,
                height: displaySize.width / imageAspectRatio
            )
            imageOffset = CGPoint(
                x: 0,
                y: (displaySize.height - imageDisplaySize.height) / 2
            )
        } else {
            // Image is taller - fit to height
            imageDisplaySize = CGSize(
                width: displaySize.height * imageAspectRatio,
                height: displaySize.height
            )
            imageOffset = CGPoint(
                x: (displaySize.width - imageDisplaySize.width) / 2,
                y: 0
            )
        }

        // Scale normalized coordinates to display coordinates
        return CGRect(
            x: boundingBox.minX * imageDisplaySize.width + imageOffset.x,
            y: boundingBox.minY * imageDisplaySize.height + imageOffset.y,
            width: boundingBox.width * imageDisplaySize.width,
            height: boundingBox.height * imageDisplaySize.height
        )
    }
}

/// Protocol for text recognition using Apple Vision framework
protocol VisionTextRecognitionProtocol: ObservableObject {
    /// Detects text in the provided image
    /// - Parameters:
    ///   - image: The image to analyze
    ///   - completion: Completion handler with detected text or error
    func detectText(in image: UIImage, completion: @escaping (Result<[DetectedText], Error>) -> Void)
}

// MARK: - Mock Implementation for Testing/Simulator

class MockVisionTextRecognitionManager: VisionTextRecognitionProtocol {

    func detectText(in image: UIImage, completion: @escaping (Result<[DetectedText], Error>) -> Void) {
        // Simulate processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let mockTexts = self.generateMockTextDetections(for: image)
            completion(.success(mockTexts))
        }
    }

    private func generateMockTextDetections(for image: UIImage) -> [DetectedText] {
        let imageSize = image.size
        let aspectRatio = imageSize.width / imageSize.height

        // Generate different mock text scenarios based on image characteristics
        if aspectRatio > 1.5 {
            // Landscape - document/receipt scenario
            return createDocumentScenario()
        } else if aspectRatio < 0.7 {
            // Portrait - phone screen/book scenario
            return createPhoneScreenScenario()
        } else {
            // Square-ish - sign/poster scenario
            return createSignScenario()
        }
    }

    private func createDocumentScenario() -> [DetectedText] {
        return [
            DetectedText(
                text: "RECEIPT",
                boundingBox: CGRect(x: 0.3, y: 0.1, width: 0.4, height: 0.08),
                confidence: 0.95,
                characterBoxes: []
            ),
            DetectedText(
                text: "Coffee Shop",
                boundingBox: CGRect(x: 0.25, y: 0.2, width: 0.5, height: 0.06),
                confidence: 0.92,
                characterBoxes: []
            ),
            DetectedText(
                text: "Latte - $4.50",
                boundingBox: CGRect(x: 0.1, y: 0.35, width: 0.6, height: 0.05),
                confidence: 0.88,
                characterBoxes: []
            ),
            DetectedText(
                text: "Croissant - $3.25",
                boundingBox: CGRect(x: 0.1, y: 0.42, width: 0.7, height: 0.05),
                confidence: 0.91,
                characterBoxes: []
            ),
            DetectedText(
                text: "Total: $7.75",
                boundingBox: CGRect(x: 0.1, y: 0.55, width: 0.5, height: 0.06),
                confidence: 0.94,
                characterBoxes: []
            ),
            DetectedText(
                text: "Thank you!",
                boundingBox: CGRect(x: 0.2, y: 0.7, width: 0.6, height: 0.05),
                confidence: 0.87,
                characterBoxes: []
            )
        ]
    }

    private func createPhoneScreenScenario() -> [DetectedText] {
        return [
            DetectedText(
                text: "Messages",
                boundingBox: CGRect(x: 0.1, y: 0.08, width: 0.8, height: 0.06),
                confidence: 0.96,
                characterBoxes: []
            ),
            DetectedText(
                text: "John Doe",
                boundingBox: CGRect(x: 0.15, y: 0.2, width: 0.4, height: 0.04),
                confidence: 0.93,
                characterBoxes: []
            ),
            DetectedText(
                text: "Hey, are we still meeting at 3pm?",
                boundingBox: CGRect(x: 0.1, y: 0.28, width: 0.8, height: 0.08),
                confidence: 0.89,
                characterBoxes: []
            ),
            DetectedText(
                text: "Yes, see you at the coffee shop",
                boundingBox: CGRect(x: 0.1, y: 0.4, width: 0.75, height: 0.08),
                confidence: 0.91,
                characterBoxes: []
            ),
            DetectedText(
                text: "Perfect! 👍",
                boundingBox: CGRect(x: 0.1, y: 0.52, width: 0.3, height: 0.06),
                confidence: 0.85,
                characterBoxes: []
            )
        ]
    }

    private func createSignScenario() -> [DetectedText] {
        return [
            DetectedText(
                text: "STOP",
                boundingBox: CGRect(x: 0.25, y: 0.3, width: 0.5, height: 0.15),
                confidence: 0.98,
                characterBoxes: []
            ),
            DetectedText(
                text: "Main Street",
                boundingBox: CGRect(x: 0.15, y: 0.55, width: 0.7, height: 0.08),
                confidence: 0.92,
                characterBoxes: []
            ),
            DetectedText(
                text: "Speed Limit 25",
                boundingBox: CGRect(x: 0.1, y: 0.7, width: 0.8, height: 0.06),
                confidence: 0.88,
                characterBoxes: []
            )
        ]
    }
}

// MARK: - Type Aliases for Conditional Compilation

// Use real Vision framework implementation (works on both device and simulator)
typealias VisionTextRecognitionProvider = VisionTextRecognitionManager
