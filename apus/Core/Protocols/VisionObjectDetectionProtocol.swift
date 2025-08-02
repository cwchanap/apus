//
//  VisionObjectDetectionProtocol.swift
//  apus
//
//  Created by Rovo Dev on 1/8/2025.
//

import Foundation
import UIKit
import Vision

struct VisionDetection {
    let id = UUID()
    let boundingBox: CGRect  // Normalized coordinates (0-1)
    let className: String
    let confidence: Float
    
    var displayBoundingBox: CGRect {
        // Convert from Vision coordinates (bottom-left origin) to SwiftUI coordinates (top-left origin)
        return CGRect(
            x: boundingBox.minX,
            y: 1.0 - boundingBox.maxY,  // Flip Y coordinate
            width: boundingBox.width,
            height: boundingBox.height
        )
    }
}

protocol VisionObjectDetectionProtocol: ObservableObject {
    var isDetecting: Bool { get }
    var lastDetectedObjects: [VisionDetection] { get }
    
    func detectObjects(in image: UIImage, completion: @escaping (Result<[VisionDetection], Error>) -> Void)
}

#if DEBUG || targetEnvironment(simulator)
// Mock implementation for simulator and debug builds
class MockVisionObjectDetectionManager: VisionObjectDetectionProtocol {
    @Published var isDetecting = false
    @Published var lastDetectedObjects: [VisionDetection] = []
    
    func detectObjects(in image: UIImage, completion: @escaping (Result<[VisionDetection], Error>) -> Void) {
        isDetecting = true
        
        // Simulate processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.isDetecting = false
            
            // Generate varied mock detections based on image characteristics
            let mockDetections = self.generateMockDetections(for: image)
            
            self.lastDetectedObjects = mockDetections
            completion(.success(mockDetections))
        }
    }
    
    private func generateMockDetections(for image: UIImage) -> [VisionDetection] {
        // Create a simple hash based on image properties to ensure different results
        let imageHash = self.simpleImageHash(image)
        
        // Define different detection scenarios
        let detectionSets: [[VisionDetection]] = [
            // People scenario
            self.createPeopleDetections(),
            
            // Animals scenario
            self.createAnimalDetections(),
            
            // Vehicles scenario
            self.createVehicleDetections(),
            
            // Food scenario
            self.createFoodDetections(),
            
            // Objects scenario
            self.createObjectDetections(),
            
            // Mixed scenario
            self.createMixedDetections()
        ]
        
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
            
            return VisionDetection(
                boundingBox: adjustedBoundingBox,
                className: detection.className,
                confidence: adjustedConfidence
            )
        }
        
        return selectedDetections
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
    
    private func createPeopleDetections() -> [VisionDetection] {
        return [
            VisionDetection(
                boundingBox: CGRect(x: 0.2, y: 0.1, width: 0.3, height: 0.7),
                className: "person",
                confidence: 0.92
            ),
            VisionDetection(
                boundingBox: CGRect(x: 0.6, y: 0.2, width: 0.25, height: 0.6),
                className: "person",
                confidence: 0.87
            )
        ]
    }
    
    private func createAnimalDetections() -> [VisionDetection] {
        return [
            VisionDetection(
                boundingBox: CGRect(x: 0.15, y: 0.3, width: 0.5, height: 0.4),
                className: "dog",
                confidence: 0.89
            ),
            VisionDetection(
                boundingBox: CGRect(x: 0.7, y: 0.6, width: 0.2, height: 0.25),
                className: "cat",
                confidence: 0.76
            )
        ]
    }
    
    private func createVehicleDetections() -> [VisionDetection] {
        return [
            VisionDetection(
                boundingBox: CGRect(x: 0.1, y: 0.4, width: 0.6, height: 0.35),
                className: "car",
                confidence: 0.94
            ),
            VisionDetection(
                boundingBox: CGRect(x: 0.75, y: 0.2, width: 0.2, height: 0.3),
                className: "bicycle",
                confidence: 0.68
            )
        ]
    }
    
    private func createFoodDetections() -> [VisionDetection] {
        return [
            VisionDetection(
                boundingBox: CGRect(x: 0.2, y: 0.2, width: 0.4, height: 0.4),
                className: "pizza",
                confidence: 0.85
            ),
            VisionDetection(
                boundingBox: CGRect(x: 0.65, y: 0.15, width: 0.25, height: 0.3),
                className: "cup",
                confidence: 0.72
            ),
            VisionDetection(
                boundingBox: CGRect(x: 0.1, y: 0.65, width: 0.3, height: 0.25),
                className: "apple",
                confidence: 0.79
            )
        ]
    }
    
    private func createObjectDetections() -> [VisionDetection] {
        return [
            VisionDetection(
                boundingBox: CGRect(x: 0.3, y: 0.1, width: 0.4, height: 0.5),
                className: "laptop",
                confidence: 0.91
            ),
            VisionDetection(
                boundingBox: CGRect(x: 0.1, y: 0.7, width: 0.2, height: 0.15),
                className: "mouse",
                confidence: 0.74
            )
        ]
    }
    
    private func createMixedDetections() -> [VisionDetection] {
        return [
            VisionDetection(
                boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.25, height: 0.4),
                className: "person",
                confidence: 0.88
            ),
            VisionDetection(
                boundingBox: CGRect(x: 0.4, y: 0.5, width: 0.3, height: 0.2),
                className: "chair",
                confidence: 0.73
            ),
            VisionDetection(
                boundingBox: CGRect(x: 0.75, y: 0.3, width: 0.2, height: 0.25),
                className: "bottle",
                confidence: 0.67
            )
        ]
    }
}

typealias VisionObjectDetectionProvider = MockVisionObjectDetectionManager
#else
// Use real Vision framework implementation for device builds
typealias VisionObjectDetectionProvider = VisionObjectDetectionManager
#endif