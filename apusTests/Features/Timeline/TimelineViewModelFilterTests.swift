//
//  TimelineViewModelFilterTests.swift
//  apusTests
//
//  Created by Codex on 2026/03/29.
//

import XCTest
@testable import apus

extension TimelineViewModelTests {
    // MARK: - Cache Invalidation Tests

    func test_cacheInvalidates_whenResultsAreReplaced() async {
        await MainActor.run {
            mockResultsManager.ocrResults = [createOCRResult(text: "Initial")]
            sut.searchQuery = "Initial"
            sut.updateSections()
        }

        XCTAssertEqual(sut.filteredCount, 1)

        await MainActor.run {
            mockResultsManager.ocrResults = [createOCRResult(text: "Updated")]
            sut.searchQuery = "Updated"
            sut.updateSections()
        }

        XCTAssertEqual(sut.filteredCount, 1)
        XCTAssertEqual(sut.sections.flatMap { $0.results }.first?.previewText, "Updated")

        await MainActor.run {
            sut.searchQuery = "Initial"
            sut.updateSections()
        }

        XCTAssertEqual(sut.filteredCount, 0)
    }

    func test_cacheInvalidates_onCountChanges() {
        XCTAssertEqual(sut.countForCategory(.ocr), 0)

        mockResultsManager.ocrResults.append(createOCRResult())
        XCTAssertEqual(sut.countForCategory(.ocr), 1)

        mockResultsManager.ocrResults.append(createOCRResult())
        XCTAssertEqual(sut.countForCategory(.ocr), 2)
    }

    // MARK: - Count For Category Tests

    func test_countForCategory_returnsZero_whenNoResults() {
        XCTAssertEqual(sut.countForCategory(.ocr), 0)
        XCTAssertEqual(sut.countForCategory(.objectDetection), 0)
        XCTAssertEqual(sut.countForCategory(.classification), 0)
        XCTAssertEqual(sut.countForCategory(.contourDetection), 0)
        XCTAssertEqual(sut.countForCategory(.barcode), 0)
    }

    func test_countForCategory_returnsCountsAcrossMixedResults() async {
        await MainActor.run {
            mockResultsManager.ocrResults = [createOCRResult()]
            mockResultsManager.objectDetectionResults = [createObjectDetectionResult(), createObjectDetectionResult(className: "dog")]
            mockResultsManager.classificationResults = [createClassificationResult(identifier: "bird")]
        }

        XCTAssertEqual(sut.countForCategory(.ocr), 1)
        XCTAssertEqual(sut.countForCategory(.objectDetection), 2)
        XCTAssertEqual(sut.countForCategory(.classification), 1)
        XCTAssertEqual(sut.countForCategory(.contourDetection), 0)
        XCTAssertEqual(sut.countForCategory(.barcode), 0)
    }

    func test_searchFilter_matchesObjectDetectionClassNames() async {
        await MainActor.run {
            mockResultsManager.objectDetectionResults.append(createObjectDetectionResult(className: "person"))
            mockResultsManager.classificationResults.append(createClassificationResult(identifier: "cat"))
            sut.searchQuery = "per"
            sut.updateSections()
        }

        let filteredResults = sut.sections.flatMap { $0.results }
        XCTAssertEqual(filteredResults.count, 1)
        XCTAssertEqual(filteredResults.first?.category, .objectDetection)
    }

    func test_dateFilter_excludesOlderResults() async {
        let oldDate = Calendar.current.date(byAdding: .day, value: -40, to: Date())!

        await MainActor.run {
            mockResultsManager.ocrResults = [createOCRResult(timestamp: oldDate)]
            sut.dateFilter = .last7Days
            sut.updateSections()
        }

        XCTAssertEqual(sut.filteredCount, 0)
        XCTAssertTrue(sut.sections.isEmpty)
    }

    func test_sections_areOrderedByTimelineGroup() async {
        let referenceDate = Date()
        let today = referenceDate
        let lastWeek = Calendar.current.date(byAdding: .day, value: -8, to: referenceDate)!
        let older = Calendar.current.date(byAdding: .day, value: -40, to: referenceDate)!

        await MainActor.run {
            mockResultsManager.ocrResults = [
                createOCRResult(text: "Today", timestamp: today),
                createOCRResult(text: "Older", timestamp: older)
            ]
            mockResultsManager.objectDetectionResults = [createObjectDetectionResult(timestamp: lastWeek)]
            sut.updateSections()
        }

        let groups = sut.sections.map(\.group)
        XCTAssertEqual(groups, [.today, .lastWeek, .older])
    }

    // MARK: - Helpers

    func createTestImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    func createOCRResult(text: String = "Test", timestamp: Date = Date()) -> StoredOCRResult {
        let texts = [DetectedText(text: text, boundingBox: .zero, confidence: 0.9, characterBoxes: [])]
        return StoredOCRResult(detectedTexts: texts, image: testImage, timestamp: timestamp)
    }

    func createObjectDetectionResult(className: String = "person", timestamp: Date = Date()) -> StoredObjectDetectionResult {
        let objects = [DetectedObject(boundingBox: .zero, className: className, confidence: 0.9, framework: .vision)]
        return StoredObjectDetectionResult(detectedObjects: objects, image: testImage, timestamp: timestamp)
    }

    func createClassificationResult(identifier: String = "dog") -> StoredClassificationResult {
        let classifications = [ClassificationResult(identifier: identifier, confidence: 0.9)]
        return StoredClassificationResult(classificationResults: classifications, image: testImage)
    }
}
