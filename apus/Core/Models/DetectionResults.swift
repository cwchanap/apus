//
//  DetectionResults.swift
//  apus
//
//  Created by Rovo Dev on 3/8/2025.
//

import Foundation
import UIKit
import CoreGraphics
import Vision

// MARK: - Stored Detection Results

/// Stored OCR text recognition result
struct StoredOCRResult: Codable, Identifiable {
    let id = UUID()
    let timestamp: Date
    let detectedTexts: [StoredDetectedText]
    let imageData: Data
    let imageSize: CGSize
    let thumbnailData: Data?

    init(detectedTexts: [DetectedText], image: UIImage) {
        self.timestamp = Date()
        self.detectedTexts = detectedTexts.map { StoredDetectedText(from: $0) }
        self.imageData = image.jpegData(compressionQuality: 0.7) ?? Data()
        self.imageSize = image.size
        // Precompute a small thumbnail to avoid heavy decoding on lists
        let maxThumb: CGFloat = 160
        let thumb = image.resizedMaintainingAspectRatio(to: CGSize(width: maxThumb, height: maxThumb))
        self.thumbnailData = thumb.jpegData(compressionQuality: 0.6)
    }

    var image: UIImage? {
        return UIImage(data: imageData)
    }

    var thumbnailImage: UIImage? {
        if let data = thumbnailData { return UIImage(data: data) }
        // Fallback: generate from full image data if older entries without thumbnail
        guard let full = UIImage(data: imageData) else { return nil }
        let maxThumb: CGFloat = 160
        let thumb = full.resizedMaintainingAspectRatio(to: CGSize(width: maxThumb, height: maxThumb))
        return thumb
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
    let thumbnailData: Data?

    init(detectedObjects: [DetectedObject], image: UIImage) {
        self.timestamp = Date()
        self.detectedObjects = detectedObjects.map { StoredDetectedObject(from: $0) }
        self.imageData = image.jpegData(compressionQuality: 0.7) ?? Data()
        self.imageSize = image.size
        self.framework = detectedObjects.first?.framework.displayName ?? "Unknown"
        let maxThumb: CGFloat = 160
        let thumb = image.resizedMaintainingAspectRatio(to: CGSize(width: maxThumb, height: maxThumb))
        self.thumbnailData = thumb.jpegData(compressionQuality: 0.6)
    }

    var image: UIImage? {
        return UIImage(data: imageData)
    }

    var thumbnailImage: UIImage? {
        if let data = thumbnailData { return UIImage(data: data) }
        guard let full = UIImage(data: imageData) else { return nil }
        let maxThumb: CGFloat = 160
        let thumb = full.resizedMaintainingAspectRatio(to: CGSize(width: maxThumb, height: maxThumb))
        return thumb
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
    let thumbnailData: Data?

    init(classificationResults: [ClassificationResult], image: UIImage) {
        self.timestamp = Date()
        self.classificationResults = classificationResults.map { StoredClassification(from: $0) }
        self.imageData = image.jpegData(compressionQuality: 0.7) ?? Data()
        self.imageSize = image.size
        let maxThumb: CGFloat = 160
        let thumb = image.resizedMaintainingAspectRatio(to: CGSize(width: maxThumb, height: maxThumb))
        self.thumbnailData = thumb.jpegData(compressionQuality: 0.6)
    }

    var image: UIImage? {
        return UIImage(data: imageData)
    }

    var thumbnailImage: UIImage? {
        if let data = thumbnailData { return UIImage(data: data) }
        guard let full = UIImage(data: imageData) else { return nil }
        let maxThumb: CGFloat = 160
        let thumb = full.resizedMaintainingAspectRatio(to: CGSize(width: maxThumb, height: maxThumb))
        return thumb
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

// MARK: - Stored Contour Detection Results

/// Stored contour detection result
struct StoredContourDetectionResult: Codable, Identifiable {
    let id = UUID()
    let timestamp: Date
    let detectedContours: [StoredDetectedContour]
    let imageData: Data
    let imageSize: CGSize
    let thumbnailData: Data?

    init(detectedContours: [DetectedContour], image: UIImage) {
        self.timestamp = Date()
        self.detectedContours = detectedContours.map { StoredDetectedContour(from: $0) }
        self.imageData = image.jpegData(compressionQuality: 0.7) ?? Data()
        self.imageSize = image.size
        let maxThumb: CGFloat = 160
        let thumb = image.resizedMaintainingAspectRatio(to: CGSize(width: maxThumb, height: maxThumb))
        self.thumbnailData = thumb.jpegData(compressionQuality: 0.6)
    }

    var image: UIImage? {
        return UIImage(data: imageData)
    }

    var thumbnailImage: UIImage? {
        if let data = thumbnailData { return UIImage(data: data) }
        guard let full = UIImage(data: imageData) else { return nil }
        let maxThumb: CGFloat = 160
        let thumb = full.resizedMaintainingAspectRatio(to: CGSize(width: maxThumb, height: maxThumb))
        return thumb
    }

    var totalContourCount: Int {
        return detectedContours.count
    }

    var averageConfidence: Float {
        guard !detectedContours.isEmpty else { return 0.0 }
        let total = detectedContours.reduce(0.0) { $0 + $1.confidence }
        return total / Float(detectedContours.count)
    }

    var typeBreakdown: [String: Int] {
        var counts: [String: Int] = [:]
        for contour in detectedContours {
            counts[contour.type] = (counts[contour.type] ?? 0) + 1
        }
        return counts
    }
}

/// Stored detected contour (simplified for storage)
struct StoredDetectedContour: Codable, Identifiable {
    let id = UUID()
    let points: [CGPoint]
    let boundingBox: CGRect
    let confidence: Float
    let aspectRatio: Float
    let area: Float
    let type: String

    init(from contour: DetectedContour) {
        self.points = contour.points
        self.boundingBox = contour.boundingBox
        self.confidence = contour.confidence
        self.aspectRatio = contour.aspectRatio
        self.area = contour.area
        self.type = contour.contourType.rawValue
    }
}

// MARK: - Stored Barcode Detection Results

/// Stored barcode detection result
struct StoredBarcodeDetectionResult: Codable, Identifiable {
    let id = UUID()
    let timestamp: Date
    let detectedBarcodes: [StoredDetectedBarcode]
    let imageData: Data
    let imageSize: CGSize
    let thumbnailData: Data?

    init(detectedBarcodes: [VNBarcodeObservation], image: UIImage) {
        self.timestamp = Date()
        self.detectedBarcodes = detectedBarcodes.map { StoredDetectedBarcode(from: $0) }
        self.imageData = image.jpegData(compressionQuality: 0.7) ?? Data()
        self.imageSize = image.size
        let maxThumb: CGFloat = 160
        let thumb = image.resizedMaintainingAspectRatio(to: CGSize(width: maxThumb, height: maxThumb))
        self.thumbnailData = thumb.jpegData(compressionQuality: 0.6)
    }

    var image: UIImage? {
        return UIImage(data: imageData)
    }

    var thumbnailImage: UIImage? {
        if let data = thumbnailData { return UIImage(data: data) }
        guard let full = UIImage(data: imageData) else { return nil }
        let maxThumb: CGFloat = 160
        let thumb = full.resizedMaintainingAspectRatio(to: CGSize(width: maxThumb, height: maxThumb))
        return thumb
    }

    var totalBarcodeCount: Int {
        return detectedBarcodes.count
    }
}

/// Stored detected barcode (simplified for storage)
struct StoredDetectedBarcode: Codable, Identifiable {
    let id = UUID()
    let payload: String
    let symbology: String
    let boundingBox: CGRect
    let confidence: Float

    init(from barcode: VNBarcodeObservation) {
        self.payload = barcode.payloadStringValue ?? ""
        self.symbology = barcode.symbology.rawValue
        self.boundingBox = barcode.boundingBox
        self.confidence = barcode.confidence
    }
}
