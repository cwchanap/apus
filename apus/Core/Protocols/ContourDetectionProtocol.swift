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

// Use real Vision framework implementation (works on both device and simulator)
typealias ContourDetectionProvider = ContourDetectionManager
