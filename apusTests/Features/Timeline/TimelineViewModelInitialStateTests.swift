//
//  TimelineViewModelInitialStateTests.swift
//  apusTests
//
//  Created by Codex on 2026/03/30.
//

import XCTest
import Combine
@testable import apus

@MainActor
final class TimelineViewModelInitialStateTests: TimelineViewModelTestCase {
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

    func test_toggleCategory_removesCategory_whenSelected() {
        XCTAssertTrue(sut.selectedCategories.contains(.ocr))

        sut.toggleCategory(.ocr)

        XCTAssertFalse(sut.selectedCategories.contains(.ocr))
    }

    func test_toggleCategory_addsCategory_whenNotSelected() {
        sut.toggleCategory(.ocr)
        XCTAssertFalse(sut.selectedCategories.contains(.ocr))

        sut.toggleCategory(.ocr)

        XCTAssertTrue(sut.selectedCategories.contains(.ocr))
    }

    func test_toggleCategory_doesNotRemoveLastCategory() {
        sut.toggleCategory(.ocr)
        sut.toggleCategory(.objectDetection)
        sut.toggleCategory(.classification)
        sut.toggleCategory(.contourDetection)

        XCTAssertEqual(sut.selectedCategories.count, 1)
        XCTAssertTrue(sut.selectedCategories.contains(.barcode))

        sut.toggleCategory(.barcode)

        XCTAssertEqual(sut.selectedCategories.count, 1)
        XCTAssertTrue(sut.selectedCategories.contains(.barcode))
    }

    func test_toggleCategory_allowsReaddingAfterRemoval() {
        sut.toggleCategory(.ocr)
        sut.toggleCategory(.objectDetection)

        sut.toggleCategory(.ocr)

        XCTAssertTrue(sut.selectedCategories.contains(.ocr))
        XCTAssertFalse(sut.selectedCategories.contains(.objectDetection))
    }

    func test_selectAllCategories_selectsAllCategories() {
        sut.toggleCategory(.ocr)
        sut.toggleCategory(.objectDetection)
        XCTAssertEqual(sut.selectedCategories.count, 3)

        sut.selectAllCategories()

        XCTAssertEqual(sut.selectedCategories.count, DetectionCategory.allCases.count)
    }

    func test_selectAllCategories_isIdempotent() {
        XCTAssertEqual(sut.selectedCategories.count, DetectionCategory.allCases.count)

        sut.selectAllCategories()

        XCTAssertEqual(sut.selectedCategories.count, DetectionCategory.allCases.count)
    }

    func test_clearFilters_resetsCategories() {
        sut.toggleCategory(.ocr)
        sut.toggleCategory(.objectDetection)

        sut.clearFilters()

        XCTAssertEqual(sut.selectedCategories.count, DetectionCategory.allCases.count)
    }

    func test_clearFilters_resetsSearchQuery() {
        sut.searchQuery = "test search"

        sut.clearFilters()

        XCTAssertEqual(sut.searchQuery, "")
    }

    func test_clearFilters_resetsDateFilter() {
        sut.dateFilter = .today

        sut.clearFilters()

        XCTAssertEqual(sut.dateFilter, .all)
    }

    func test_clearFilters_resetsAllFiltersAtOnce() {
        sut.toggleCategory(.ocr)
        sut.searchQuery = "test"
        sut.dateFilter = .last7Days

        sut.clearFilters()

        XCTAssertEqual(sut.selectedCategories.count, DetectionCategory.allCases.count)
        XCTAssertEqual(sut.searchQuery, "")
        XCTAssertEqual(sut.dateFilter, .all)
    }

    func test_hasActiveFilters_returnsTrue_whenCategoryDeselected() {
        sut.toggleCategory(.ocr)

        XCTAssertTrue(sut.hasActiveFilters)
    }

    func test_hasActiveFilters_returnsTrue_whenSearchQuerySet() {
        sut.searchQuery = "test"

        XCTAssertTrue(sut.hasActiveFilters)
    }

    func test_hasActiveFilters_returnsTrue_whenDateFilterChanged() {
        sut.dateFilter = .today

        XCTAssertTrue(sut.hasActiveFilters)
    }

    func test_hasActiveFilters_returnsFalse_whenAllDefault() {
        XCTAssertEqual(sut.selectedCategories.count, DetectionCategory.allCases.count)
        XCTAssertEqual(sut.searchQuery, "")
        XCTAssertEqual(sut.dateFilter, .all)

        XCTAssertFalse(sut.hasActiveFilters)
    }

    func test_hasActiveFilters_returnsFalse_afterClearFilters() {
        sut.toggleCategory(.ocr)
        sut.searchQuery = "test"
        sut.dateFilter = .today
        XCTAssertTrue(sut.hasActiveFilters)

        sut.clearFilters()

        XCTAssertFalse(sut.hasActiveFilters)
    }
}
