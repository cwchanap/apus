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

    // Detect objects in an image
    func detectObjects(in image: UIImage, completion: @escaping (Result<[DetectedObject], Error>) -> Void)

    // Optional hook for heavy model/resource preloading; default is no-op
    func preload()
}

// Provide a default no-op for preload so only heavy frameworks need to implement
extension UnifiedObjectDetectionProtocol {
    func preload() {}
}

// Factory declaration (implementation moved to concrete managers to keep file small)
class ObjectDetectionFactory {
    static func createObjectDetectionManager() -> any UnifiedObjectDetectionProtocol {
        #if DEBUG || targetEnvironment(simulator)
        return MockUnifiedObjectDetectionManager(framework: .vision)
        #else
        // Prefer Core ML YOLO if a bundled model is present; otherwise fallback to Vision
        if YOLOv12CoreMLObjectDetectionManager.loadBundledModel() != nil {
            return YOLOv12CoreMLObjectDetectionManager()
        } else {
            return VisionUnifiedObjectDetectionManager()
        }
        #endif
    }

    static func createObjectDetectionManager(framework: ObjectDetectionFramework) -> any UnifiedObjectDetectionProtocol {
        #if DEBUG || targetEnvironment(simulator)
        return MockUnifiedObjectDetectionManager(framework: framework)
        #else
        switch framework {
        case .vision:
            return VisionUnifiedObjectDetectionManager()
        case .coreML:
            // Use YOLO Core ML implementation when explicitly requesting Core ML
            if YOLOv12CoreMLObjectDetectionManager.loadBundledModel() != nil {
                return YOLOv12CoreMLObjectDetectionManager()
            } else {
                return CoreMLObjectDetectionManager()
            }
        }
        #endif
    }
}
