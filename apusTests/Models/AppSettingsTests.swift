//
//  AppSettingsTests.swift
//  apusTests
//
//  Created by Codex on 2026/03/25.
//

import XCTest
@testable import apus

final class AppSettingsTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUpWithError() throws {
        try super.setUpWithError()
        suiteName = "AppSettingsTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDownWithError() throws {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil
        try super.tearDownWithError()
    }

    func test_init_loadsDefaultValuesWhenStoreIsEmpty() {
        let settings = AppSettings(userDefaults: userDefaults)

        XCTAssertTrue(settings.isRealTimeObjectDetectionEnabled)
        XCTAssertTrue(settings.isRealTimeBarcodeDetectionEnabled)
        XCTAssertEqual(settings.objectDetectionFramework, .vision)
        XCTAssertEqual(settings.objectDetectionModel, .yoloV12s)
        XCTAssertEqual(settings.ocrResultsLimit, 10)
        XCTAssertEqual(settings.objectDetectionResultsLimit, 10)
        XCTAssertEqual(settings.classificationResultsLimit, 10)
        XCTAssertEqual(settings.contourDetectionResultsLimit, 10)
        XCTAssertEqual(settings.barcodeDetectionResultsLimit, 10)
    }

    func test_init_loadsPersistedValuesFromInjectedUserDefaults() {
        userDefaults.set(false, forKey: UserDefaults.Keys.isRealTimeObjectDetectionEnabled)
        userDefaults.set(false, forKey: UserDefaults.Keys.isRealTimeBarcodeDetectionEnabled)
        userDefaults.set(ObjectDetectionFramework.coreML.rawValue, forKey: UserDefaults.Keys.objectDetectionFramework)
        userDefaults.set(ObjectDetectionModel.yoloV12s.rawValue, forKey: UserDefaults.Keys.objectDetectionModel)
        userDefaults.set(4, forKey: UserDefaults.Keys.ocrResultsLimit)
        userDefaults.set(5, forKey: UserDefaults.Keys.objectDetectionResultsLimit)
        userDefaults.set(6, forKey: UserDefaults.Keys.classificationResultsLimit)
        userDefaults.set(7, forKey: UserDefaults.Keys.contourDetectionResultsLimit)
        userDefaults.set(8, forKey: UserDefaults.Keys.barcodeDetectionResultsLimit)

        let settings = AppSettings(userDefaults: userDefaults)

        XCTAssertFalse(settings.isRealTimeObjectDetectionEnabled)
        XCTAssertFalse(settings.isRealTimeBarcodeDetectionEnabled)
        XCTAssertEqual(settings.objectDetectionFramework, .coreML)
        XCTAssertEqual(settings.objectDetectionModel, .yoloV12s)
        XCTAssertEqual(settings.ocrResultsLimit, 4)
        XCTAssertEqual(settings.objectDetectionResultsLimit, 5)
        XCTAssertEqual(settings.classificationResultsLimit, 6)
        XCTAssertEqual(settings.contourDetectionResultsLimit, 7)
        XCTAssertEqual(settings.barcodeDetectionResultsLimit, 8)
    }

    func test_propertyMutationsPersistToInjectedUserDefaults() {
        let settings = AppSettings(userDefaults: userDefaults)

        settings.isRealTimeObjectDetectionEnabled = false
        settings.isRealTimeBarcodeDetectionEnabled = false
        settings.objectDetectionFramework = .coreML
        settings.objectDetectionModel = .yoloV12s
        settings.ocrResultsLimit = 11
        settings.objectDetectionResultsLimit = 12
        settings.classificationResultsLimit = 13
        settings.contourDetectionResultsLimit = 14
        settings.barcodeDetectionResultsLimit = 15

        XCTAssertEqual(userDefaults.object(forKey: UserDefaults.Keys.isRealTimeObjectDetectionEnabled) as? Bool, false)
        XCTAssertEqual(userDefaults.object(forKey: UserDefaults.Keys.isRealTimeBarcodeDetectionEnabled) as? Bool, false)
        XCTAssertEqual(userDefaults.string(forKey: UserDefaults.Keys.objectDetectionFramework), ObjectDetectionFramework.coreML.rawValue)
        XCTAssertEqual(userDefaults.string(forKey: UserDefaults.Keys.objectDetectionModel), ObjectDetectionModel.yoloV12s.rawValue)
        XCTAssertEqual(userDefaults.integer(forKey: UserDefaults.Keys.ocrResultsLimit), 11)
        XCTAssertEqual(userDefaults.integer(forKey: UserDefaults.Keys.objectDetectionResultsLimit), 12)
        XCTAssertEqual(userDefaults.integer(forKey: UserDefaults.Keys.classificationResultsLimit), 13)
        XCTAssertEqual(userDefaults.integer(forKey: UserDefaults.Keys.contourDetectionResultsLimit), 14)
        XCTAssertEqual(userDefaults.integer(forKey: UserDefaults.Keys.barcodeDetectionResultsLimit), 15)
    }

    func test_setStorageLimit_clampsValuesForEveryCategory() {
        let settings = AppSettings(userDefaults: userDefaults)

        for category in DetectionCategory.allCases {
            settings.setStorageLimit(for: category, limit: 0)
            XCTAssertEqual(settings.getStorageLimit(for: category), 1)

            settings.setStorageLimit(for: category, limit: 101)
            XCTAssertEqual(settings.getStorageLimit(for: category), 100)
        }
    }

    func test_resetToDefaults_restoresDefaultValues() {
        let settings = AppSettings(userDefaults: userDefaults)

        settings.isRealTimeObjectDetectionEnabled = false
        settings.isRealTimeBarcodeDetectionEnabled = false
        settings.objectDetectionFramework = .coreML
        settings.ocrResultsLimit = 3
        settings.objectDetectionResultsLimit = 4
        settings.classificationResultsLimit = 5
        settings.contourDetectionResultsLimit = 6
        settings.barcodeDetectionResultsLimit = 7

        settings.resetToDefaults()

        XCTAssertTrue(settings.isRealTimeObjectDetectionEnabled)
        XCTAssertTrue(settings.isRealTimeBarcodeDetectionEnabled)
        XCTAssertEqual(settings.objectDetectionFramework, .vision)
        XCTAssertEqual(settings.objectDetectionModel, .yoloV12s)
        XCTAssertEqual(settings.ocrResultsLimit, 10)
        XCTAssertEqual(settings.objectDetectionResultsLimit, 10)
        XCTAssertEqual(settings.classificationResultsLimit, 10)
        XCTAssertEqual(settings.contourDetectionResultsLimit, 10)
        XCTAssertEqual(settings.barcodeDetectionResultsLimit, 10)
    }
}
