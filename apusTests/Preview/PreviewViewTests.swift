//
//  PreviewViewTests.swift
//  apusTests
//
//  Created by wa-ik on 2025/08/17
//
import XCTest
@testable import apus

class PreviewViewTests: XCTestCase {

    var sut: PreviewView!

    override func setUp() {
        super.setUp()
        sut = PreviewView(capturedImage: .constant(UIImage(systemName: "qrcode")!))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_toggleBarcodes_showsAndHidesBarcodeOverlay() {
        // Given
        sut.detectedBarcodes = [VNBarcodeObservation()]
        sut.hasDetectedBarcodes = true

        // When
        sut.toggleBarcodes()

        // Then
        XCTAssertTrue(sut.showingBarcodes)

        // When
        sut.toggleBarcodes()

        // Then
        XCTAssertFalse(sut.showingBarcodes)
    }
}
