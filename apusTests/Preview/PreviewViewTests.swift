//
//  PreviewViewTests.swift
//  apusTests
//
//  Created by wa-ik on 2025/08/17
//
import XCTest
import SwiftUI
import Vision
@testable import apus

@MainActor
class PreviewViewTests: XCTestCase {

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
