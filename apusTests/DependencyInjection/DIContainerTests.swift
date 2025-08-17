//
//  DIContainerTests.swift
//  apusTests
//
//  Created by wa-ik on 2025/08/17
//
import XCTest
@testable import apus

class DIContainerTests: XCTestCase {

    var sut: DIContainer!

    override func setUp() {
        super.setUp()
        sut = DIContainer.shared
        sut.clear()
    }

    override func tearDown() {
        sut.clear()
        sut = nil
        super.tearDown()
    }

    func test_registerAndResolve_barcodeDetectionManager() {
        // Given
        let manager = MockBarcodeDetectionManager()
        sut.register(BarcodeDetectionProtocol.self, instance: manager)

        // When
        let resolvedManager: BarcodeDetectionProtocol = sut.resolve(BarcodeDetectionProtocol.self)

        // Then
        XCTAssertNotNil(resolvedManager)
        XCTAssertTrue(resolvedManager is MockBarcodeDetectionManager)
    }
}