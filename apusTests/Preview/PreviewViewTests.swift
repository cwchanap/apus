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
        let host = UIHostingController(rootView: sut)
        host.loadViewIfNeeded()

        // Given
        host.rootView.detectedBarcodes = []
        host.rootView.cachedBarcodes = []
        host.rootView.hasDetectedBarcodes = true
        host.rootView.showingBarcodes = false

        // When
        host.rootView.toggleBarcodes()

        // Then
        XCTAssertTrue(host.rootView.showingBarcodes)

        // When
        host.rootView.toggleBarcodes()

        // Then
        XCTAssertFalse(host.rootView.showingBarcodes)
    }
}
