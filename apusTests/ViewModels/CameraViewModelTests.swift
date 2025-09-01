//
//  CameraViewModelTests.swift
//  apusTests
//
//  Created by Rovo Dev on 28/7/2025.
//

import XCTest
import Combine
@testable import apus

@MainActor
final class CameraViewModelTests: XCTestCase {
    var sut: CameraViewModel!
    var mockCameraManager: MockCameraManager!
    var mockObjectDetectionManager: MockUnifiedObjectDetectionManager!
    var mockBarcodeDetectionManager: MockBarcodeDetectionManager!
    var testContainer: TestDIContainer!
    var cancellables: Set<AnyCancellable>!

    override func setUp() async throws {
        try await super.setUp()

        // Setup test dependencies
        testContainer = TestDIContainer()
        mockCameraManager = MockCameraManager()
        mockObjectDetectionManager = MockUnifiedObjectDetectionManager(framework: .vision)
        mockBarcodeDetectionManager = MockBarcodeDetectionManager()

        // Register test dependencies
        testContainer.register(CameraManagerProtocol.self, instance: mockCameraManager)
        testContainer.register(UnifiedObjectDetectionProtocol.self, instance: mockObjectDetectionManager)
        testContainer.register(BarcodeDetectionProtocol.self, instance: mockBarcodeDetectionManager)

        // Create view model with test dependencies
        sut = CameraViewModel(cameraManager: mockCameraManager, objectDetectionManager: mockObjectDetectionManager, barcodeDetectionManager: mockBarcodeDetectionManager)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() async throws {
        sut = nil
        mockCameraManager = nil
        mockObjectDetectionManager = nil
        mockBarcodeDetectionManager = nil
        testContainer = nil
        cancellables = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInit_SetsUpBindings() {
        // Given & When (initialization happens in setUp)

        // Then
        XCTAssertNotNil(sut)
        XCTAssertFalse(sut.showingImagePicker)
        XCTAssertNil(sut.capturedImage)
        XCTAssertFalse(sut.isFlashOn)
        XCTAssertEqual(sut.currentZoomFactor, 1.0)
    }

    // MARK: - Camera Control Tests

    func testStartCamera_CallsCameraManagerStartSession() {
        // When
        sut.startCamera()

        // Then
        XCTAssertTrue(mockCameraManager.isSessionRunning)
    }

    func testStopCamera_CallsCameraManagerStopSession() {
        // Given
        sut.startCamera()
        XCTAssertTrue(mockCameraManager.isSessionRunning)

        // When
        sut.stopCamera()

        // Then
        XCTAssertFalse(mockCameraManager.isSessionRunning)
    }

    func testToggleFlash_UpdatesFlashState() {
        // Given
        let initialFlashState = sut.isFlashOn

        // When
        sut.toggleFlash()

        // Then
        XCTAssertEqual(sut.isFlashOn, !initialFlashState)
        XCTAssertEqual(mockCameraManager.isFlashOn, !initialFlashState)
    }

    func testZoom_UpdatesZoomFactor() {
        // Given
        let newZoomFactor: CGFloat = 2.5

        // When
        sut.zoom(factor: newZoomFactor)

        // Then
        XCTAssertEqual(sut.currentZoomFactor, newZoomFactor)
        XCTAssertEqual(mockCameraManager.currentZoomFactor, newZoomFactor)
    }

    // MARK: - Photo Capture Tests

    func testCapturePhoto_UpdatesCapturedImage() {
        // Given
        let expectation = XCTestExpectation(description: "Photo captured")

        // When
        sut.capturePhoto()

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(self.sut.capturedImage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testIsShowingPreview_ReturnsCorrectBinding() {
        // Given
        XCTAssertFalse(sut.isShowingPreview.wrappedValue)

        // When
        sut.capturedImage = UIImage(systemName: "camera")

        // Then
        XCTAssertTrue(sut.isShowingPreview.wrappedValue)

        // When
        sut.isShowingPreview.wrappedValue = false

        // Then
        XCTAssertNil(sut.capturedImage)
    }

    // MARK: - Image Picker Tests

    func testSelectImageFromLibrary_ShowsImagePicker() {
        // Given
        XCTAssertFalse(sut.showingImagePicker)

        // When
        sut.selectImageFromLibrary()

        // Then
        XCTAssertTrue(sut.showingImagePicker)
    }

    func testHandleSelectedImage_UpdatesCapturedImageAndHidesPicker() {
        // Given
        let testImage = UIImage(systemName: "photo")
        sut.showingImagePicker = true

        // When
        sut.handleSelectedImage(testImage)

        // Then
        XCTAssertEqual(sut.capturedImage, testImage)
        XCTAssertFalse(sut.showingImagePicker)
    }

    func testHandleSelectedImage_WithNilImage_HidesPicker() {
        // Given
        sut.showingImagePicker = true

        // When
        sut.handleSelectedImage(nil)

        // Then
        XCTAssertNil(sut.capturedImage)
        XCTAssertFalse(sut.showingImagePicker)
    }

    // MARK: - Object Detection Tests

    func testDetections_ReturnsObjectDetectionManagerDetections() {
        // Given
        let mockDetections = [
            DetectedObject(boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.25, height: 0.25), className: "person", confidence: 0.9, framework: .vision)
        ]
        mockObjectDetectionManager.lastDetectedObjects = mockDetections

        // When
        let detections = sut.detections

        // Then
        XCTAssertEqual(detections.count, mockDetections.count)
        XCTAssertEqual(detections.first?.className, "person")
        XCTAssertEqual(detections.first?.confidence, 0.9)
    }

    func testConcreteCameraManager_ReturnsCorrectType() {
        // When
        let concreteCameraManager = sut.concreteCameraManager

        // Then
        // In unit tests we pass a mock, so this should be nil
        XCTAssertNil(concreteCameraManager)
        // In production, with a real CameraManager, this would be non-nil
    }
}
