//
//  DetectionResults.swift
//  apus
//
//  Created by Rovo Dev on 3/8/2025.
//

import Foundation
import UIKit

// MARK: - Stored Detection Results

/// Stored OCR text recognition result
struct StoredOCRResult: Codable, Identifiable {
    let id = UUID()
    let timestamp: Date
    let detectedTexts: [StoredDetectedText]
    let imageData: Data
    let imageSize: CGSize

    init(detectedTexts: [DetectedText], image: UIImage) {
        self.timestamp = Date()
        self.detectedTexts = detectedTexts.map { StoredDetectedText(from: $0) }
        self.imageData = image.jpegData(compressionQuality: 0.7) ?? Data()
        self.imageSize = image.size
    }

    var image: UIImage? {
        return UIImage(data: imageData)
    }

    var totalTextCount: Int {
        return detectedTexts.count
    }

    var averageConfidence: Float {
        guard !detectedTexts.isEmpty else { return 0.0 }
        let total = detectedTexts.reduce(0.0) { $0 + $1.confidence }
        return total / Float(detectedTexts.count)
    }

    var allText: String {
        return detectedTexts.map { $0.text }.joined(separator: " ")
    }
}

/// Stored detected text (simplified for storage)
struct StoredDetectedText: Codable, Identifiable {
    let id = UUID()
    let text: String
    let boundingBox: CGRect
    let confidence: Float

    init(from detectedText: DetectedText) {
        self.text = detectedText.text
        self.boundingBox = detectedText.boundingBox
        self.confidence = detectedText.confidence
    }

    func toDetectedText() -> DetectedText {
        return DetectedText(
            text: text,
            boundingBox: boundingBox,
            confidence: confidence,
            characterBoxes: []
        )
    }
}

/// Stored object detection result
struct StoredObjectDetectionResult: Codable, Identifiable {
    let id = UUID()
    let timestamp: Date
    let detectedObjects: [StoredDetectedObject]
    let imageData: Data
    let imageSize: CGSize
    let framework: String

    init(detectedObjects: [DetectedObject], image: UIImage) {
        self.timestamp = Date()
        self.detectedObjects = detectedObjects.map { StoredDetectedObject(from: $0) }
        self.imageData = image.jpegData(compressionQuality: 0.7) ?? Data()
        self.imageSize = image.size
        self.framework = detectedObjects.first?.framework.displayName ?? "Unknown"
    }

    var image: UIImage? {
        return UIImage(data: imageData)
    }

    var totalObjectCount: Int {
        return detectedObjects.count
    }

    var averageConfidence: Float {
        guard !detectedObjects.isEmpty else { return 0.0 }
        let total = detectedObjects.reduce(0.0) { $0 + $1.confidence }
        return total / Float(detectedObjects.count)
    }

    var uniqueClasses: [String] {
        return Array(Set(detectedObjects.map { $0.className })).sorted()
    }
}

/// Stored detected object (simplified for storage)
struct StoredDetectedObject: Codable, Identifiable {
    let id = UUID()
    let boundingBox: CGRect
    let className: String
    let confidence: Float
    let framework: String

    init(from detectedObject: DetectedObject) {
        self.boundingBox = detectedObject.boundingBox
        self.className = detectedObject.className
        self.confidence = detectedObject.confidence
        self.framework = detectedObject.framework.displayName
    }

    func toDetectedObject() -> DetectedObject {
        let frameworkEnum = ObjectDetectionFramework.allCases.first { $0.displayName == framework } ?? .vision
        return DetectedObject(
            boundingBox: boundingBox,
            className: className,
            confidence: confidence,
            framework: frameworkEnum
        )
    }
}

/// Stored image classification result
struct StoredClassificationResult: Codable, Identifiable {
    let id = UUID()
    let timestamp: Date
    let classificationResults: [StoredClassification]
    let imageData: Data
    let imageSize: CGSize

    init(classificationResults: [ClassificationResult], image: UIImage) {
        self.timestamp = Date()
        self.classificationResults = classificationResults.map { StoredClassification(from: $0) }
        self.imageData = image.jpegData(compressionQuality: 0.7) ?? Data()
        self.imageSize = image.size
    }

    var image: UIImage? {
        return UIImage(data: imageData)
    }

    var topResult: StoredClassification? {
        return classificationResults.first
    }

    var averageConfidence: Float {
        guard !classificationResults.isEmpty else { return 0.0 }
        let total = classificationResults.reduce(0.0) { $0 + $1.confidence }
        return total / Float(classificationResults.count)
    }
}

/// Stored classification (simplified for storage)
struct StoredClassification: Codable, Identifiable {
    let id = UUID()
    let identifier: String
    let confidence: Float

    init(from classificationResult: ClassificationResult) {
        self.identifier = classificationResult.identifier
        self.confidence = classificationResult.confidence
    }

    func toClassificationResult() -> ClassificationResult {
        return ClassificationResult(identifier: identifier, confidence: confidence)
    }
}

// MARK: - Extensions for ObjectDetectionFramework

extension ObjectDetectionFramework {
    static var allCases: [ObjectDetectionFramework] {
        return [.vision, .tensorflowLite]
    }
}
