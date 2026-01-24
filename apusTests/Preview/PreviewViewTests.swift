//
//  PreviewViewTests.swift
//  apusTests
//
//  Created by wa-ik on 2025/08/17
//
import XCTest
import SwiftUI
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
        var showingBarcodes = false
        var detectedBarcodes: [VNBarcodeObservation] = []
        let cachedBarcodes: [VNBarcodeObservation] = []
        let hasDetectedBarcodes = true

        // When
        let didToggleOn = PreviewView.toggleBarcodesState(
            showingBarcodes: &showingBarcodes,
            detectedBarcodes: &detectedBarcodes,
            cachedBarcodes: cachedBarcodes,
            hasDetectedBarcodes: hasDetectedBarcodes
        )

        // Then
        XCTAssertTrue(didToggleOn)
        XCTAssertTrue(showingBarcodes)

        // When
        let didToggleOff = PreviewView.toggleBarcodesState(
            showingBarcodes: &showingBarcodes,
            detectedBarcodes: &detectedBarcodes,
            cachedBarcodes: cachedBarcodes,
            hasDetectedBarcodes: hasDetectedBarcodes
        )

        // Then
        XCTAssertTrue(didToggleOff)
        XCTAssertFalse(showingBarcodes)
    }
}
