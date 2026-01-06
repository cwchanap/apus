//
//  TimelineResultTests.swift
//  apusTests
//
//  Created by Claude Code on 5/1/2026.
//

import XCTest
@testable import apus

final class TimelineResultTests: XCTestCase {

    var testImage: UIImage!

    override func setUpWithError() throws {
        try super.setUpWithError()
        testImage = createTestImage(size: CGSize(width: 400, height: 300))
    }

    override func tearDownWithError() throws {
        testImage = nil
        try super.tearDownWithError()
    }

    // MARK: - TimelineResult.id Tests

    func test_id_returnsUnderlyingResultId_forOCR() {
        // Given
        let ocrResult = createOCRResult()

        // When
        let timelineResult = TimelineResult.ocr(ocrResult)

        // Then
        XCTAssertEqual(timelineResult.id, ocrResult.id)
    }

    func test_id_returnsUnderlyingResultId_forObjectDetection() {
        // Given
        let objResult = createObjectDetectionResult()

        // When
        let timelineResult = TimelineResult.objectDetection(objResult)

        // Then
        XCTAssertEqual(timelineResult.id, objResult.id)
    }

    func test_id_returnsUnderlyingResultId_forClassification() {
        // Given
        let classResult = createClassificationResult()

        // When
        let timelineResult = TimelineResult.classification(classResult)

        // Then
        XCTAssertEqual(timelineResult.id, classResult.id)
    }

    // MARK: - TimelineResult.category Tests

    func test_category_returnsOCR_forOCRResult() {
        let timelineResult = TimelineResult.ocr(createOCRResult())
        XCTAssertEqual(timelineResult.category, .ocr)
    }

    func test_category_returnsObjectDetection_forObjectDetectionResult() {
        let timelineResult = TimelineResult.objectDetection(createObjectDetectionResult())
        XCTAssertEqual(timelineResult.category, .objectDetection)
    }

    func test_category_returnsClassification_forClassificationResult() {
        let timelineResult = TimelineResult.classification(createClassificationResult())
        XCTAssertEqual(timelineResult.category, .classification)
    }

    // MARK: - TimelineResult.previewText Tests

    func test_previewText_returnsText_forOCRResultWithText() {
        // Given
        let texts = [DetectedText(text: "Hello World", boundingBox: .zero, confidence: 0.9, characterBoxes: [])]
        let ocrResult = StoredOCRResult(detectedTexts: texts, image: testImage)

        // When
        let timelineResult = TimelineResult.ocr(ocrResult)

        // Then
        XCTAssertEqual(timelineResult.previewText, "Hello World")
    }

    func test_previewText_truncatesLongText_forOCRResult() {
        // Given
        let longText = String(repeating: "A", count: 100)
        let texts = [DetectedText(text: longText, boundingBox: .zero, confidence: 0.9, characterBoxes: [])]
        let ocrResult = StoredOCRResult(detectedTexts: texts, image: testImage)

        // When
        let timelineResult = TimelineResult.ocr(ocrResult)

        // Then
        XCTAssertEqual(timelineResult.previewText.count, 53) // 50 chars + "..."
        XCTAssertTrue(timelineResult.previewText.hasSuffix("..."))
    }

    func test_previewText_returnsNoTextDetected_forEmptyOCRResult() {
        // Given
        let ocrResult = StoredOCRResult(detectedTexts: [], image: testImage)

        // When
        let timelineResult = TimelineResult.ocr(ocrResult)

        // Then
        XCTAssertEqual(timelineResult.previewText, "No text detected")
    }

    func test_previewText_returnsObjectClasses_forObjectDetectionResult() {
        // Given
        let objects = [
            DetectedObject(boundingBox: .zero, className: "person", confidence: 0.9, framework: .vision),
            DetectedObject(boundingBox: .zero, className: "dog", confidence: 0.8, framework: .vision)
        ]
        let objResult = StoredObjectDetectionResult(detectedObjects: objects, image: testImage)

        // When
        let timelineResult = TimelineResult.objectDetection(objResult)

        // Then
        // uniqueClasses are sorted alphabetically, so "dog" comes before "person"
        XCTAssertTrue(timelineResult.previewText.contains("dog"))
        XCTAssertTrue(timelineResult.previewText.contains("person"))
    }

    func test_previewText_returnsNoObjectsDetected_forEmptyObjectDetectionResult() {
        // Given
        let objResult = StoredObjectDetectionResult(detectedObjects: [], image: testImage)

        // When
        let timelineResult = TimelineResult.objectDetection(objResult)

        // Then
        XCTAssertEqual(timelineResult.previewText, "No objects detected")
    }

    func test_previewText_returnsTopIdentifier_forClassificationResult() {
        // Given
        let classifications = [ClassificationResult(identifier: "golden retriever", confidence: 0.95)]
        let classResult = StoredClassificationResult(classificationResults: classifications, image: testImage)

        // When
        let timelineResult = TimelineResult.classification(classResult)

        // Then
        XCTAssertEqual(timelineResult.previewText, "Golden Retriever")
    }

    func test_previewText_returnsNoClassification_forEmptyClassificationResult() {
        // Given
        let classResult = StoredClassificationResult(classificationResults: [], image: testImage)

        // When
        let timelineResult = TimelineResult.classification(classResult)

        // Then
        XCTAssertEqual(timelineResult.previewText, "No classification")
    }

    // MARK: - TimelineResult.statsText Tests

    func test_statsText_includesTextCountAndConfidence_forOCRResult() {
        // Given
        let texts = [
            DetectedText(text: "Hello", boundingBox: .zero, confidence: 0.9, characterBoxes: []),
            DetectedText(text: "World", boundingBox: .zero, confidence: 0.8, characterBoxes: [])
        ]
        let ocrResult = StoredOCRResult(detectedTexts: texts, image: testImage)

        // When
        let timelineResult = TimelineResult.ocr(ocrResult)

        // Then
        XCTAssertTrue(timelineResult.statsText.contains("2 texts"))
        XCTAssertTrue(timelineResult.statsText.contains("85%")) // average of 90 and 80
    }

    func test_statsText_includesObjectCountAndFramework_forObjectDetectionResult() {
        // Given
        let objects = [
            DetectedObject(boundingBox: .zero, className: "person", confidence: 0.9, framework: .vision)
        ]
        let objResult = StoredObjectDetectionResult(detectedObjects: objects, image: testImage)

        // When
        let timelineResult = TimelineResult.objectDetection(objResult)

        // Then
        XCTAssertTrue(timelineResult.statsText.contains("1 objects"))
        XCTAssertTrue(timelineResult.statsText.contains("Vision"))
    }

    func test_statsText_includesConfidence_forClassificationResult() {
        // Given
        let classifications = [ClassificationResult(identifier: "dog", confidence: 0.92)]
        let classResult = StoredClassificationResult(classificationResults: classifications, image: testImage)

        // When
        let timelineResult = TimelineResult.classification(classResult)

        // Then
        XCTAssertTrue(timelineResult.statsText.contains("92%"))
        XCTAssertTrue(timelineResult.statsText.contains("confidence"))
    }

    func test_statsText_returnsNoResults_forEmptyClassificationResult() {
        // Given
        let classResult = StoredClassificationResult(classificationResults: [], image: testImage)

        // When
        let timelineResult = TimelineResult.classification(classResult)

        // Then
        XCTAssertEqual(timelineResult.statsText, "No results")
    }

    // MARK: - TimelineResult.matchesSearch Tests

    func test_matchesSearch_returnsTrue_forEmptyQuery() {
        // Given
        let timelineResult = TimelineResult.ocr(createOCRResult())

        // When & Then
        XCTAssertTrue(timelineResult.matchesSearch(""))
    }

    func test_matchesSearch_returnsTrue_whenOCRTextContainsQuery() {
        // Given
        let texts = [DetectedText(text: "Hello World", boundingBox: .zero, confidence: 0.9, characterBoxes: [])]
        let ocrResult = StoredOCRResult(detectedTexts: texts, image: testImage)
        let timelineResult = TimelineResult.ocr(ocrResult)

        // When & Then
        XCTAssertTrue(timelineResult.matchesSearch("hello"))
        XCTAssertTrue(timelineResult.matchesSearch("WORLD"))
        XCTAssertTrue(timelineResult.matchesSearch("llo wor"))
    }

    func test_matchesSearch_returnsFalse_whenOCRTextDoesNotContainQuery() {
        // Given
        let texts = [DetectedText(text: "Hello World", boundingBox: .zero, confidence: 0.9, characterBoxes: [])]
        let ocrResult = StoredOCRResult(detectedTexts: texts, image: testImage)
        let timelineResult = TimelineResult.ocr(ocrResult)

        // When & Then
        XCTAssertFalse(timelineResult.matchesSearch("goodbye"))
    }

    func test_matchesSearch_returnsTrue_whenObjectClassContainsQuery() {
        // Given
        let objects = [DetectedObject(boundingBox: .zero, className: "golden retriever", confidence: 0.9, framework: .vision)]
        let objResult = StoredObjectDetectionResult(detectedObjects: objects, image: testImage)
        let timelineResult = TimelineResult.objectDetection(objResult)

        // When & Then
        XCTAssertTrue(timelineResult.matchesSearch("golden"))
        XCTAssertTrue(timelineResult.matchesSearch("RETRIEVER"))
    }

    func test_matchesSearch_returnsFalse_whenObjectClassDoesNotContainQuery() {
        // Given
        let objects = [DetectedObject(boundingBox: .zero, className: "person", confidence: 0.9, framework: .vision)]
        let objResult = StoredObjectDetectionResult(detectedObjects: objects, image: testImage)
        let timelineResult = TimelineResult.objectDetection(objResult)

        // When & Then
        XCTAssertFalse(timelineResult.matchesSearch("cat"))
    }

    func test_matchesSearch_returnsTrue_whenClassificationIdentifierContainsQuery() {
        // Given
        let classifications = [ClassificationResult(identifier: "golden retriever", confidence: 0.95)]
        let classResult = StoredClassificationResult(classificationResults: classifications, image: testImage)
        let timelineResult = TimelineResult.classification(classResult)

        // When & Then
        XCTAssertTrue(timelineResult.matchesSearch("golden"))
    }

    // MARK: - TimelineResult.group Tests

    func test_group_returnsToday_forTodayTimestamp() {
        // Given
        let ocrResult = createOCRResult()
        let timelineResult = TimelineResult.ocr(ocrResult)

        // When
        let group = timelineResult.group()

        // Then
        XCTAssertEqual(group, .today)
    }

    // MARK: - TimelineGroup Tests

    func test_timelineGroup_sortOrderValues() {
        XCTAssertEqual(TimelineGroup.today.sortOrder, 0)
        XCTAssertEqual(TimelineGroup.yesterday.sortOrder, 1)
        XCTAssertEqual(TimelineGroup.thisWeek.sortOrder, 2)
        XCTAssertEqual(TimelineGroup.lastWeek.sortOrder, 3)
        XCTAssertEqual(TimelineGroup.older.sortOrder, 4)
    }

    func test_timelineGroup_allCasesCount() {
        XCTAssertEqual(TimelineGroup.allCases.count, 5)
    }

    func test_timelineGroup_rawValues() {
        XCTAssertEqual(TimelineGroup.today.rawValue, "Today")
        XCTAssertEqual(TimelineGroup.yesterday.rawValue, "Yesterday")
        XCTAssertEqual(TimelineGroup.thisWeek.rawValue, "This Week")
        XCTAssertEqual(TimelineGroup.lastWeek.rawValue, "Last Week")
        XCTAssertEqual(TimelineGroup.older.rawValue, "Older")
    }

    // MARK: - DateFilterPreset Tests

    func test_dateFilterPreset_all_includesAllDates() {
        // Given
        let oldDate = Calendar.current.date(byAdding: .year, value: -10, to: Date())!
        let futureDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!

        // When & Then
        XCTAssertTrue(DateFilterPreset.all.includes(Date()))
        XCTAssertTrue(DateFilterPreset.all.includes(oldDate))
        XCTAssertTrue(DateFilterPreset.all.includes(futureDate))
    }

    func test_dateFilterPreset_today_onlyIncludesToday() {
        // Given
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        // When & Then
        XCTAssertTrue(DateFilterPreset.today.includes(Date()))
        XCTAssertFalse(DateFilterPreset.today.includes(yesterday))
    }

    func test_dateFilterPreset_last7Days_includesRecentDates() {
        // Given
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: Date())!

        // When & Then
        XCTAssertTrue(DateFilterPreset.last7Days.includes(Date()))
        XCTAssertTrue(DateFilterPreset.last7Days.includes(fiveDaysAgo))
        XCTAssertFalse(DateFilterPreset.last7Days.includes(tenDaysAgo))
    }

    func test_dateFilterPreset_last30Days_includesRecentDates() {
        // Given
        let twentyDaysAgo = Calendar.current.date(byAdding: .day, value: -20, to: Date())!
        let fiftyDaysAgo = Calendar.current.date(byAdding: .day, value: -50, to: Date())!

        // When & Then
        XCTAssertTrue(DateFilterPreset.last30Days.includes(Date()))
        XCTAssertTrue(DateFilterPreset.last30Days.includes(twentyDaysAgo))
        XCTAssertFalse(DateFilterPreset.last30Days.includes(fiftyDaysAgo))
    }

    func test_dateFilterPreset_allCasesCount() {
        XCTAssertEqual(DateFilterPreset.allCases.count, 4)
    }

    // MARK: - Helper Methods

    private func createTestImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    private func createOCRResult() -> StoredOCRResult {
        let texts = [DetectedText(text: "Test", boundingBox: .zero, confidence: 0.9, characterBoxes: [])]
        return StoredOCRResult(detectedTexts: texts, image: testImage)
    }

    private func createObjectDetectionResult() -> StoredObjectDetectionResult {
        let objects = [DetectedObject(boundingBox: .zero, className: "person", confidence: 0.9, framework: .vision)]
        return StoredObjectDetectionResult(detectedObjects: objects, image: testImage)
    }

    private func createClassificationResult() -> StoredClassificationResult {
        let classifications = [ClassificationResult(identifier: "dog", confidence: 0.9)]
        return StoredClassificationResult(classificationResults: classifications, image: testImage)
    }
}
