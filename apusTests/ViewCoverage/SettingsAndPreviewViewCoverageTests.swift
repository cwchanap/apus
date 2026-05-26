//
//  SettingsAndPreviewViewCoverageTests.swift
//  apusTests
//
//  Created by Codex on 2026/05/25.
//

import SwiftUI
import UIKit
import Vision
import XCTest
@testable import apus

@MainActor
final class SettingsAndPreviewViewCoverageTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetStoredState()
    }

    override func tearDown() {
        resetStoredState()
        super.tearDown()
    }

    func testSettingsViewsAndStorageLimitRowsRender() {
        let viewModel = SettingsViewModel()

        AppSettings.shared.objectDetectionFramework = .coreML
        ViewRenderingTestHarness.render(SettingsView(), settleDuration: 0.2)
        ViewRenderingTestHarness.render(StorageLimitsSettingsView())

        for (offset, category) in DetectionCategory.allCases.enumerated() {
            let limit = 5 + offset
            viewModel.setStorageLimit(for: category, limit: limit)

            ViewRenderingTestHarness.render(
                StorageLimitRowView(category: category, viewModel: viewModel)
            )

            XCTAssertEqual(viewModel.getStorageLimit(for: category), limit)
        }
    }

    func testPreviewViewRendersWithNilAndNonNilImageBindings() {
        ViewRenderingTestHarness.render(
            NavigationStack {
                PreviewView(capturedImage: .constant(nil))
            }
        )

        ViewRenderingTestHarness.render(
            NavigationStack {
                PreviewView(capturedImage: .constant(DetectionResultFixtures.image()))
            }
        )
    }

    func testObjectAndTextAndContourOverlaysRenderWithDetections() {
        let imageSize = CGSize(width: 400, height: 300)
        let displaySize = CGSize(width: 320, height: 240)
        let detectedObjects = DetectionResultFixtures.detectedObjects()
        let detectedTexts = DetectionResultFixtures.detectedTexts()
        let detectedContours = DetectionResultFixtures.contours()
        let cameraDetections = detectedObjects.map {
            Detection(
                boundingBox: $0.boundingBox,
                className: $0.className,
                confidence: $0.confidence
            )
        }

        ViewRenderingTestHarness.render(
            ObjectDetectionOverlay(detections: cameraDetections)
                .frame(width: displaySize.width, height: displaySize.height),
            size: displaySize
        )
        ViewRenderingTestHarness.render(
            UnifiedObjectDetectionOverlay(
                detections: detectedObjects,
                imageSize: imageSize,
                displaySize: displaySize
            )
            .frame(width: displaySize.width, height: displaySize.height),
            size: displaySize
        )
        ViewRenderingTestHarness.render(
            VisionTextRecognitionOverlay(
                detectedTexts: detectedTexts,
                imageSize: imageSize,
                displaySize: displaySize
            )
            .frame(width: displaySize.width, height: displaySize.height),
            size: displaySize
        )
        ViewRenderingTestHarness.render(
            ContourOverlayView(
                contours: detectedContours,
                imageSize: imageSize,
                displaySize: displaySize
            )
            .frame(width: displaySize.width, height: displaySize.height),
            size: displaySize
        )

        XCTAssertEqual(cameraDetections.count, detectedObjects.count)
        XCTAssertEqual(detectedTexts.count, 2)
        XCTAssertEqual(detectedContours.count, 2)
    }

    func testBarcodeOverlaysRenderWithEmptyObservationArrays() {
        let imageSize = CGSize(width: 400, height: 300)
        let displaySize = CGSize(width: 320, height: 240)
        let barcodes: [VNBarcodeObservation] = []

        ViewRenderingTestHarness.render(
            BarcodeOverlayView(
                barcodes: barcodes,
                imageSize: imageSize,
                displaySize: displaySize
            )
            .frame(width: displaySize.width, height: displaySize.height),
            size: displaySize
        )
        ViewRenderingTestHarness.render(
            BarcodeDetectionOverlay(barcodes: barcodes)
                .frame(width: displaySize.width, height: displaySize.height),
            size: displaySize
        )

        XCTAssertTrue(barcodes.isEmpty)
    }
}

private extension SettingsAndPreviewViewCoverageTests {
    func resetStoredState() {
        AppDependencies.shared.configureForTesting()
        AppSettings.shared.resetToDefaults()
        let manager = DIContainer.shared.resolve(DetectionResultsManager.self)
        waitUntilLoaded(manager)
        DetectionResultFixtures.reset(manager)
    }

    func waitUntilLoaded(_ manager: DetectionResultsManager, timeout: TimeInterval = 1.0) {
        let deadline = Date().addingTimeInterval(timeout)
        while manager.isLoading && Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }
    }
}
