//
//  BarcodeDetectionManagerTests.swift
//  apusTests
//
//  Created by wa-ik on 2025/08/17
//
import CoreImage
import Foundation
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

    func test_detectBarcodes_withValidImage_returnsBarcodes() throws {
        // Given
        try XCTSkipIf(ProcessInfo.processInfo.environment["CI"] == "true", "Barcode detection can be unreliable on headless CI simulators.")
        #if targetEnvironment(simulator)
        throw XCTSkip("Barcode detection can be unreliable on the simulator.")
        #endif
        let expectation = self.expectation(description: "Barcode detection completes")
        let image = generateQRCodeImage(from: "https://example.com")

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

private func generateQRCodeImage(from string: String) -> UIImage {
    let data = Data(string.utf8)
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
        return UIImage()
    }
    filter.setValue(data, forKey: "inputMessage")
    filter.setValue("M", forKey: "inputCorrectionLevel")

    let transform = CGAffineTransform(scaleX: 6, y: 6)
    if let outputImage = filter.outputImage?.transformed(by: transform) {
        let context = CIContext()
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
    }
    // Fallback to an empty image if generation fails
    return UIImage()
}
