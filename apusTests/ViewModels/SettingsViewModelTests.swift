//
//  SettingsViewModelTests.swift
//  apusTests
//
//  Created by wa-ik on 2025/08/17
//
import XCTest
import Combine
@testable import apus

@MainActor
final class SettingsViewModelTests: XCTestCase {
    var sut: SettingsViewModel!
    var appSettings: AppSettings!
    var cancellables: Set<AnyCancellable>!
    var testContainer: TestDIContainer!

    override func setUp() async throws {
        try await super.setUp()

        AppDependencies.shared.configureForTesting()
        appSettings = AppSettings.shared
        appSettings.resetToDefaults()
        testContainer = TestDIContainer()
        TestDependencySetup.setupMockDependencies(container: testContainer)
        testContainer.register((any ObjectDetectionProtocol).self, instance: MockObjectDetectionManager())
        sut = SettingsViewModel(container: testContainer)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() async throws {
        sut = nil
        appSettings.resetToDefaults()
        appSettings = nil
        testContainer = nil
        cancellables = nil
        try await super.tearDown()
    }

    func test_isRealTimeBarcodeDetectionEnabled_isBoundToAppSettings() {
        // Given
        let initialValue = appSettings.isRealTimeBarcodeDetectionEnabled

        // When
        sut.isRealTimeBarcodeDetectionEnabled = !initialValue

        // Then
        XCTAssertEqual(appSettings.isRealTimeBarcodeDetectionEnabled, !initialValue)
    }

    func test_resetToDefaults_resetsBarcodeDetectionSetting() {
        // Given
        sut.isRealTimeBarcodeDetectionEnabled = false

        // When
        sut.resetToDefaults()

        // Then
        XCTAssertTrue(sut.isRealTimeBarcodeDetectionEnabled)
    }
}
