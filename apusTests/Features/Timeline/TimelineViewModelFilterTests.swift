//
//  TimelineViewModelFilterTests.swift
//  apusTests
//
//  Created by Codex on 2026/03/30.
//

import XCTest
import Combine
@testable import apus

@MainActor
final class TimelineViewModelFilterTests: TimelineViewModelTestCase {
    func test_cacheInvalidates_whenResultsAreReplaced() async {
        await MainActor.run {
            resultsManager.ocrResults = [createOCRResult(text: "Initial")]
            sut.searchQuery = "Initial"
            sut.updateSections()
        }

        XCTAssertEqual(sut.filteredCount, 1)

        await MainActor.run {
            resultsManager.ocrResults = [createOCRResult(text: "Updated")]
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

        resultsManager.ocrResults.append(createOCRResult())
        XCTAssertEqual(sut.countForCategory(.ocr), 1)

        resultsManager.ocrResults.append(createOCRResult())
        XCTAssertEqual(sut.countForCategory(.ocr), 2)
    }

    func test_countForCategory_returnsZero_whenNoResults() {
        XCTAssertEqual(sut.countForCategory(.ocr), 0)
        XCTAssertEqual(sut.countForCategory(.objectDetection), 0)
        XCTAssertEqual(sut.countForCategory(.classification), 0)
        XCTAssertEqual(sut.countForCategory(.contourDetection), 0)
        XCTAssertEqual(sut.countForCategory(.barcode), 0)
    }

    func test_countForCategory_returnsCountsAcrossMixedResults() async {
        await MainActor.run {
            resultsManager.ocrResults = [createOCRResult()]
            resultsManager.objectDetectionResults = [createObjectDetectionResult(), createObjectDetectionResult(className: "dog")]
            resultsManager.classificationResults = [createClassificationResult(identifier: "bird")]
        }

        XCTAssertEqual(sut.countForCategory(.ocr), 1)
        XCTAssertEqual(sut.countForCategory(.objectDetection), 2)
        XCTAssertEqual(sut.countForCategory(.classification), 1)
        XCTAssertEqual(sut.countForCategory(.contourDetection), 0)
        XCTAssertEqual(sut.countForCategory(.barcode), 0)
    }

    func test_searchFilter_affectsSections() async {
        await MainActor.run {
            resultsManager.ocrResults.append(createOCRResult())
            sut.updateSections()
        }

        sut.searchQuery = "nonexistent text"

        try? await Task.sleep(nanoseconds: 400_000_000)
        await MainActor.run {
            sut.updateSections()
        }

        XCTAssertTrue(sut.sections.isEmpty)
    }

    func test_searchFilter_matchesObjectDetectionClassNames() async {
        await MainActor.run {
            resultsManager.objectDetectionResults.append(createObjectDetectionResult(className: "person"))
            resultsManager.classificationResults.append(createClassificationResult(identifier: "cat"))
            sut.searchQuery = "per"
            sut.updateSections()
        }

        let filteredResults = sut.sections.flatMap { $0.results }
        XCTAssertEqual(filteredResults.count, 1)
        XCTAssertEqual(filteredResults.first?.category, .objectDetection)
    }

    func test_dateFilter_affectsSections() async {
        await MainActor.run {
            resultsManager.ocrResults.append(createOCRResult())
            sut.updateSections()
        }

        XCTAssertEqual(sut.filteredCount, 1)

        sut.dateFilter = .last7Days

        XCTAssertEqual(sut.filteredCount, 1)
    }

    func test_dateFilter_excludesOlderResults() async {
        let oldDate = Calendar.current.date(byAdding: .day, value: -40, to: Date())!

        await MainActor.run {
            resultsManager.ocrResults = [createOCRResult(timestamp: oldDate)]
            sut.dateFilter = .last7Days
            sut.updateSections()
        }

        XCTAssertEqual(sut.filteredCount, 0)
        XCTAssertTrue(sut.sections.isEmpty)
    }
}
