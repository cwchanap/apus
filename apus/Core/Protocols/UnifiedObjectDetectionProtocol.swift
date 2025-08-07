//
//  UnifiedObjectDetectionProtocol.swift
//  apus
//
//  Created by Rovo Dev on 1/8/2025.
//

import Foundation
import UIKit

/// Unified object detection result that works with any framework
struct DetectedObject {
    let id = UUID()
    let boundingBox: CGRect  // Normalized coordinates (0-1) with top-left origin
    let className: String
    let confidence: Float
    let framework: ObjectDetectionFramework

    /// Convert bounding box to display coordinates
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

/// Unified object detection protocol that both Vision and TensorFlow Lite will implement
protocol UnifiedObjectDetectionProtocol: ObservableObject {
    var isDetecting: Bool { get }
    var lastDetectedObjects: [DetectedObject] { get }
    var framework: ObjectDetectionFramework { get }

    func detectObjects(in image: UIImage, completion: @escaping (Result<[DetectedObject], Error>) -> Void)
}

/// Factory for creating object detection managers based on settings
class ObjectDetectionFactory {
    static func createObjectDetectionManager() -> any UnifiedObjectDetectionProtocol {
        // Use default framework to avoid circular dependency with AppSettings
        // The actual framework will be determined when detection is first used
        let defaultFramework = ObjectDetectionFramework.vision

        #if DEBUG || targetEnvironment(simulator)
        // Use mock implementation for simulator/debug
        return MockUnifiedObjectDetectionManager(framework: defaultFramework)
        #else
        // Use default Vision framework to avoid AppSettings dependency during initialization
        // Framework switching will be handled at runtime when needed
        return VisionUnifiedObjectDetectionManager()
        #endif
    }

    /// Create object detection manager with specific framework (for runtime switching)
    static func createObjectDetectionManager(framework: ObjectDetectionFramework) -> any UnifiedObjectDetectionProtocol {
        #if DEBUG || targetEnvironment(simulator)
        return MockUnifiedObjectDetectionManager(framework: framework)
        #else
        switch framework {
        case .vision:
            return VisionUnifiedObjectDetectionManager()
        case .tensorflowLite:
            return TensorFlowLiteObjectDetectionManager()
        }
        #endif
    }
}

// MARK: - Mock Implementation for DEBUG/Simulator
#if DEBUG || targetEnvironment(simulator)
class MockUnifiedObjectDetectionManager: UnifiedObjectDetectionProtocol {
    @Published var isDetecting = false
    @Published var lastDetectedObjects: [DetectedObject] = []
    let framework: ObjectDetectionFramework

    init(framework: ObjectDetectionFramework) {
        self.framework = framework
    }

    func detectObjects(in image: UIImage, completion: @escaping (Result<[DetectedObject], Error>) -> Void) {
        isDetecting = true

        // Simulate processing delay (TensorFlow Lite takes longer)
        let delay = framework == .tensorflowLite ? 2.0 : 1.2

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.isDetecting = false

            // Generate varied mock detections based on image characteristics and framework
            let mockDetections = self.generateMockDetections(for: image)

            self.lastDetectedObjects = mockDetections
            completion(.success(mockDetections))
        }
    }

    private func generateMockDetections(for image: UIImage) -> [DetectedObject] {
        // Create a simple hash based on image properties to ensure different results
        let imageHash = self.simpleImageHash(image)

        // Define different detection scenarios based on framework
        let detectionSets: [[DetectedObject]]

        switch framework {
        case .vision:
            // Vision framework tends to detect more general objects
            detectionSets = [
                createVisionPeopleDetections(),
                createVisionAnimalDetections(),
                createVisionVehicleDetections(),
                createVisionFoodDetections(),
                createVisionObjectDetections(),
                createVisionMixedDetections()
            ]
        case .tensorflowLite:
            // TensorFlow Lite might detect more specific objects
            detectionSets = [
                createTensorFlowPeopleDetections(),
                createTensorFlowAnimalDetections(),
                createTensorFlowVehicleDetections(),
                createTensorFlowFoodDetections(),
                createTensorFlowObjectDetections(),
                createTensorFlowMixedDetections()
            ]
        }

        // Select detection set based on image hash
        let selectedIndex = imageHash % detectionSets.count
        var selectedDetections = detectionSets[selectedIndex]

        // Add some randomness to positions and confidence scores
        selectedDetections = selectedDetections.map { detection in
            let positionVariation = Float.random(in: -0.05...0.05)
            let confidenceVariation = Float.random(in: -0.1...0.1)

            let adjustedBoundingBox = CGRect(
                x: max(0, min(0.8, detection.boundingBox.minX + CGFloat(positionVariation))),
                y: max(0, min(0.8, detection.boundingBox.minY + CGFloat(positionVariation))),
                width: detection.boundingBox.width,
                height: detection.boundingBox.height
            )

            let adjustedConfidence = max(0.1, min(0.99, detection.confidence + confidenceVariation))

            return DetectedObject(
                boundingBox: adjustedBoundingBox,
                className: detection.className,
                confidence: adjustedConfidence,
                framework: framework
            )
        }

        return selectedDetections
    }

    private func simpleImageHash(_ image: UIImage) -> Int {
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let scale = Int(image.scale * 100)
        let orientation = image.imageOrientation.rawValue

        return (width * 31 + height * 17 + scale * 7 + orientation * 3) % 1000
    }

    // MARK: - Vision Framework Mock Detections
    private func createVisionPeopleDetections() -> [DetectedObject] {
        return [
            DetectedObject(
                boundingBox: CGRect(x: 0.2, y: 0.1, width: 0.3, height: 0.7),
                className: "person",
                confidence: 0.92,
                framework: framework
            ),
            DetectedObject(
                boundingBox: CGRect(x: 0.6, y: 0.2, width: 0.25, height: 0.6),
                className: "person",
                confidence: 0.87,
                framework: framework
            )
        ]
    }

    private func createVisionAnimalDetections() -> [DetectedObject] {
        return [
            DetectedObject(
                boundingBox: CGRect(x: 0.15, y: 0.3, width: 0.5, height: 0.4),
                className: "dog",
                confidence: 0.89,
                framework: framework
            ),
            DetectedObject(
                boundingBox: CGRect(x: 0.7, y: 0.6, width: 0.2, height: 0.25),
                className: "cat",
                confidence: 0.76,
                framework: framework
            )
        ]
    }

    private func createVisionVehicleDetections() -> [DetectedObject] {
        return [
            DetectedObject(
                boundingBox: CGRect(x: 0.1, y: 0.4, width: 0.6, height: 0.35),
                className: "car",
                confidence: 0.94,
                framework: framework
            ),
            DetectedObject(
                boundingBox: CGRect(x: 0.75, y: 0.2, width: 0.2, height: 0.3),
                className: "bicycle",
                confidence: 0.68,
                framework: framework
            )
        ]
    }

    private func createVisionFoodDetections() -> [DetectedObject] {
        return [
            DetectedObject(
                boundingBox: CGRect(x: 0.2, y: 0.2, width: 0.4, height: 0.4),
                className: "pizza",
                confidence: 0.85,
                framework: framework
            ),
            DetectedObject(
                boundingBox: CGRect(x: 0.65, y: 0.15, width: 0.25, height: 0.3),
                className: "cup",
                confidence: 0.72,
                framework: framework
            )
        ]
    }

    private func createVisionObjectDetections() -> [DetectedObject] {
        return [
            DetectedObject(
                boundingBox: CGRect(x: 0.3, y: 0.1, width: 0.4, height: 0.5),
                className: "laptop",
                confidence: 0.91,
                framework: framework
            ),
            DetectedObject(
                boundingBox: CGRect(x: 0.1, y: 0.7, width: 0.2, height: 0.15),
                className: "mouse",
                confidence: 0.74,
                framework: framework
            )
        ]
    }

    private func createVisionMixedDetections() -> [DetectedObject] {
        return [
            DetectedObject(
                boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.25, height: 0.4),
                className: "person",
                confidence: 0.88,
                framework: framework
            ),
            DetectedObject(
                boundingBox: CGRect(x: 0.4, y: 0.5, width: 0.3, height: 0.2),
                className: "chair",
                confidence: 0.73,
                framework: framework
            )
        ]
    }

    // MARK: - TensorFlow Lite Mock Detections (More specific/technical)
    private func createTensorFlowPeopleDetections() -> [DetectedObject] {
        return [
            DetectedObject(
                boundingBox: CGRect(x: 0.25, y: 0.15, width: 0.28, height: 0.65),
                className: "human_face",
                confidence: 0.89,
                framework: framework
            ),
            DetectedObject(
                boundingBox: CGRect(x: 0.58, y: 0.25, width: 0.22, height: 0.55),
                className: "human_body",
                confidence: 0.84,
                framework: framework
            )
        ]
    }

    private func createTensorFlowAnimalDetections() -> [DetectedObject] {
        return [
            DetectedObject(
                boundingBox: CGRect(x: 0.18, y: 0.35, width: 0.48, height: 0.38),
                className: "golden_retriever",
                confidence: 0.91,
                framework: framework
            ),
            DetectedObject(
                boundingBox: CGRect(x: 0.72, y: 0.58, width: 0.18, height: 0.28),
                className: "domestic_cat",
                confidence: 0.78,
                framework: framework
            )
        ]
    }

    private func createTensorFlowVehicleDetections() -> [DetectedObject] {
        return [
            DetectedObject(
                boundingBox: CGRect(x: 0.12, y: 0.42, width: 0.58, height: 0.33),
                className: "sedan_car",
                confidence: 0.96,
                framework: framework
            ),
            DetectedObject(
                boundingBox: CGRect(x: 0.77, y: 0.22, width: 0.18, height: 0.28),
                className: "mountain_bike",
                confidence: 0.71,
                framework: framework
            )
        ]
    }

    private func createTensorFlowFoodDetections() -> [DetectedObject] {
        return [
            DetectedObject(
                boundingBox: CGRect(x: 0.22, y: 0.22, width: 0.38, height: 0.38),
                className: "pepperoni_pizza",
                confidence: 0.87,
                framework: framework
            ),
            DetectedObject(
                boundingBox: CGRect(x: 0.67, y: 0.17, width: 0.23, height: 0.28),
                className: "coffee_mug",
                confidence: 0.74,
                framework: framework
            ),
            DetectedObject(
                boundingBox: CGRect(x: 0.12, y: 0.67, width: 0.28, height: 0.23),
                className: "red_apple",
                confidence: 0.81,
                framework: framework
            )
        ]
    }

    private func createTensorFlowObjectDetections() -> [DetectedObject] {
        return [
            DetectedObject(
                boundingBox: CGRect(x: 0.32, y: 0.12, width: 0.38, height: 0.48),
                className: "macbook_pro",
                confidence: 0.93,
                framework: framework
            ),
            DetectedObject(
                boundingBox: CGRect(x: 0.12, y: 0.72, width: 0.18, height: 0.13),
                className: "wireless_mouse",
                confidence: 0.76,
                framework: framework
            )
        ]
    }

    private func createTensorFlowMixedDetections() -> [DetectedObject] {
        return [
            DetectedObject(
                boundingBox: CGRect(x: 0.12, y: 0.12, width: 0.23, height: 0.38),
                className: "business_person",
                confidence: 0.86,
                framework: framework
            ),
            DetectedObject(
                boundingBox: CGRect(x: 0.42, y: 0.52, width: 0.28, height: 0.18),
                className: "office_chair",
                confidence: 0.75,
                framework: framework
            ),
            DetectedObject(
                boundingBox: CGRect(x: 0.75, y: 0.32, width: 0.18, height: 0.23),
                className: "water_bottle",
                confidence: 0.69,
                framework: framework
            )
        ]
    }
}
#endif
