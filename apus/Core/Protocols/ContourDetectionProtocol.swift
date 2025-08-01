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
            
            // Mock edge contours - simulate various edge types
            let mockContours = [
                // Large object outline
                DetectedContour(
                    points: [
                        CGPoint(x: 0.1, y: 0.2),
                        CGPoint(x: 0.8, y: 0.2),
                        CGPoint(x: 0.8, y: 0.7),
                        CGPoint(x: 0.1, y: 0.7)
                    ],
                    boundingBox: CGRect(x: 0.1, y: 0.2, width: 0.7, height: 0.5),
                    confidence: 0.92,
                    aspectRatio: 1.4,
                    area: 0.35
                ),
                // Medium curved edge
                DetectedContour(
                    points: [
                        CGPoint(x: 0.2, y: 0.3),
                        CGPoint(x: 0.4, y: 0.25),
                        CGPoint(x: 0.6, y: 0.3),
                        CGPoint(x: 0.7, y: 0.4),
                        CGPoint(x: 0.6, y: 0.5),
                        CGPoint(x: 0.4, y: 0.55),
                        CGPoint(x: 0.2, y: 0.5)
                    ],
                    boundingBox: CGRect(x: 0.2, y: 0.25, width: 0.5, height: 0.3),
                    confidence: 0.85,
                    aspectRatio: 1.67,
                    area: 0.15
                ),
                // Small detail edges
                DetectedContour(
                    points: [
                        CGPoint(x: 0.3, y: 0.1),
                        CGPoint(x: 0.5, y: 0.12),
                        CGPoint(x: 0.6, y: 0.15)
                    ],
                    boundingBox: CGRect(x: 0.3, y: 0.1, width: 0.3, height: 0.05),
                    confidence: 0.65,
                    aspectRatio: 6.0,
                    area: 0.015
                ),
                // Vertical edge
                DetectedContour(
                    points: [
                        CGPoint(x: 0.75, y: 0.2),
                        CGPoint(x: 0.76, y: 0.6)
                    ],
                    boundingBox: CGRect(x: 0.75, y: 0.2, width: 0.01, height: 0.4),
                    confidence: 0.70,
                    aspectRatio: 0.025,
                    area: 0.004
                ),
                // Horizontal edge
                DetectedContour(
                    points: [
                        CGPoint(x: 0.1, y: 0.65),
                        CGPoint(x: 0.4, y: 0.66)
                    ],
                    boundingBox: CGRect(x: 0.1, y: 0.65, width: 0.3, height: 0.01),
                    confidence: 0.68,
                    aspectRatio: 30.0,
                    area: 0.003
                )
            ]
            
            self.lastDetectedContours = mockContours
            completion(.success(mockContours))
        }
    }
}

typealias ContourDetectionProvider = MockContourDetectionManager
#else
// Use real Vision framework implementation for device builds
typealias ContourDetectionProvider = ContourDetectionManager
#endif