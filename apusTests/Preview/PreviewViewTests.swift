//
//  PreviewViewTests.swift
//  apusTests
//
//  Created by wa-ik on 2025/08/17
//
import XCTest
@testable import apus

@MainActor
class PreviewViewTests: XCTestCase {

    var sut: PreviewView!

    override func setUp() {
        super.setUp()
        AppDependencies.shared.configureForTesting()
        sut = PreviewView(capturedImage: .constant(UIImage(systemName: "qrcode")!))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_toggleBarcodes_showsAndHidesBarcodeOverlay() {
        // Given
        sut.detectedBarcodes = []
        sut.cachedBarcodes = []
        sut.hasDetectedBarcodes = false
        sut.showingBarcodes = false

        let showExpectation = expectation(description: "Shows barcodes")

        // When
        sut.toggleBarcodes()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if self.sut.showingBarcodes {
                showExpectation.fulfill()
            }
        }

        wait(for: [showExpectation], timeout: 2.0)

        // Then
        XCTAssertTrue(sut.showingBarcodes)

        // When
        sut.toggleBarcodes()

        // Then
        XCTAssertFalse(sut.showingBarcodes)
    }
}
