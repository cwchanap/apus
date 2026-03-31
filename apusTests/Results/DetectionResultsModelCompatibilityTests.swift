//
//  DetectionResultsModelCompatibilityTests.swift
//  apusTests
//
//  Created by Codex on 2026/03/29.
//

import XCTest
@testable import apus

extension DetectionResultsModelsTests {
    func testStoredDetectedObjectFrameworkConversionMapsLegacyTensorFlowLiteToCoreML() throws {
        let originalObject = StoredDetectedObject(
            from: DetectedObject(
                boundingBox: CGRect(x: 0.2, y: 0.1, width: 0.4, height: 0.3),
                className: "legacy",
                confidence: 0.88,
                framework: .vision
            )
        )

        let encoded = try JSONEncoder().encode(originalObject)
        let updatedData = try DetectionResultsTestSupport.replacingJSONValue("TensorFlow Lite", forKey: "framework", in: encoded)
        let decoded = try JSONDecoder().decode(StoredDetectedObject.self, from: updatedData)

        XCTAssertEqual(decoded.toDetectedObject().framework, .coreML)
    }

    func testStoredDetectedObjectFrameworkConversionFallsBackToVisionForUnknownFramework() throws {
        let originalObject = StoredDetectedObject(
            from: DetectedObject(
                boundingBox: CGRect(x: 0.2, y: 0.1, width: 0.4, height: 0.3),
                className: "unknown",
                confidence: 0.61,
                framework: .coreML
            )
        )

        let encoded = try JSONEncoder().encode(originalObject)
        let updatedData = try DetectionResultsTestSupport.replacingJSONValue("Completely Unknown", forKey: "framework", in: encoded)
        let decoded = try JSONDecoder().decode(StoredDetectedObject.self, from: updatedData)

        XCTAssertEqual(decoded.toDetectedObject().framework, .vision)
    }

    func testStoredOCRResultThumbnailImageGeneratesFallbackWhenThumbnailDataIsMissing() throws {
        let detectedTexts = [
            DetectedText(text: "Fallback", boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.3, height: 0.1), confidence: 0.95, characterBoxes: [])
        ]
        let originalResult = StoredOCRResult(detectedTexts: detectedTexts, image: testImage)

        let encoded = try JSONEncoder().encode(originalResult)
        let legacyData = try DetectionResultsTestSupport.removingJSONKey("thumbnailData", from: encoded)
        let decoded = try JSONDecoder().decode(StoredOCRResult.self, from: legacyData)

        XCTAssertNil(decoded.thumbnailData)
        XCTAssertNotNil(decoded.thumbnailImage)
    }

    func testStoredObjectDetectionResultThumbnailImageGeneratesFallbackWhenThumbnailDataIsMissing() throws {
        let detectedObjects = [
            DetectedObject(boundingBox: CGRect.zero, className: "person", confidence: 0.91, framework: .vision)
        ]
        let originalResult = StoredObjectDetectionResult(detectedObjects: detectedObjects, image: testImage)

        let encoded = try JSONEncoder().encode(originalResult)
        let legacyData = try DetectionResultsTestSupport.removingJSONKey("thumbnailData", from: encoded)
        let decoded = try JSONDecoder().decode(StoredObjectDetectionResult.self, from: legacyData)

        XCTAssertNil(decoded.thumbnailData)
        XCTAssertNotNil(decoded.thumbnailImage)
    }

    func testStoredContourDetectionResultStatistics() throws {
        let contours = [
            DetectedContour(
                points: [CGPoint(x: 0, y: 0), CGPoint(x: 0.7, y: 0), CGPoint(x: 0.7, y: 0.5), CGPoint(x: 0, y: 0.5)],
                boundingBox: CGRect(x: 0, y: 0, width: 0.7, height: 0.5),
                confidence: 0.9,
                aspectRatio: 1.4,
                area: 0.35
            ),
            DetectedContour(
                points: [CGPoint(x: 0.2, y: 0.2), CGPoint(x: 0.6, y: 0.2), CGPoint(x: 0.6, y: 0.5), CGPoint(x: 0.2, y: 0.5)],
                boundingBox: CGRect(x: 0.2, y: 0.2, width: 0.4, height: 0.3),
                confidence: 0.8,
                aspectRatio: 1.33,
                area: 0.12
            ),
            DetectedContour(
                points: [CGPoint(x: 0, y: 0), CGPoint(x: 0.1, y: 0.1), CGPoint(x: 0.2, y: 0)],
                boundingBox: CGRect(x: 0, y: 0, width: 0.2, height: 0.1),
                confidence: 0.6,
                aspectRatio: 2.0,
                area: 0.02
            )
        ]

        let storedResult = StoredContourDetectionResult(detectedContours: contours, image: testImage)

        XCTAssertEqual(storedResult.totalContourCount, 3)
        XCTAssertEqual(storedResult.averageConfidence, 0.7666, accuracy: 0.01)
        XCTAssertEqual(storedResult.typeBreakdown[ContourType.document.rawValue], 2)
        XCTAssertEqual(storedResult.typeBreakdown[ContourType.simple.rawValue], 1)
        XCTAssertNotNil(storedResult.thumbnailImage)
    }

    func testStoredBarcodeDetectionResultDecodingSupportsFallbackThumbnailGeneration() throws {
        let fixture = DetectionResultsTestSupport.StoredBarcodeDetectionResultFixture(
            timestamp: Date(timeIntervalSince1970: 1234),
            detectedBarcodes: [
                DetectionResultsTestSupport.StoredDetectedBarcodeFixture(
                    payload: "abc-123",
                    symbology: "QR",
                    boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.4, height: 0.4),
                    confidence: 0.95
                ),
                DetectionResultsTestSupport.StoredDetectedBarcodeFixture(
                    payload: "",
                    symbology: "EAN13",
                    boundingBox: CGRect(x: 0.5, y: 0.3, width: 0.2, height: 0.2),
                    confidence: 0.74
                )
            ],
            imageData: testImage.jpegData(compressionQuality: 0.7) ?? Data(),
            imageSize: testImage.size,
            thumbnailData: nil
        )

        let data = try JSONEncoder().encode(fixture)
        let decoded = try JSONDecoder().decode(StoredBarcodeDetectionResult.self, from: data)

        XCTAssertEqual(decoded.totalBarcodeCount, 2)
        XCTAssertNotNil(decoded.image)
        XCTAssertNotNil(decoded.thumbnailImage)
    }
}
