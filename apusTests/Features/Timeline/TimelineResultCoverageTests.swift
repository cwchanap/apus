//
//  TimelineResultCoverageTests.swift
//  apusTests
//
//  Created by Copilot on 2026/03/31.
//

import XCTest
@testable import apus

extension TimelineResultTests {
    func test_previewText_returnsContourTypes_forContourResult() {
        let contourResult = makeContourResult(
            contours: [
                makeContour(aspectRatio: 1.4),
                makeContour(aspectRatio: 1.0)
            ]
        )

        let timelineResult = TimelineResult.contour(contourResult)

        XCTAssertTrue(timelineResult.previewText.contains(ContourType.document.rawValue))
        XCTAssertTrue(timelineResult.previewText.contains(ContourType.square.rawValue))
    }

    func test_previewText_returnsNoContoursDetected_forEmptyContourResult() {
        let timelineResult = TimelineResult.contour(makeContourResult(contours: []))

        XCTAssertEqual(timelineResult.previewText, "No contours detected")
    }

    func test_previewText_returnsBarcodeSymbology_whenPayloadIsEmpty() throws {
        let timelineResult = TimelineResult.barcode(
            try makeBarcodeResult(payloads: [(payload: "", symbology: "QR")])
        )

        XCTAssertEqual(timelineResult.previewText, "QR")
    }

    func test_statsText_returnsBarcodeCount_forMultipleBarcodes() throws {
        let timelineResult = TimelineResult.barcode(
            try makeBarcodeResult(
                payloads: [
                    (payload: "first", symbology: "QR"),
                    (payload: "second", symbology: "EAN13")
                ]
            )
        )

        XCTAssertEqual(timelineResult.statsText, "2 barcodes")
    }

    func test_matchesSearch_returnsTrue_whenContourTypeContainsQuery() {
        let timelineResult = TimelineResult.contour(
            makeContourResult(
                contours: [
                    makeContour(aspectRatio: 1.4),
                    makeContour(aspectRatio: 0.9)
                ]
            )
        )

        XCTAssertTrue(timelineResult.matchesSearch("document"))
        XCTAssertTrue(timelineResult.matchesSearch("SQUARE"))
        XCTAssertFalse(timelineResult.matchesSearch("barcode"))
    }

    func test_matchesSearch_returnsTrue_whenBarcodePayloadOrSymbologyContainsQuery() throws {
        let timelineResult = TimelineResult.barcode(
            try makeBarcodeResult(
                payloads: [
                    (payload: "invoice-123", symbology: "Code128"),
                    (payload: "", symbology: "QR")
                ]
            )
        )

        XCTAssertTrue(timelineResult.matchesSearch("invoice"))
        XCTAssertTrue(timelineResult.matchesSearch("qr"))
        XCTAssertFalse(timelineResult.matchesSearch("document"))
    }

    func test_group_usesInclusiveWeekBoundaries_relativeToReferenceDate() {
        let calendar = Calendar.current
        let referenceDate = Date(timeIntervalSince1970: 1_700_000_000)
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: referenceDate)!
        let fourteenDaysAgo = calendar.date(byAdding: .day, value: -14, to: referenceDate)!
        let fifteenDaysAgo = calendar.date(byAdding: .day, value: -15, to: referenceDate)!

        XCTAssertEqual(TimelineResult.ocr(makeTimedOCRResult(timestamp: sevenDaysAgo)).group(relativeTo: referenceDate), .thisWeek)
        XCTAssertEqual(TimelineResult.ocr(makeTimedOCRResult(timestamp: fourteenDaysAgo)).group(relativeTo: referenceDate), .lastWeek)
        XCTAssertEqual(TimelineResult.ocr(makeTimedOCRResult(timestamp: fifteenDaysAgo)).group(relativeTo: referenceDate), .older)
    }

    func test_dateFilterPresets_honorInclusiveCutoffs_andExcludeFutureDates() {
        let calendar = Calendar.current
        let referenceDate = Date(timeIntervalSince1970: 1_700_000_000)
        let sevenDayCutoff = calendar.date(byAdding: .day, value: -7, to: referenceDate)!
        let thirtyDayCutoff = calendar.date(byAdding: .day, value: -30, to: referenceDate)!
        let beforeSevenDayCutoff = calendar.date(byAdding: .second, value: -1, to: sevenDayCutoff)!
        let futureDate = calendar.date(byAdding: .hour, value: 1, to: referenceDate)!

        XCTAssertTrue(DateFilterPreset.last7Days.includes(sevenDayCutoff, relativeTo: referenceDate))
        XCTAssertFalse(DateFilterPreset.last7Days.includes(beforeSevenDayCutoff, relativeTo: referenceDate))
        XCTAssertFalse(DateFilterPreset.last7Days.includes(futureDate, relativeTo: referenceDate))

        XCTAssertTrue(DateFilterPreset.last30Days.includes(thirtyDayCutoff, relativeTo: referenceDate))
        XCTAssertFalse(DateFilterPreset.last30Days.includes(futureDate, relativeTo: referenceDate))
    }

    private func makeTimedOCRResult(timestamp: Date) -> StoredOCRResult {
        let texts = [DetectedText(text: "Timeline", boundingBox: .zero, confidence: 0.9, characterBoxes: [])]
        return StoredOCRResult(detectedTexts: texts, image: testImage, timestamp: timestamp)
    }

    private func makeContourResult(contours: [DetectedContour]) -> StoredContourDetectionResult {
        StoredContourDetectionResult(detectedContours: contours, image: testImage)
    }

    private func makeContour(aspectRatio: Float) -> DetectedContour {
        DetectedContour(
            points: [
                CGPoint(x: 0.1, y: 0.1),
                CGPoint(x: 0.7, y: 0.1),
                CGPoint(x: 0.7, y: 0.5),
                CGPoint(x: 0.1, y: 0.5)
            ],
            boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.6, height: 0.4),
            confidence: 0.84,
            aspectRatio: aspectRatio,
            area: 0.24
        )
    }

    private func makeBarcodeResult(payloads: [(payload: String, symbology: String)]) throws -> StoredBarcodeDetectionResult {
        let fixtures = [
            DetectionResultsTestSupport.StoredBarcodeDetectionResultFixture(
                timestamp: Date(timeIntervalSince1970: 9_999),
                detectedBarcodes: payloads.map { payloadInfo in
                    DetectionResultsTestSupport.StoredDetectedBarcodeFixture(
                        payload: payloadInfo.payload,
                        symbology: payloadInfo.symbology,
                        boundingBox: CGRect(x: 0.2, y: 0.2, width: 0.3, height: 0.3),
                        confidence: 0.9
                    )
                },
                imageData: testImage.jpegData(compressionQuality: 0.7) ?? Data(),
                imageSize: testImage.size,
                thumbnailData: nil
            )
        ]

        let encoded = try JSONEncoder().encode(fixtures)
        return try XCTUnwrap(JSONDecoder().decode([StoredBarcodeDetectionResult].self, from: encoded).first)
    }
}
