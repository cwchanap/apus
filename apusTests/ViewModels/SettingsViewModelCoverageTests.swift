//
//  SettingsViewModelCoverageTests.swift
//  apusTests
//
//  Created by Copilot on 2026/03/31.
//

import Combine
import CoreVideo
import XCTest
@testable import apus

extension SettingsViewModelTests {
    func test_initialization_mirrorsAllAppSettingsValues() {
        appSettings.isRealTimeObjectDetectionEnabled = false
        appSettings.isRealTimeBarcodeDetectionEnabled = false
        appSettings.objectDetectionFramework = .coreML
        appSettings.ocrResultsLimit = 3
        appSettings.objectDetectionResultsLimit = 4
        appSettings.classificationResultsLimit = 5
        appSettings.contourDetectionResultsLimit = 6
        appSettings.barcodeDetectionResultsLimit = 7

        sut = SettingsViewModel()

        XCTAssertFalse(sut.isRealTimeObjectDetectionEnabled)
        XCTAssertFalse(sut.isRealTimeBarcodeDetectionEnabled)
        XCTAssertEqual(sut.objectDetectionFramework, .coreML)
        XCTAssertEqual(sut.objectDetectionModel, .yoloV12s)
        XCTAssertEqual(sut.ocrResultsLimit, 3)
        XCTAssertEqual(sut.objectDetectionResultsLimit, 4)
        XCTAssertEqual(sut.classificationResultsLimit, 5)
        XCTAssertEqual(sut.contourDetectionResultsLimit, 6)
        XCTAssertEqual(sut.barcodeDetectionResultsLimit, 7)
    }

    func test_isRealTimeObjectDetectionEnabled_isBoundToAppSettingsWhenDisabled() {
        sut.isRealTimeObjectDetectionEnabled = false

        XCTAssertFalse(appSettings.isRealTimeObjectDetectionEnabled)
    }

    func test_objectDetectionFramework_isBoundToAppSettings() {
        sut.objectDetectionFramework = .coreML

        XCTAssertEqual(appSettings.objectDetectionFramework, .coreML)
    }

    func test_setStorageLimit_clampsValuesAndUpdatesAppSettingsForEveryCategory() {
        for category in DetectionCategory.allCases {
            sut.setStorageLimit(for: category, limit: 0)
            XCTAssertEqual(sut.getStorageLimit(for: category), 1)
            XCTAssertEqual(appSettings.getStorageLimit(for: category), 1)

            sut.setStorageLimit(for: category, limit: 101)
            XCTAssertEqual(sut.getStorageLimit(for: category), 100)
            XCTAssertEqual(appSettings.getStorageLimit(for: category), 100)
        }
    }

    func test_appSettingsChanges_updateViewModelValues() {
        appSettings.isRealTimeObjectDetectionEnabled = false
        appSettings.isRealTimeBarcodeDetectionEnabled = false
        appSettings.objectDetectionFramework = .coreML
        appSettings.ocrResultsLimit = 21
        appSettings.objectDetectionResultsLimit = 22
        appSettings.classificationResultsLimit = 23
        appSettings.contourDetectionResultsLimit = 24
        appSettings.barcodeDetectionResultsLimit = 25

        XCTAssertTrue(waitUntil {
            !self.sut.isRealTimeObjectDetectionEnabled &&
            !self.sut.isRealTimeBarcodeDetectionEnabled &&
            self.sut.objectDetectionFramework == .coreML &&
            self.sut.ocrResultsLimit == 21 &&
            self.sut.objectDetectionResultsLimit == 22 &&
            self.sut.classificationResultsLimit == 23 &&
            self.sut.contourDetectionResultsLimit == 24 &&
            self.sut.barcodeDetectionResultsLimit == 25
        })
    }

    func test_resetToDefaults_restoresAllSettingsValues() {
        sut.isRealTimeObjectDetectionEnabled = false
        sut.isRealTimeBarcodeDetectionEnabled = false
        sut.objectDetectionFramework = .coreML
        sut.setStorageLimit(for: .ocr, limit: 15)
        sut.setStorageLimit(for: .objectDetection, limit: 16)
        sut.setStorageLimit(for: .classification, limit: 17)
        sut.setStorageLimit(for: .contourDetection, limit: 18)
        sut.setStorageLimit(for: .barcode, limit: 19)

        sut.resetToDefaults()

        XCTAssertTrue(waitUntil {
            self.sut.isRealTimeObjectDetectionEnabled &&
            self.sut.isRealTimeBarcodeDetectionEnabled &&
            self.sut.objectDetectionFramework == .vision &&
            self.sut.objectDetectionModel == .yoloV12s &&
            self.sut.ocrResultsLimit == 10 &&
            self.sut.objectDetectionResultsLimit == 10 &&
            self.sut.classificationResultsLimit == 10 &&
            self.sut.contourDetectionResultsLimit == 10 &&
            self.sut.barcodeDetectionResultsLimit == 10
        })
    }

    func test_enablingRealTimeObjectDetection_preloadsModelsInBackground() {
        let preloadManager = PreloadTrackingObjectDetectionManager()
        DIContainer.shared.register(ObjectDetectionProtocol.self, instance: preloadManager)

        sut.isRealTimeObjectDetectionEnabled = false
        sut.isRealTimeObjectDetectionEnabled = true

        XCTAssertTrue(waitUntil(timeout: 1.0) { preloadManager.preloadCalled })
        XCTAssertTrue(appSettings.isRealTimeObjectDetectionEnabled)
    }

    @discardableResult
    private func waitUntil(timeout: TimeInterval = 0.5, pollInterval: TimeInterval = 0.01, condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(pollInterval))
        }
        return condition()
    }
}

private final class PreloadTrackingObjectDetectionManager: ObjectDetectionProtocol {
    let objectWillChange = ObservableObjectPublisher()
    private(set) var detections: [Detection] = []
    private(set) var preloadCalled = false

    func processFrame(_ pixelBuffer: CVPixelBuffer) {}

    func preload() {
        preloadCalled = true
    }
}
