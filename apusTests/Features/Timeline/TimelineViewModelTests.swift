//
//  TimelineViewModelTests.swift
//  apusTests
//
//  Created by Claude Code on 5/1/2026.
//

import XCTest
import Combine
@testable import apus

@MainActor
final class TimelineViewModelTests: XCTestCase {

    var sut: TimelineViewModel!
    var mockResultsManager: DetectionResultsManager!
    var testImage: UIImage!
    var cancellables: Set<AnyCancellable>!

    override func setUp() async throws {
        try await super.setUp()
        testImage = createTestImage(size: CGSize(width: 100, height: 100))
        mockResultsManager = DetectionResultsManager()
        sut = TimelineViewModel(resultsManager: mockResultsManager)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() async throws {
        sut = nil
        mockResultsManager = nil
        testImage = nil
        cancellables = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func test_initialState_hasAllCategoriesSelected() {
        XCTAssertEqual(sut.selectedCategories.count, DetectionCategory.allCases.count)
        XCTAssertTrue(sut.selectedCategories.contains(.ocr))
        XCTAssertTrue(sut.selectedCategories.contains(.objectDetection))
        XCTAssertTrue(sut.selectedCategories.contains(.classification))
        XCTAssertTrue(sut.selectedCategories.contains(.contourDetection))
        XCTAssertTrue(sut.selectedCategories.contains(.barcode))
    }

    func test_initialState_hasEmptySearchQuery() {
        XCTAssertEqual(sut.searchQuery, "")
    }

    func test_initialState_hasAllDateFilter() {
        XCTAssertEqual(sut.dateFilter, .all)
    }

    func test_initialState_hasNoActiveFilters() {
        XCTAssertFalse(sut.hasActiveFilters)
    }

    func test_initialState_isEmpty_whenNoResults() {
        XCTAssertTrue(sut.isEmpty)
    }

    func test_initialState_hasZeroFilteredCount_whenNoResults() {
        XCTAssertEqual(sut.filteredCount, 0)
    }

    func test_initialState_hasEmptySections() {
        XCTAssertTrue(sut.sections.isEmpty)
    }

    // MARK: - Category Toggle Tests

    func test_toggleCategory_removesCategory_whenSelected() {
        // Given
        XCTAssertTrue(sut.selectedCategories.contains(.ocr))

        // When
        sut.toggleCategory(.ocr)

        // Then
        XCTAssertFalse(sut.selectedCategories.contains(.ocr))
    }

    func test_toggleCategory_addsCategory_whenNotSelected() {
        // Given
        sut.toggleCategory(.ocr) // Remove first
        XCTAssertFalse(sut.selectedCategories.contains(.ocr))

        // When
        sut.toggleCategory(.ocr)

        // Then
        XCTAssertTrue(sut.selectedCategories.contains(.ocr))
    }

    func test_toggleCategory_doesNotRemoveLastCategory() {
        // Given - Remove all but one category
        sut.toggleCategory(.ocr)
        sut.toggleCategory(.objectDetection)
        sut.toggleCategory(.classification)
        sut.toggleCategory(.contourDetection)
        // Only .barcode remains

        XCTAssertEqual(sut.selectedCategories.count, 1)
        XCTAssertTrue(sut.selectedCategories.contains(.barcode))

        // When - Try to remove the last one
        sut.toggleCategory(.barcode)

        // Then - Should still have one category
        XCTAssertEqual(sut.selectedCategories.count, 1)
        XCTAssertTrue(sut.selectedCategories.contains(.barcode))
    }

    func test_toggleCategory_allowsReaddingAfterRemoval() {
        // Given
        sut.toggleCategory(.ocr) // Remove
        sut.toggleCategory(.objectDetection) // Remove

        // When
        sut.toggleCategory(.ocr) // Re-add

        // Then
        XCTAssertTrue(sut.selectedCategories.contains(.ocr))
        XCTAssertFalse(sut.selectedCategories.contains(.objectDetection))
    }

    // MARK: - Select All Categories Tests

    func test_selectAllCategories_selectsAllCategories() {
        // Given
        sut.toggleCategory(.ocr)
        sut.toggleCategory(.objectDetection)
        XCTAssertEqual(sut.selectedCategories.count, 3)

        // When
        sut.selectAllCategories()

        // Then
        XCTAssertEqual(sut.selectedCategories.count, DetectionCategory.allCases.count)
    }

    func test_selectAllCategories_isIdempotent() {
        // Given - already all selected
        XCTAssertEqual(sut.selectedCategories.count, DetectionCategory.allCases.count)

        // When
        sut.selectAllCategories()

        // Then
        XCTAssertEqual(sut.selectedCategories.count, DetectionCategory.allCases.count)
    }

    // MARK: - Clear Filters Tests

    func test_clearFilters_resetsCategories() {
        // Given
        sut.toggleCategory(.ocr)
        sut.toggleCategory(.objectDetection)

        // When
        sut.clearFilters()

        // Then
        XCTAssertEqual(sut.selectedCategories.count, DetectionCategory.allCases.count)
    }

    func test_clearFilters_resetsSearchQuery() {
        // Given
        sut.searchQuery = "test search"

        // When
        sut.clearFilters()

        // Then
        XCTAssertEqual(sut.searchQuery, "")
    }

    func test_clearFilters_resetsDateFilter() {
        // Given
        sut.dateFilter = .today

        // When
        sut.clearFilters()

        // Then
        XCTAssertEqual(sut.dateFilter, .all)
    }

    func test_clearFilters_resetsAllFiltersAtOnce() {
        // Given
        sut.toggleCategory(.ocr)
        sut.searchQuery = "test"
        sut.dateFilter = .last7Days

        // When
        sut.clearFilters()

        // Then
        XCTAssertEqual(sut.selectedCategories.count, DetectionCategory.allCases.count)
        XCTAssertEqual(sut.searchQuery, "")
        XCTAssertEqual(sut.dateFilter, .all)
    }

    // MARK: - Has Active Filters Tests

    func test_hasActiveFilters_returnsTrue_whenCategoryDeselected() {
        // When
        sut.toggleCategory(.ocr)

        // Then
        XCTAssertTrue(sut.hasActiveFilters)
    }

    func test_hasActiveFilters_returnsTrue_whenSearchQuerySet() {
        // When
        sut.searchQuery = "test"

        // Then
        XCTAssertTrue(sut.hasActiveFilters)
    }

    func test_hasActiveFilters_returnsTrue_whenDateFilterChanged() {
        // When
        sut.dateFilter = .today

        // Then
        XCTAssertTrue(sut.hasActiveFilters)
    }

    func test_hasActiveFilters_returnsFalse_whenAllDefault() {
        // Given - all defaults
        XCTAssertEqual(sut.selectedCategories.count, DetectionCategory.allCases.count)
        XCTAssertEqual(sut.searchQuery, "")
        XCTAssertEqual(sut.dateFilter, .all)

        // Then
        XCTAssertFalse(sut.hasActiveFilters)
    }

    func test_hasActiveFilters_returnsFalse_afterClearFilters() {
        // Given
        sut.toggleCategory(.ocr)
        sut.searchQuery = "test"
        sut.dateFilter = .today
        XCTAssertTrue(sut.hasActiveFilters)

        // When
        sut.clearFilters()

        // Then
        XCTAssertFalse(sut.hasActiveFilters)
    }

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

    // MARK: - Count For Category Tests (with empty manager)

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

    // MARK: - Helper Methods

    private func createTestImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    private func createOCRResult(text: String = "Test", timestamp: Date = Date()) -> StoredOCRResult {
        let texts = [DetectedText(text: text, boundingBox: .zero, confidence: 0.9, characterBoxes: [])]
        return StoredOCRResult(detectedTexts: texts, image: testImage, timestamp: timestamp)
    }

    private func createObjectDetectionResult(className: String = "person", timestamp: Date = Date()) -> StoredObjectDetectionResult {
        let objects = [DetectedObject(boundingBox: .zero, className: className, confidence: 0.9, framework: .vision)]
        return StoredObjectDetectionResult(detectedObjects: objects, image: testImage, timestamp: timestamp)
    }

    private func createClassificationResult(identifier: String = "dog") -> StoredClassificationResult {
        let classifications = [ClassificationResult(identifier: identifier, confidence: 0.9)]
        return StoredClassificationResult(classificationResults: classifications, image: testImage)
    }

    // MARK: - Section Grouping Integration Tests

    func test_sections_arePopulated_whenResultsAdded() async {
        // Given
        let ocrResult = createOCRResult()

        // When - Add result directly to manager's published array
        await MainActor.run {
            mockResultsManager.ocrResults.append(ocrResult)
            // Manually trigger section update since Combine subscription may have timing issues in tests
            sut.updateSections()
        }

        // Then
        XCTAssertFalse(sut.sections.isEmpty, "Sections should not be empty after adding results")
        XCTAssertEqual(sut.sections.first?.results.count, 1, "First section should have 1 result")
        XCTAssertEqual(sut.filteredCount, 1, "Filtered count should be 1")
        XCTAssertFalse(sut.isEmpty, "isEmpty should be false when results exist")
    }

    func test_sections_groupResultsByDate() async {
        // Given - Use a fixed reference date to avoid edge cases near midnight
        let referenceDate = Date()
        let today = referenceDate
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: referenceDate)!
        let lastWeek = Calendar.current.date(byAdding: .day, value: -8, to: referenceDate)!

        // Create results with specific timestamps for proper date grouping
        let ocrToday = createOCRResult(timestamp: today)
        let ocrYesterday = createOCRResult(timestamp: yesterday)
        let objLastWeek = createObjectDetectionResult(timestamp: lastWeek)

        // When - Add results
        await MainActor.run {
            mockResultsManager.ocrResults.append(ocrToday)
            mockResultsManager.ocrResults.append(ocrYesterday)
            mockResultsManager.objectDetectionResults.append(objLastWeek)

            // Manually trigger section update since Combine subscription may have timing issues in tests
            sut.updateSections()
        }

        // Then - Results should be grouped by date
        let todaySection = sut.sections.first { $0.group == .today }
        let yesterdaySection = sut.sections.first { $0.group == .yesterday }
        let lastWeekSection = sut.sections.first { $0.group == .lastWeek }

        XCTAssertNotNil(todaySection, "Today section should exist when result has today's timestamp")
        XCTAssertNotNil(yesterdaySection, "Yesterday section should exist when result has yesterday's timestamp")
        XCTAssertNotNil(lastWeekSection, "Last week section should exist when result has last week's timestamp")

        XCTAssertEqual(todaySection?.results.count ?? 0, 1, "Today should have 1 result (OCR)")
        XCTAssertEqual(yesterdaySection?.results.count ?? 0, 1, "Yesterday should have 1 result (OCR)")
        XCTAssertEqual(lastWeekSection?.results.count ?? 0, 1, "Last week should have 1 result (Object Detection)")

        // Verify results are correctly categorized by type
        let ocrResultsInSections = sut.sections.flatMap { $0.results }.filter { $0.category == .ocr }
        XCTAssertEqual(ocrResultsInSections.count, 2, "Should have 2 OCR results across all sections")

        let objResultsInSections = sut.sections.flatMap { $0.results }.filter { $0.category == .objectDetection }
        XCTAssertEqual(objResultsInSections.count, 1, "Should have 1 object detection result")
    }

    func test_sections_filterByCategory() async {
        // Given - Add results from different categories
        await MainActor.run {
            mockResultsManager.ocrResults.append(createOCRResult())
            mockResultsManager.objectDetectionResults.append(createObjectDetectionResult())
            // Manually trigger section update since Combine subscription may have timing issues in tests
            sut.updateSections()
        }

        // Initially both should be visible
        XCTAssertEqual(sut.sections.flatMap { $0.results }.count, 2, "Both categories should be visible")

        // When - Filter out OCR
        sut.toggleCategory(.ocr)
        // Manually trigger section update after filter change
        sut.updateSections()

        // Then - Only object detection should remain
        let ocrResults = sut.sections.flatMap { $0.results }.filter { $0.category == .ocr }
        XCTAssertTrue(ocrResults.isEmpty, "OCR results should not appear when OCR is filtered out")

        let objectDetectionResults = sut.sections.flatMap { $0.results }.filter { $0.category == .objectDetection }
        XCTAssertEqual(objectDetectionResults.count, 1, "Object detection result should still be visible")
    }

    func test_sections_multipleResultsInSameGroup() async {
        // Given - Add multiple OCR results
        await MainActor.run {
            mockResultsManager.ocrResults.append(createOCRResult())
            mockResultsManager.ocrResults.append(createOCRResult())
            mockResultsManager.objectDetectionResults.append(createObjectDetectionResult())
            // Manually trigger section update since Combine subscription may have timing issues in tests
            sut.updateSections()
        }

        // Then - All results should be in Today section (all created today)
        let todaySection = sut.sections.first { $0.group == .today }
        XCTAssertNotNil(todaySection, "Today section should exist")
        XCTAssertEqual(todaySection?.results.count, 3, "Today should have all 3 results")
    }

    func test_sections_empty_whenNoResultsMatchFilters() async {
        // Given
        await MainActor.run {
            mockResultsManager.ocrResults.append(createOCRResult())
            // Manually trigger section update since Combine subscription may have timing issues in tests
            sut.updateSections()
        }

        XCTAssertFalse(sut.sections.isEmpty, "Sections should have results")

        // When - Filter out all categories by explicitly clearing selected categories
        sut.selectedCategories = []

        // Manually trigger section update after filter change
        sut.updateSections()

        // Then - Results should be empty due to filtering
        let filteredResults = sut.sections.flatMap { $0.results }
        XCTAssertTrue(filteredResults.isEmpty, "Results should be empty when no categories selected")
    }

    func test_searchFilter_affectsSections() async {
        // Given
        await MainActor.run {
            mockResultsManager.ocrResults.append(createOCRResult())
            // Manually trigger section update since Combine subscription may have timing issues in tests
            sut.updateSections()
        }

        // When - Apply search filter that won't match
        sut.searchQuery = "nonexistent text"

        // Allow debounce (300ms) - but also manually update since Combine has timing issues
        try? await Task.sleep(nanoseconds: 400_000_000)
        await MainActor.run {
            sut.updateSections()
        }

        // Then
        XCTAssertTrue(sut.sections.isEmpty, "Sections should be empty when search doesn't match")
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

    func test_dateFilter_affectsSections() async {
        // Given - Add OCR results
        await MainActor.run {
            mockResultsManager.ocrResults.append(createOCRResult())
            // Manually trigger section update since Combine subscription may have timing issues in tests
            sut.updateSections()
        }

        // Initially should have 1 result
        XCTAssertEqual(sut.filteredCount, 1, "Should have 1 result initially")

        // When - Filter to last 7 days (should still include today's result)
        sut.dateFilter = .last7Days

        // Then - Result should still be visible
        XCTAssertEqual(sut.filteredCount, 1, "Should have 1 result when filtered to last 7 days")
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
}
