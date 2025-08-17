//
//  DetectionResultsManagerTests.swift
//  apusTests
//
//  Created by wa-ik on 2025/08/17
//
import XCTest
@testable import apus

class DetectionResultsManagerTests: XCTestCase {

    var sut: DetectionResultsManager!

    override func setUp() {
        super.setUp()
        sut = DetectionResultsManager()
        sut.clearAllResults()
    }

    override func tearDown() {
        sut.clearAllResults()
        sut = nil
        super.tearDown()
    }

    func test_saveBarcodeResult_addsResult() {
        // Given
        let image = UIImage(systemName: "qrcode")!
        let barcode = VNBarcodeObservation()

        // When
        sut.saveBarcodeResult(detectedBarcodes: [barcode], image: image)

        // Then
        XCTAssertEqual(sut.barcodeResults.count, 1)
    }

    func test_clearBarcodeDetectionResults_removesAllResults() {
        // Given
        let image = UIImage(systemName: "qrcode")!
        let barcode = VNBarcodeObservation()
        sut.saveBarcodeResult(detectedBarcodes: [barcode], image: image)

        // When
        sut.clearBarcodeDetectionResults()

        // Then
        XCTAssertEqual(sut.barcodeResults.count, 0)
    }

    func test_deleteBarcodeDetectionResult_removesResult() {
        // Given
        let image = UIImage(systemName: "qrcode")!
        let barcode = VNBarcodeObservation()
        sut.saveBarcodeResult(detectedBarcodes: [barcode], image: image)
        let resultToDelete = sut.barcodeResults[0]

        // When
        sut.deleteBarcodeDetectionResult(id: resultToDelete.id)

        // Then
        XCTAssertEqual(sut.barcodeResults.count, 0)
    }
}