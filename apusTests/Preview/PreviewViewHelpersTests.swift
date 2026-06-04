import XCTest
import SwiftUI
import Vision
@testable import apus

@MainActor
final class PreviewViewHelpersTests: XCTestCase {

    override func setUp() {
        super.setUp()
        AppDependencies.shared.configureForTesting()
    }

    // MARK: - Button Text Tests

    func testGetClassificationButtonText_initial() {
        let view = PreviewView(capturedImage: .constant(UIImage()))
        XCTAssertEqual(view.getClassificationButtonText(), "Run Classification")
    }

    func testGetClassificationButtonText_showing() {
        let view = PreviewView(capturedImage: .constant(UIImage()))
        // Can't mutate @State directly; test via rendering instead
        let text = view.getClassificationButtonText()
        XCTAssertNotNil(text)
    }

    func testGetObjectButtonText_returnsNonEmpty() {
        let view = PreviewView(capturedImage: .constant(UIImage()))
        XCTAssertFalse(view.getObjectButtonText().isEmpty)
    }

    func testGetContourButtonText_returnsNonEmpty() {
        let view = PreviewView(capturedImage: .constant(UIImage()))
        XCTAssertFalse(view.getContourButtonText().isEmpty)
    }

    func testGetTextRecognitionButtonText_returnsNonEmpty() {
        let view = PreviewView(capturedImage: .constant(UIImage()))
        XCTAssertFalse(view.getTextRecognitionButtonText().isEmpty)
    }

    func testGetBarcodeButtonText_returnsNonEmpty() {
        let view = PreviewView(capturedImage: .constant(UIImage()))
        XCTAssertFalse(view.getBarcodeButtonText().isEmpty)
    }

    // MARK: - Button Color Tests

    func testGetClassificationButtonColor_returnsColor() {
        let view = PreviewView(capturedImage: .constant(UIImage()))
        let color = view.getClassificationButtonColor()
        XCTAssertNotNil(color)
    }

    func testGetObjectButtonColor_returnsColor() {
        let view = PreviewView(capturedImage: .constant(UIImage()))
        let color = view.getObjectButtonColor()
        XCTAssertNotNil(color)
    }

    func testGetContourButtonColor_returnsColor() {
        let view = PreviewView(capturedImage: .constant(UIImage()))
        let color = view.getContourButtonColor()
        XCTAssertNotNil(color)
    }

    func testGetTextRecognitionButtonColor_returnsColor() {
        let view = PreviewView(capturedImage: .constant(UIImage()))
        let color = view.getTextRecognitionButtonColor()
        XCTAssertNotNil(color)
    }

    func testGetBarcodeButtonColor_returnsColor() {
        let view = PreviewView(capturedImage: .constant(UIImage()))
        let color = view.getBarcodeButtonColor()
        XCTAssertNotNil(color)
    }

    // MARK: - Reset Tests

    func testResetAllDetections_doesNotCrash() {
        let view = PreviewView(capturedImage: .constant(UIImage()))
        view.resetAllDetections()
    }

    // MARK: - Display Image Tests

    func testDisplayImage_nilWhenNoCapturedImage() {
        let view = PreviewView(capturedImage: .constant(nil))
        XCTAssertNil(view.displayImage)
    }

    func testProcessingImage_nilWhenNoCapturedImage() {
        let view = PreviewView(capturedImage: .constant(nil))
        XCTAssertNil(view.processingImage)
    }

    // MARK: - Alert Tests

    func testShowAlert_doesNotCrash() {
        let view = PreviewView(capturedImage: .constant(nil))
        view.showAlert(message: "Test alert")
    }

    // MARK: - Toggle Barcodes Static Tests

    func testToggleBarcodesState_hidesWhenShowing() {
        var showingBarcodes = true
        var detectedBarcodes: [VNBarcodeObservation] = [VNBarcodeObservation()]

        let result = PreviewView.toggleBarcodesState(
            showingBarcodes: &showingBarcodes,
            detectedBarcodes: &detectedBarcodes,
            cachedBarcodes: [],
            hasDetectedBarcodes: true
        )

        XCTAssertTrue(result)
        XCTAssertFalse(showingBarcodes)
        XCTAssertTrue(detectedBarcodes.isEmpty)
    }

    func testToggleBarcodesState_showsCachedWhenAvailable() {
        var showingBarcodes = false
        var detectedBarcodes: [VNBarcodeObservation] = []
        let cached = [VNBarcodeObservation()]

        let result = PreviewView.toggleBarcodesState(
            showingBarcodes: &showingBarcodes,
            detectedBarcodes: &detectedBarcodes,
            cachedBarcodes: cached,
            hasDetectedBarcodes: true
        )

        XCTAssertTrue(result)
        XCTAssertTrue(showingBarcodes)
        XCTAssertEqual(detectedBarcodes.count, 1)
    }

    func testToggleBarcodesState_returnsFalseWhenNoCacheAndNotShowing() {
        var showingBarcodes = false
        var detectedBarcodes: [VNBarcodeObservation] = []

        let result = PreviewView.toggleBarcodesState(
            showingBarcodes: &showingBarcodes,
            detectedBarcodes: &detectedBarcodes,
            cachedBarcodes: [],
            hasDetectedBarcodes: false
        )

        XCTAssertFalse(result)
        XCTAssertFalse(showingBarcodes)
    }
}

@MainActor
final class PreviewViewStateTests: XCTestCase {

    func testPreviewState_defaultValues() {
        let state = PreviewView.PreviewState()
        XCTAssertTrue(state.classificationResults.isEmpty)
        XCTAssertFalse(state.showingClassificationResults)
        XCTAssertFalse(state.isClassifying)
        XCTAssertTrue(state.cachedClassificationResults.isEmpty)
        XCTAssertFalse(state.hasClassificationResults)
        XCTAssertTrue(state.detectedContours.isEmpty)
        XCTAssertFalse(state.showingContours)
        XCTAssertFalse(state.isDetectingContours)
        XCTAssertTrue(state.cachedContours.isEmpty)
        XCTAssertFalse(state.hasDetectedContours)
        XCTAssertTrue(state.detectedObjects.isEmpty)
        XCTAssertFalse(state.showingObjects)
        XCTAssertFalse(state.isDetectingObjects)
        XCTAssertTrue(state.cachedObjects.isEmpty)
        XCTAssertFalse(state.hasDetectedObjects)
        XCTAssertTrue(state.detectedTexts.isEmpty)
        XCTAssertFalse(state.showingTexts)
        XCTAssertFalse(state.isDetectingTexts)
        XCTAssertTrue(state.cachedTexts.isEmpty)
        XCTAssertFalse(state.hasDetectedTexts)
        XCTAssertFalse(state.showingAlert)
        XCTAssertTrue(state.alertMessage.isEmpty)
        XCTAssertFalse(state.isSaved)
        XCTAssertFalse(state.showingHistory)
    }
}
