//
//  MockContourScenarios.swift
//  apus
//
//  Created by Rovo Dev on 9/8/2025.
//

import UIKit

#if DEBUG || targetEnvironment(simulator)
struct MockContourScenarios {
    static func createDocumentContours() -> [DetectedContour] {
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

    static func createNaturalContours() -> [DetectedContour] {
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

    static func createGeometricContours() -> [DetectedContour] {
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

    static func createEdgeHeavyContours() -> [DetectedContour] {
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

    static func createSimpleContours() -> [DetectedContour] {
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

    static func createComplexSceneContours() -> [DetectedContour] {
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
#endif
