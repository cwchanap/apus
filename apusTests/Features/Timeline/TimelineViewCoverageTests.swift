//
//  TimelineViewCoverageTests.swift
//  apusTests
//
//  Created by Codex on 2026/05/25.
//

import SwiftUI
import XCTest
@testable import apus

@MainActor
final class TimelineViewCoverageTests: XCTestCase {
    override func setUp() {
        super.setUp()
        AppDependencies.shared.configureForTesting()
        resetResolvedResultsManager()
    }

    override func tearDown() {
        resetResolvedResultsManager()
        super.tearDown()
    }

    func testTimelineViewRendersInNavigationStack() {
        let manager = resolvedResultsManager()
        populate(manager)
        let viewModel = TimelineViewModel(resultsManager: manager)

        ViewRenderingTestHarness.render(
            NavigationStack {
                TimelineView()
            }
        )

        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertEqual(viewModel.filteredCount, DetectionCategory.allCases.count)
        XCTAssertEqual(manager.totalResultsCount, DetectionCategory.allCases.count)
    }

    func testTimelineFilterControlsRenderWithPopulatedViewModel() {
        let manager = DetectionResultFixtures.populatedManager()
        let viewModel = TimelineViewModel(resultsManager: manager)
        var searchQuery = "receipt"
        var selectedPreset = DateFilterPreset.last7Days
        let searchBinding = Binding<String>(
            get: { searchQuery },
            set: { searchQuery = $0 }
        )
        let presetBinding = Binding<DateFilterPreset>(
            get: { selectedPreset },
            set: { selectedPreset = $0 }
        )

        ViewRenderingTestHarness.render(TimelineFilterBar(viewModel: viewModel))
        ViewRenderingTestHarness.render(TimelineSearchBar(searchQuery: searchBinding))
        ViewRenderingTestHarness.render(TimelineCategoryFilters(viewModel: viewModel))
        ViewRenderingTestHarness.render(TimelineDatePresets(selectedPreset: presetBinding))

        XCTAssertEqual(viewModel.countForCategory(.ocr), 1)
        XCTAssertEqual(viewModel.countForCategory(.objectDetection), 1)
        XCTAssertEqual(viewModel.countForCategory(.classification), 1)
        XCTAssertEqual(viewModel.countForCategory(.contourDetection), 1)
        XCTAssertEqual(viewModel.countForCategory(.barcode), 1)
        XCTAssertEqual(searchQuery, "receipt")
        XCTAssertEqual(selectedPreset, .last7Days)
    }

    func testTimelineRowsHeadersEmptyStatesAndChipsRender() {
        let results = timelineResults()
        var clearFiltersWasCalled = false
        var categoryChipWasTapped = false
        var dateChipWasTapped = false

        for result in results {
            ViewRenderingTestHarness.render(TimelineRowView(result: result))
            XCTAssertTrue(DetectionCategory.allCases.contains(result.category))
        }

        ViewRenderingTestHarness.render(TimelineSectionHeader(title: TimelineGroup.today.rawValue))
        ViewRenderingTestHarness.render(EmptyTimelineView(hasFilters: false) {})
        ViewRenderingTestHarness.render(EmptyTimelineView(hasFilters: true) {
            clearFiltersWasCalled = true
        })
        ViewRenderingTestHarness.render(
            CategoryFilterChip(category: .ocr, isSelected: true, count: 1) {
                categoryChipWasTapped = true
            }
        )
        ViewRenderingTestHarness.render(
            CategoryFilterChip(category: .barcode, isSelected: false, count: 0) {
                categoryChipWasTapped = true
            }
        )
        ViewRenderingTestHarness.render(
            DatePresetChip(preset: .all, isSelected: true) {
                dateChipWasTapped = true
            }
        )
        ViewRenderingTestHarness.render(
            DatePresetChip(preset: .today, isSelected: false) {
                dateChipWasTapped = true
            }
        )

        XCTAssertEqual(results.map(\.category), DetectionCategory.allCases)
        XCTAssertFalse(clearFiltersWasCalled)
        XCTAssertFalse(categoryChipWasTapped)
        XCTAssertFalse(dateChipWasTapped)
    }

    func testTimelineDetailSheetRendersEveryTimelineResultCase() {
        let results = timelineResults()

        for result in results {
            ViewRenderingTestHarness.render(TimelineDetailSheet(result: result))
        }

        XCTAssertEqual(results.count, DetectionCategory.allCases.count)
        XCTAssertEqual(Set(results.map(\.category)), Set(DetectionCategory.allCases))
    }
}

private extension TimelineViewCoverageTests {
    func resolvedResultsManager() -> DetectionResultsManager {
        DIContainer.shared.resolve(DetectionResultsManager.self)
    }

    func resetResolvedResultsManager() {
        let manager = resolvedResultsManager()
        waitUntilLoaded(manager)
        DetectionResultFixtures.reset(manager)
    }

    func populate(_ manager: DetectionResultsManager) {
        waitUntilLoaded(manager)
        DetectionResultFixtures.reset(manager)
        manager.ocrResults = [DetectionResultFixtures.ocrResult()]
        manager.objectDetectionResults = [DetectionResultFixtures.objectResult()]
        manager.classificationResults = [DetectionResultFixtures.classificationResult()]
        manager.contourResults = [DetectionResultFixtures.contourResult()]
        manager.barcodeResults = [
            DetectionResultFixtures.barcodeResult(
                payloads: [("https://example.com/docs", "QR"), ("9781234567890", "EAN13")]
            )
        ]
        manager.updateCachedValues()
    }

    func waitUntilLoaded(_ manager: DetectionResultsManager, timeout: TimeInterval = 1.0) {
        let deadline = Date().addingTimeInterval(timeout)
        while manager.isLoading && Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }
    }

    func timelineResults() -> [TimelineResult] {
        [
            .ocr(DetectionResultFixtures.ocrResult()),
            .objectDetection(DetectionResultFixtures.objectResult()),
            .classification(DetectionResultFixtures.classificationResult()),
            .contour(DetectionResultFixtures.contourResult()),
            .barcode(
                DetectionResultFixtures.barcodeResult(
                    payloads: [("https://example.com/docs", "QR"), ("9781234567890", "EAN13")]
                )
            )
        ]
    }
}
