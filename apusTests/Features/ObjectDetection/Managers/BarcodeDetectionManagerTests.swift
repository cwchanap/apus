//
//  BarcodeDetectionManagerTests.swift
//  apusTests
//
//  Created by wa-ik on 2025/08/17
//
import XCTest
@testable import apus

class BarcodeDetectionManagerTests: XCTestCase {

    var sut: BarcodeDetectionManager!

    override func setUp() {
        super.setUp()
        sut = BarcodeDetectionManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_detectBarcodes_withValidImage_returnsBarcodes() {
        // Given
        let expectation = self.expectation(description: "Barcode detection completes")
        let image = UIImage(systemName: "qrcode")!

        // When
        sut.detectBarcodes(on: image) { barcodes in
            // Then
            XCTAssertFalse(barcodes.isEmpty)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func test_detectBarcodes_withInvalidImage_returnsNoBarcodes() {
        // Given
        let expectation = self.expectation(description: "Barcode detection completes")
        let image = UIImage()

        // When
        sut.detectBarcodes(on: image) { barcodes in
            // Then
            XCTAssertTrue(barcodes.isEmpty)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
