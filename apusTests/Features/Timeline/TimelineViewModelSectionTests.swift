//
//  TimelineViewModelSectionTests.swift
//  apusTests
//
//  Created by Codex on 2026/03/30.
//

import XCTest
import Combine
@testable import apus

@MainActor
final class TimelineViewModelSectionTests: TimelineViewModelTestCase {
    func test_sections_arePopulated_whenResultsAdded() async {
        let ocrResult = createOCRResult()

        await MainActor.run {
            resultsManager.ocrResults.append(ocrResult)
            sut.updateSections()
        }

        XCTAssertFalse(sut.sections.isEmpty)
        XCTAssertEqual(sut.sections.first?.results.count, 1)
        XCTAssertEqual(sut.filteredCount, 1)
        XCTAssertFalse(sut.isEmpty)
    }

    func test_sections_groupResultsByDate() async {
        let referenceDate = Date()
        let today = referenceDate
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: referenceDate)!
        let lastWeek = Calendar.current.date(byAdding: .day, value: -8, to: referenceDate)!

        let ocrToday = createOCRResult(timestamp: today)
        let ocrYesterday = createOCRResult(timestamp: yesterday)
        let objLastWeek = createObjectDetectionResult(timestamp: lastWeek)

        await MainActor.run {
            resultsManager.ocrResults.append(ocrToday)
            resultsManager.ocrResults.append(ocrYesterday)
            resultsManager.objectDetectionResults.append(objLastWeek)
            sut.updateSections()
        }

        let todaySection = sut.sections.first { $0.group == .today }
        let yesterdaySection = sut.sections.first { $0.group == .yesterday }
        let lastWeekSection = sut.sections.first { $0.group == .lastWeek }

        XCTAssertNotNil(todaySection)
        XCTAssertNotNil(yesterdaySection)
        XCTAssertNotNil(lastWeekSection)

        XCTAssertEqual(todaySection?.results.count ?? 0, 1)
        XCTAssertEqual(yesterdaySection?.results.count ?? 0, 1)
        XCTAssertEqual(lastWeekSection?.results.count ?? 0, 1)

        let ocrResultsInSections = sut.sections.flatMap { $0.results }.filter { $0.category == .ocr }
        XCTAssertEqual(ocrResultsInSections.count, 2)

        let objectDetectionResultsInSections = sut.sections.flatMap { $0.results }.filter { $0.category == .objectDetection }
        XCTAssertEqual(objectDetectionResultsInSections.count, 1)
    }

    func test_sections_filterByCategory() async {
        await MainActor.run {
            resultsManager.ocrResults.append(createOCRResult())
            resultsManager.objectDetectionResults.append(createObjectDetectionResult())
            sut.updateSections()
        }

        XCTAssertEqual(sut.sections.flatMap { $0.results }.count, 2)

        sut.toggleCategory(.ocr)
        sut.updateSections()

        let ocrResults = sut.sections.flatMap { $0.results }.filter { $0.category == .ocr }
        XCTAssertTrue(ocrResults.isEmpty)

        let objectDetectionResults = sut.sections.flatMap { $0.results }.filter { $0.category == .objectDetection }
        XCTAssertEqual(objectDetectionResults.count, 1)
    }

    func test_sections_multipleResultsInSameGroup() async {
        await MainActor.run {
            resultsManager.ocrResults.append(createOCRResult())
            resultsManager.ocrResults.append(createOCRResult())
            resultsManager.objectDetectionResults.append(createObjectDetectionResult())
            sut.updateSections()
        }

        let todaySection = sut.sections.first { $0.group == .today }
        XCTAssertNotNil(todaySection)
        XCTAssertEqual(todaySection?.results.count, 3)
    }

    func test_sections_empty_whenNoResultsMatchFilters() async {
        await MainActor.run {
            resultsManager.ocrResults.append(createOCRResult())
            sut.updateSections()
        }

        XCTAssertFalse(sut.sections.isEmpty)

        sut.selectedCategories = []
        sut.updateSections()

        let filteredResults = sut.sections.flatMap { $0.results }
        XCTAssertTrue(filteredResults.isEmpty)
    }

    func test_sections_areOrderedByTimelineGroup() async {
        let referenceDate = Date()
        let today = referenceDate
        let lastWeek = Calendar.current.date(byAdding: .day, value: -8, to: referenceDate)!
        let older = Calendar.current.date(byAdding: .day, value: -40, to: referenceDate)!

        await MainActor.run {
            resultsManager.ocrResults = [
                createOCRResult(text: "Today", timestamp: today),
                createOCRResult(text: "Older", timestamp: older)
            ]
            resultsManager.objectDetectionResults = [createObjectDetectionResult(timestamp: lastWeek)]
            sut.updateSections()
        }

        let groups = sut.sections.map(\.group)
        XCTAssertEqual(groups, [.today, .lastWeek, .older])
    }
}
