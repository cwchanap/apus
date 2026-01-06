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

    // MARK: - Count For Category Tests (with empty manager)

    func test_countForCategory_returnsZero_whenNoResults() {
        XCTAssertEqual(sut.countForCategory(.ocr), 0)
        XCTAssertEqual(sut.countForCategory(.objectDetection), 0)
        XCTAssertEqual(sut.countForCategory(.classification), 0)
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
