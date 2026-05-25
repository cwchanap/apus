//
//  ResultsViewCoverageTests.swift
//  apusTests
//
//  Created by Codex on 2026/05/24.
//

import SwiftUI
import XCTest
@testable import apus

@MainActor
final class ResultsViewCoverageTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetStoredState()
    }

    override func tearDown() {
        resetStoredState()
        super.tearDown()
    }

    func testResultsDashboardRendersLoadingEmptyAndPopulatedStates() {
        let loadingManager = DetectionResultFixtures.emptyManager(isLoading: true)
        renderDashboard(with: loadingManager)
        XCTAssertFalse(loadingManager.hasAnyResults)

        let emptyManager = DetectionResultFixtures.emptyManager()
        renderDashboard(with: emptyManager)
        XCTAssertEqual(emptyManager.totalResultsCount, 0)

        let populatedManager = DetectionResultFixtures.populatedManager()
        renderDashboard(with: populatedManager)
        XCTAssertEqual(populatedManager.totalResultsCount, DetectionCategory.allCases.count)
    }

    func testCategoryResultsViewsRenderEveryCategoryWhenEmptyAndPopulated() {
        let emptyManager = DetectionResultFixtures.emptyManager()
        let populatedManager = DetectionResultFixtures.populatedManager()

        for category in DetectionCategory.allCases {
            renderCategory(category, manager: emptyManager)
            XCTAssertEqual(emptyManager.getResultsCount(for: category), 0)

            renderCategory(category, manager: populatedManager)
            XCTAssertEqual(populatedManager.getResultsCount(for: category), 1)
        }
    }

    func testSharedComponentsRenderWithEmptyAndPopulatedCategories() {
        let emptyManager = DetectionResultFixtures.emptyManager()
        let populatedManager = DetectionResultFixtures.populatedManager()

        for category in DetectionCategory.allCases {
            ViewRenderingTestHarness.render(
                EmptyResultsView(
                    category: category,
                    message: "No results",
                    description: "Results for this category are not available."
                )
            )

            ViewRenderingTestHarness.render(
                RecentResultsPreview(resultsManager: emptyManager, category: category)
            )
            XCTAssertEqual(emptyManager.getResultsCount(for: category), 0)

            ViewRenderingTestHarness.render(
                RecentResultsPreview(resultsManager: populatedManager, category: category)
            )
            XCTAssertEqual(populatedManager.getResultsCount(for: category), 1)

            ViewRenderingTestHarness.render(ResultsSummaryCard(category: category, count: 0) {})
            ViewRenderingTestHarness.render(ResultsSummaryCard(category: category, count: 1) {})
            ViewRenderingTestHarness.render(
                StorageInfoRow(
                    label: category.rawValue,
                    count: 0,
                    maxCount: AppSettings.shared.getStorageLimit(for: category),
                    color: category.color
                )
            )
            ViewRenderingTestHarness.render(
                StorageInfoRow(
                    label: category.rawValue,
                    count: 1,
                    maxCount: AppSettings.shared.getStorageLimit(for: category),
                    color: category.color
                )
            )
        }

        ViewRenderingTestHarness.render(StatRow(label: "Stored", value: "5"))
    }

    func testRecentRowsRenderForEveryStoredResultType() {
        let ocrResult = DetectionResultFixtures.ocrResult()
        let objectResult = DetectionResultFixtures.objectResult()
        let classificationResult = DetectionResultFixtures.classificationResult()
        let contourResult = DetectionResultFixtures.contourResult()
        let barcodeResult = DetectionResultFixtures.barcodeResult(
            payloads: [("https://example.com/docs", "QR"), ("9781234567890", "EAN13")]
        )

        ViewRenderingTestHarness.render(RecentOCRRow(result: ocrResult))
        XCTAssertEqual(ocrResult.detectedTexts.count, DetectionResultFixtures.detectedTexts().count)

        ViewRenderingTestHarness.render(RecentObjectDetectionRow(result: objectResult))
        XCTAssertEqual(objectResult.detectedObjects.count, DetectionResultFixtures.detectedObjects().count)

        ViewRenderingTestHarness.render(RecentClassificationRow(result: classificationResult))
        XCTAssertEqual(classificationResult.classificationResults.count, DetectionResultFixtures.classifications().count)

        ViewRenderingTestHarness.render(RecentContourRow(result: contourResult))
        XCTAssertEqual(contourResult.detectedContours.count, DetectionResultFixtures.contours().count)

        ViewRenderingTestHarness.render(RecentBarcodeRow(result: barcodeResult))
        XCTAssertEqual(barcodeResult.detectedBarcodes.count, 2)
    }

    func testOCRRowsAndDetailViewsRender() {
        let result = DetectionResultFixtures.ocrResult()
        var tappedRow = false

        ViewRenderingTestHarness.render(OCRResultRow(result: result) { tappedRow = true })
        XCTAssertFalse(tappedRow)
        XCTAssertEqual(result.detectedTexts.count, DetectionResultFixtures.detectedTexts().count)

        ViewRenderingTestHarness.render(
            OCRResultDetailView(
                result: result,
                selectedDetent: .constant(.medium),
                onReset: {}
            )
        )

        guard let detectedText = result.detectedTexts.first else {
            XCTFail("OCR fixture should include detected text.")
            return
        }

        ViewRenderingTestHarness.render(DetectedTextRow(detectedText: detectedText))
        XCTAssertEqual(result.detectedTexts.count, 2)
    }

    func testObjectDetectionRowsAndDetailViewsRender() {
        let result = DetectionResultFixtures.objectResult()
        var tappedRow = false

        ViewRenderingTestHarness.render(ObjectDetectionResultRow(result: result) { tappedRow = true })
        XCTAssertFalse(tappedRow)
        XCTAssertEqual(result.detectedObjects.count, DetectionResultFixtures.detectedObjects().count)

        ViewRenderingTestHarness.render(
            ObjectDetectionResultDetailView(
                result: result,
                selectedDetent: .constant(.fraction(0.9)),
                onReset: {}
            )
        )

        guard let detectedObject = result.detectedObjects.first else {
            XCTFail("Object detection fixture should include detected objects.")
            return
        }

        ViewRenderingTestHarness.render(DetectedObjectRow(detectedObject: detectedObject))
        XCTAssertEqual(result.detectedObjects.count, 2)
    }

    func testClassificationRowsDetailAndChartRender() {
        let result = DetectionResultFixtures.classificationResult()
        var tappedRow = false

        ViewRenderingTestHarness.render(ClassificationResultRow(result: result) { tappedRow = true })
        XCTAssertFalse(tappedRow)
        XCTAssertEqual(result.classificationResults.count, DetectionResultFixtures.classifications().count)

        ViewRenderingTestHarness.render(
            ClassificationResultDetailView(
                result: result,
                selectedDetent: .constant(.medium),
                onReset: {}
            )
        )

        guard let topClassification = result.classificationResults.first else {
            XCTFail("Classification fixture should include classification results.")
            return
        }

        ViewRenderingTestHarness.render(
            ClassificationRow(classification: topClassification, rank: 1, isTopResult: true)
        )
        ViewRenderingTestHarness.render(ConfidenceChartView(results: result.classificationResults))
        XCTAssertEqual(result.classificationResults.count, 3)
    }

    func testBarcodeRowsDetailAndCardRender() {
        let barcodeManager = BarcodeDetectionManager()
        let result = DetectionResultFixtures.barcodeResult(
            payloads: [("https://example.com/docs", "QR"), ("9781234567890", "EAN13")]
        )
        var tappedRow = false

        ViewRenderingTestHarness.render(
            BarcodeResultRow(result: result, barcodeManager: barcodeManager) { tappedRow = true }
        )
        XCTAssertFalse(tappedRow)
        XCTAssertEqual(result.detectedBarcodes.count, 2)

        ViewRenderingTestHarness.render(
            BarcodeResultDetailView(result: result, barcodeManager: barcodeManager)
        )

        guard let barcode = result.detectedBarcodes.first else {
            XCTFail("Barcode fixture should include detected barcodes.")
            return
        }

        ViewRenderingTestHarness.render(
            BarcodeDetailCard(barcode: barcode, index: 1, barcodeManager: barcodeManager)
        )
        XCTAssertEqual(result.detectedBarcodes.count, 2)
    }
}

private extension ResultsViewCoverageTests {
    func resetStoredState() {
        AppSettings.shared.resetToDefaults()
        _ = DetectionResultFixtures.emptyManager()
    }

    func renderDashboard(with manager: DetectionResultsManager) {
        ViewRenderingTestHarness.render(
            NavigationStack {
                ResultsDashboardView(path: .constant([]))
                    .environmentObject(manager)
            }
        )
    }

    func renderCategory(_ category: DetectionCategory, manager: DetectionResultsManager) {
        ViewRenderingTestHarness.render(
            NavigationStack {
                CategoryResultsView(category: category)
                    .environmentObject(manager)
            }
        )
    }
}
