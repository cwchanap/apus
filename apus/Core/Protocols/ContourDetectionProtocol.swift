//
//  ContourDetectionProtocol.swift
//  apus
//
//  Created by Rovo Dev on 30/7/2025.
//

import Foundation
import UIKit
import Vision

struct DetectedContour {
    let id = UUID()
    let points: [CGPoint]
    let boundingBox: CGRect
    let confidence: Float
    let aspectRatio: Float
    let area: Float
    
    var isRectangular: Bool {
        // Consider rectangular if aspect ratio is reasonable and has 4+ significant points
        return points.count >= 4 && aspectRatio > 0.3 && aspectRatio < 3.0
    }
    
    var contourType: ContourType {
        if isRectangular {
            if aspectRatio > 1.2 && aspectRatio < 1.8 {
                return .document
            } else if aspectRatio > 0.6 && aspectRatio < 1.4 {
                return .square
            } else {
                return .rectangle
            }
        } else if points.count > 8 {
            return .complex
        } else {
            return .simple
        }
    }
}

enum ContourType: String, CaseIterable {
    case document = "Document"
    case rectangle = "Rectangle"
    case square = "Square"
    case complex = "Complex Shape"
    case simple = "Simple Shape"
    
    var color: UIColor {
        switch self {
        case .document:
            return .systemBlue
        case .rectangle:
            return .systemGreen
        case .square:
            return .systemOrange
        case .complex:
            return .systemPurple
        case .simple:
            return .systemRed
        }
    }
}

protocol ContourDetectionProtocol: ObservableObject {
    var isDetecting: Bool { get }
    var lastDetectedContours: [DetectedContour] { get }
    
    func detectContours(in image: UIImage, completion: @escaping (Result<[DetectedContour], Error>) -> Void)
}

#if DEBUG || targetEnvironment(simulator)
// Mock implementation for simulator and debug builds
class MockContourDetectionManager: ContourDetectionProtocol {
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
            // Document-like contours (rectangular shapes)
            self.createDocumentContours(),
            
            // Natural object contours (curved, organic shapes)
            self.createNaturalContours(),
            
            // Geometric contours (squares, circles, triangles)
            self.createGeometricContours(),
            
            // Edge-heavy contours (many small edges)
            self.createEdgeHeavyContours(),
            
            // Simple contours (few large shapes)
            self.createSimpleContours(),
            
            // Complex scene contours (mixed shapes and sizes)
            self.createComplexSceneContours()
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
    
    private func createDocumentContours() -> [DetectedContour] {
        return [
            // Main document outline
            DetectedContour(
                points: [
                    CGPoint(x: 0.1, y: 0.15),
                    CGPoint(x: 0.85, y: 0.15),
                    CGPoint(x: 0.85, y: 0.8),
                    CGPoint(x: 0.1, y: 0.8)
                ],
                boundingBox: CGRect(x: 0.1, y: 0.15, width: 0.75, height: 0.65),
                confidence: 0.95,
                aspectRatio: 1.15,
                area: 0.49
            ),
            // Text lines
            DetectedContour(
                points: [
                    CGPoint(x: 0.15, y: 0.25),
                    CGPoint(x: 0.8, y: 0.25)
                ],
                boundingBox: CGRect(x: 0.15, y: 0.25, width: 0.65, height: 0.01),
                confidence: 0.78,
                aspectRatio: 65.0,
                area: 0.007
            ),
            DetectedContour(
                points: [
                    CGPoint(x: 0.15, y: 0.35),
                    CGPoint(x: 0.75, y: 0.35)
                ],
                boundingBox: CGRect(x: 0.15, y: 0.35, width: 0.6, height: 0.01),
                confidence: 0.72,
                aspectRatio: 60.0,
                area: 0.006
            )
        ]
    }
    
    private func createNaturalContours() -> [DetectedContour] {
        return [
            // Organic curved shape (like a leaf or cloud)
            DetectedContour(
                points: [
                    CGPoint(x: 0.2, y: 0.3),
                    CGPoint(x: 0.35, y: 0.2),
                    CGPoint(x: 0.55, y: 0.25),
                    CGPoint(x: 0.7, y: 0.4),
                    CGPoint(x: 0.65, y: 0.6),
                    CGPoint(x: 0.45, y: 0.7),
                    CGPoint(x: 0.25, y: 0.65),
                    CGPoint(x: 0.15, y: 0.45)
                ],
                boundingBox: CGRect(x: 0.15, y: 0.2, width: 0.55, height: 0.5),
                confidence: 0.88,
                aspectRatio: 1.1,
                area: 0.275
            ),
            // Smaller natural detail
            DetectedContour(
                points: [
                    CGPoint(x: 0.6, y: 0.15),
                    CGPoint(x: 0.75, y: 0.18),
                    CGPoint(x: 0.8, y: 0.25),
                    CGPoint(x: 0.7, y: 0.3),
                    CGPoint(x: 0.6, y: 0.28)
                ],
                boundingBox: CGRect(x: 0.6, y: 0.15, width: 0.2, height: 0.15),
                confidence: 0.65,
                aspectRatio: 1.33,
                area: 0.03
            )
        ]
    }
    
    private func createGeometricContours() -> [DetectedContour] {
        return [
            // Square
            DetectedContour(
                points: [
                    CGPoint(x: 0.2, y: 0.2),
                    CGPoint(x: 0.6, y: 0.2),
                    CGPoint(x: 0.6, y: 0.6),
                    CGPoint(x: 0.2, y: 0.6)
                ],
                boundingBox: CGRect(x: 0.2, y: 0.2, width: 0.4, height: 0.4),
                confidence: 0.92,
                aspectRatio: 1.0,
                area: 0.16
            ),
            // Triangle
            DetectedContour(
                points: [
                    CGPoint(x: 0.5, y: 0.1),
                    CGPoint(x: 0.8, y: 0.7),
                    CGPoint(x: 0.2, y: 0.7)
                ],
                boundingBox: CGRect(x: 0.2, y: 0.1, width: 0.6, height: 0.6),
                confidence: 0.85,
                aspectRatio: 1.0,
                area: 0.18
            ),
            // Circle (approximated with many points)
            DetectedContour(
                points: [
                    CGPoint(x: 0.5, y: 0.2),
                    CGPoint(x: 0.65, y: 0.25),
                    CGPoint(x: 0.75, y: 0.4),
                    CGPoint(x: 0.7, y: 0.6),
                    CGPoint(x: 0.5, y: 0.7),
                    CGPoint(x: 0.3, y: 0.6),
                    CGPoint(x: 0.25, y: 0.4),
                    CGPoint(x: 0.35, y: 0.25)
                ],
                boundingBox: CGRect(x: 0.25, y: 0.2, width: 0.5, height: 0.5),
                confidence: 0.79,
                aspectRatio: 1.0,
                area: 0.196
            )
        ]
    }
    
    private func createEdgeHeavyContours() -> [DetectedContour] {
        return [
            // Many small horizontal edges
            DetectedContour(
                points: [CGPoint(x: 0.1, y: 0.2), CGPoint(x: 0.4, y: 0.2)],
                boundingBox: CGRect(x: 0.1, y: 0.2, width: 0.3, height: 0.01),
                confidence: 0.68,
                aspectRatio: 30.0,
                area: 0.003
            ),
            DetectedContour(
                points: [CGPoint(x: 0.1, y: 0.3), CGPoint(x: 0.5, y: 0.3)],
                boundingBox: CGRect(x: 0.1, y: 0.3, width: 0.4, height: 0.01),
                confidence: 0.72,
                aspectRatio: 40.0,
                area: 0.004
            ),
            DetectedContour(
                points: [CGPoint(x: 0.1, y: 0.4), CGPoint(x: 0.35, y: 0.4)],
                boundingBox: CGRect(x: 0.1, y: 0.4, width: 0.25, height: 0.01),
                confidence: 0.65,
                aspectRatio: 25.0,
                area: 0.0025
            ),
            // Vertical edges
            DetectedContour(
                points: [CGPoint(x: 0.6, y: 0.1), CGPoint(x: 0.6, y: 0.5)],
                boundingBox: CGRect(x: 0.6, y: 0.1, width: 0.01, height: 0.4),
                confidence: 0.75,
                aspectRatio: 0.025,
                area: 0.004
            ),
            DetectedContour(
                points: [CGPoint(x: 0.8, y: 0.2), CGPoint(x: 0.8, y: 0.6)],
                boundingBox: CGRect(x: 0.8, y: 0.2, width: 0.01, height: 0.4),
                confidence: 0.71,
                aspectRatio: 0.025,
                area: 0.004
            )
        ]
    }
    
    private func createSimpleContours() -> [DetectedContour] {
        return [
            // One large dominant shape
            DetectedContour(
                points: [
                    CGPoint(x: 0.05, y: 0.1),
                    CGPoint(x: 0.9, y: 0.1),
                    CGPoint(x: 0.9, y: 0.85),
                    CGPoint(x: 0.05, y: 0.85)
                ],
                boundingBox: CGRect(x: 0.05, y: 0.1, width: 0.85, height: 0.75),
                confidence: 0.96,
                aspectRatio: 1.13,
                area: 0.64
            ),
            // Small accent shape
            DetectedContour(
                points: [
                    CGPoint(x: 0.7, y: 0.15),
                    CGPoint(x: 0.85, y: 0.15),
                    CGPoint(x: 0.85, y: 0.25),
                    CGPoint(x: 0.7, y: 0.25)
                ],
                boundingBox: CGRect(x: 0.7, y: 0.15, width: 0.15, height: 0.1),
                confidence: 0.82,
                aspectRatio: 1.5,
                area: 0.015
            )
        ]
    }
    
    private func createComplexSceneContours() -> [DetectedContour] {
        return [
            // Mix of different shapes and sizes
            DetectedContour(
                points: [
                    CGPoint(x: 0.1, y: 0.1),
                    CGPoint(x: 0.4, y: 0.1),
                    CGPoint(x: 0.4, y: 0.3),
                    CGPoint(x: 0.1, y: 0.3)
                ],
                boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.3, height: 0.2),
                confidence: 0.87,
                aspectRatio: 1.5,
                area: 0.06
            ),
            DetectedContour(
                points: [
                    CGPoint(x: 0.5, y: 0.2),
                    CGPoint(x: 0.8, y: 0.25),
                    CGPoint(x: 0.75, y: 0.5),
                    CGPoint(x: 0.45, y: 0.45)
                ],
                boundingBox: CGRect(x: 0.45, y: 0.2, width: 0.35, height: 0.3),
                confidence: 0.74,
                aspectRatio: 1.17,
                area: 0.105
            ),
            DetectedContour(
                points: [CGPoint(x: 0.2, y: 0.6), CGPoint(x: 0.6, y: 0.6)],
                boundingBox: CGRect(x: 0.2, y: 0.6, width: 0.4, height: 0.01),
                confidence: 0.69,
                aspectRatio: 40.0,
                area: 0.004
            ),
            DetectedContour(
                points: [CGPoint(x: 0.7, y: 0.7), CGPoint(x: 0.7, y: 0.9)],
                boundingBox: CGRect(x: 0.7, y: 0.7, width: 0.01, height: 0.2),
                confidence: 0.66,
                aspectRatio: 0.05,
                area: 0.002
            )
        ]
    }
}

typealias ContourDetectionProvider = MockContourDetectionManager
#else
// Use real Vision framework implementation for device builds
typealias ContourDetectionProvider = ContourDetectionManager
#endif