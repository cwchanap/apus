//
//  DetectionResultFixtures.swift
//  apusTests
//
//  Created by Codex on 2026/05/24.
//

import CoreGraphics
import UIKit
import XCTest
@testable import apus

enum DetectionResultFixtures {
    static let timestamp = Date(timeIntervalSince1970: 1_700_000_000)

    static func image(size: CGSize = CGSize(width: 400, height: 300)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            UIColor.systemBlue.setFill()
            context.fill(CGRect(x: size.width * 0.1, y: size.height * 0.2, width: size.width * 0.5, height: size.height * 0.3))

            UIColor.systemGreen.setFill()
            context.fill(CGRect(x: size.width * 0.62, y: size.height * 0.25, width: size.width * 0.22, height: size.height * 0.32))
        }
    }

    static func detectedTexts() -> [DetectedText] {
        [
            DetectedText(
                text: "Receipt",
                boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.4, height: 0.12),
                confidence: 0.94,
                characterBoxes: []
            ),
            DetectedText(
                text: "Total 12.50",
                boundingBox: CGRect(x: 0.2, y: 0.4, width: 0.5, height: 0.1),
                confidence: 0.82,
                characterBoxes: []
            )
        ]
    }

    static func detectedObjects() -> [DetectedObject] {
        [
            DetectedObject(
                boundingBox: CGRect(x: 0.2, y: 0.15, width: 0.4, height: 0.35),
                className: "book",
                confidence: 0.91,
                framework: .vision
            ),
            DetectedObject(
                boundingBox: CGRect(x: 0.55, y: 0.25, width: 0.25, height: 0.3),
                className: "laptop",
                confidence: 0.73,
                framework: .coreML
            )
        ]
    }

    static func classifications() -> [ClassificationResult] {
        [
            ClassificationResult(identifier: "document", confidence: 0.88),
            ClassificationResult(identifier: "receipt", confidence: 0.74),
            ClassificationResult(identifier: "paper", confidence: 0.61)
        ]
    }

    static func contours() -> [DetectedContour] {
        [
            DetectedContour(
                points: [
                    CGPoint(x: 0.1, y: 0.1),
                    CGPoint(x: 0.7, y: 0.1),
                    CGPoint(x: 0.7, y: 0.55),
                    CGPoint(x: 0.1, y: 0.55)
                ],
                boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.6, height: 0.45),
                confidence: 0.86,
                aspectRatio: 1.33,
                area: 0.27
            ),
            DetectedContour(
                points: [
                    CGPoint(x: 0.2, y: 0.25),
                    CGPoint(x: 0.35, y: 0.4),
                    CGPoint(x: 0.22, y: 0.5)
                ],
                boundingBox: CGRect(x: 0.2, y: 0.25, width: 0.15, height: 0.25),
                confidence: 0.72,
                aspectRatio: 0.6,
                area: 0.04
            )
        ]
    }

    static func ocrResult() -> StoredOCRResult {
        StoredOCRResult(detectedTexts: detectedTexts(), image: image(), timestamp: timestamp)
    }

    static func objectResult() -> StoredObjectDetectionResult {
        StoredObjectDetectionResult(detectedObjects: detectedObjects(), image: image(), timestamp: timestamp)
    }

    static func classificationResult() -> StoredClassificationResult {
        StoredClassificationResult(classificationResults: classifications(), image: image(), timestamp: timestamp)
    }

    static func contourResult(file: StaticString = #filePath, line: UInt = #line) -> StoredContourDetectionResult {
        let fixtureImage = image()
        let fixture = StoredContourDetectionResultFixture(
            timestamp: timestamp,
            detectedContours: contours().map(StoredDetectedContourFixture.init),
            imageData: fixtureImage.jpegData(compressionQuality: 0.7) ?? Data(),
            imageSize: fixtureImage.size,
            thumbnailData: fixtureImage.resizedMaintainingAspectRatio(to: CGSize(width: 160, height: 160)).jpegData(compressionQuality: 0.6)
        )

        return decodeFixture(
            fixture,
            as: StoredContourDetectionResult.self,
            fallback: StoredContourDetectionResult(detectedContours: contours(), image: fixtureImage),
            file: file,
            line: line
        )
    }

    static func barcodeResult(
        payloads: [(payload: String, symbology: String)] = [("https://example.com/docs", "QR")],
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> StoredBarcodeDetectionResult {
        let fixtureImage = image()
        let barcodeFixtures = payloads.enumerated().map { index, payloadInfo in
            StoredDetectedBarcodeFixture(
                payload: payloadInfo.payload,
                symbology: payloadInfo.symbology,
                boundingBox: CGRect(x: 0.1 + CGFloat(index) * 0.08, y: 0.12, width: 0.32, height: 0.28),
                confidence: max(0.5, 0.92 - Float(index) * 0.08)
            )
        }
        let fixture = StoredBarcodeDetectionResultFixture(
            timestamp: timestamp,
            detectedBarcodes: barcodeFixtures,
            imageData: fixtureImage.jpegData(compressionQuality: 0.7) ?? Data(),
            imageSize: fixtureImage.size,
            thumbnailData: fixtureImage.resizedMaintainingAspectRatio(to: CGSize(width: 160, height: 160)).jpegData(compressionQuality: 0.6)
        )

        return decodeFixture(
            fixture,
            as: StoredBarcodeDetectionResult.self,
            fallback: StoredBarcodeDetectionResult(detectedBarcodes: [], image: fixtureImage),
            file: file,
            line: line
        )
    }

    @MainActor
    static func emptyManager(isLoading: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> DetectionResultsManager {
        let manager = DetectionResultsManager()
        waitUntilLoaded(manager, file: file, line: line)
        reset(manager, file: file, line: line)
        manager.isLoading = isLoading
        return manager
    }

    @MainActor
    static func populatedManager(file: StaticString = #filePath, line: UInt = #line) -> DetectionResultsManager {
        let manager = emptyManager(file: file, line: line)
        manager.ocrResults = [ocrResult()]
        manager.objectDetectionResults = [objectResult()]
        manager.classificationResults = [classificationResult()]
        manager.contourResults = [contourResult(file: file, line: line)]
        manager.barcodeResults = [
            barcodeResult(payloads: [("https://example.com/docs", "QR"), ("9781234567890", "EAN13")], file: file, line: line)
        ]
        persist(manager, file: file, line: line)
        manager.updateCachedValues()
        return manager
    }

    @MainActor
    static func reset(_ manager: DetectionResultsManager, file: StaticString = #filePath, line: UInt = #line) {
        waitUntilLoaded(manager, file: file, line: line)
        manager.ocrResults = []
        manager.objectDetectionResults = []
        manager.classificationResults = []
        manager.contourResults = []
        manager.barcodeResults = []
        manager.ocrResultsData = Data()
        manager.objectDetectionResultsData = Data()
        manager.classificationResultsData = Data()
        manager.contourDetectionResultsData = Data()
        manager.barcodeDetectionResultsData = Data()
        manager.isLoading = false
        manager.updateCachedValues()
    }
}

private extension DetectionResultFixtures {
    struct StoredDetectedContourFixture: Codable {
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

    struct StoredContourDetectionResultFixture: Codable {
        let timestamp: Date
        let detectedContours: [StoredDetectedContourFixture]
        let imageData: Data
        let imageSize: CGSize
        let thumbnailData: Data?
    }

    struct StoredDetectedBarcodeFixture: Codable {
        let payload: String
        let symbology: String
        let boundingBox: CGRect
        let confidence: Float
    }

    struct StoredBarcodeDetectionResultFixture: Codable {
        let timestamp: Date
        let detectedBarcodes: [StoredDetectedBarcodeFixture]
        let imageData: Data
        let imageSize: CGSize
        let thumbnailData: Data?
    }

    static func decodeFixture<Fixture: Encodable, Result: Decodable>(
        _ fixture: Fixture,
        as resultType: Result.Type,
        fallback: Result,
        file: StaticString,
        line: UInt
    ) -> Result {
        do {
            let data = try JSONEncoder().encode(fixture)
            return try JSONDecoder().decode(resultType, from: data)
        } catch {
            XCTFail("Failed to decode detection result fixture: \(error)", file: file, line: line)
            return fallback
        }
    }

    @MainActor
    static func waitUntilLoaded(_ manager: DetectionResultsManager, timeout: TimeInterval = 1.0, file: StaticString, line: UInt) {
        let deadline = Date().addingTimeInterval(timeout)
        while manager.isLoading && Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }

        XCTAssertFalse(manager.isLoading, "DetectionResultsManager initial load did not finish before timeout.", file: file, line: line)
    }

    @MainActor
    static func persist(_ manager: DetectionResultsManager, file: StaticString, line: UInt) {
        manager.ocrResultsData = encode(manager.ocrResults, file: file, line: line)
        manager.objectDetectionResultsData = encode(manager.objectDetectionResults, file: file, line: line)
        manager.classificationResultsData = encode(manager.classificationResults, file: file, line: line)
        manager.contourDetectionResultsData = encode(manager.contourResults, file: file, line: line)
        manager.barcodeDetectionResultsData = encode(manager.barcodeResults, file: file, line: line)
    }

    static func encode<T: Encodable>(_ value: T, file: StaticString, line: UInt) -> Data {
        do {
            return try JSONEncoder().encode(value)
        } catch {
            XCTFail("Failed to encode detection result fixture: \(error)", file: file, line: line)
            return Data()
        }
    }
}
