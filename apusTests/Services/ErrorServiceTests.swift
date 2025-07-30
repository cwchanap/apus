//
//  ErrorServiceTests.swift
//  apusTests
//
//  Created by Rovo Dev on 28/7/2025.
//

import XCTest
import Combine
@testable import apus

final class ErrorServiceTests: XCTestCase {
    var sut: ErrorService!
    var mockPermissionService: MockPermissionService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockPermissionService = MockPermissionService()
        sut = ErrorService(permissionService: mockPermissionService)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        mockPermissionService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Error Handling Tests
    
    func testHandleAppError_CameraPermissionDenied_SetsCorrectError() {
        // Given
        let error = AppError.cameraPermissionDenied
        let expectation = XCTestExpectation(description: "Error is set")
        
        // When
        sut.errorPublisher
            .sink { errorPresentation in
                if let presentation = errorPresentation {
                    XCTAssertEqual(presentation.message, error.localizedDescription)
                    XCTAssertTrue(presentation.shouldShowSettings)
                    XCTAssertEqual(presentation.primaryAction, "Open Settings")
                    XCTAssertEqual(presentation.secondaryAction, "Cancel")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.handleAppError(error)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testHandleAppError_ImageProcessingFailed_SetsCorrectError() {
        // Given
        let error = AppError.imageProcessingFailed
        let expectation = XCTestExpectation(description: "Error is set")
        
        // When
        sut.errorPublisher
            .sink { errorPresentation in
                if let presentation = errorPresentation {
                    XCTAssertEqual(presentation.message, error.localizedDescription)
                    XCTAssertFalse(presentation.shouldShowSettings)
                    XCTAssertEqual(presentation.primaryAction, "OK")
                    XCTAssertNil(presentation.secondaryAction)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.handleAppError(error)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testHandleError_PhotoLibraryError_ConvertsToAppError() {
        // Given
        let photoError = PhotoLibraryError.permissionDenied
        let expectation = XCTestExpectation(description: "Error is converted and set")
        
        // When
        sut.errorPublisher
            .sink { errorPresentation in
                if let presentation = errorPresentation {
                    XCTAssertTrue(presentation.shouldShowSettings)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.handleError(photoError)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testClearError_RemovesCurrentError() {
        // Given
        sut.handleAppError(.cameraPermissionDenied)
        XCTAssertNotNil(sut.currentError)
        
        // When
        sut.clearError()
        
        // Then
        XCTAssertNil(sut.currentError)
    }
    
    func testOpenSettings_CallsPermissionServiceAndClearsError() {
        // Given
        sut.handleAppError(.cameraPermissionDenied)
        XCTAssertNotNil(sut.currentError)
        
        // When
        sut.openSettings()
        
        // Then
        XCTAssertNil(sut.currentError)
        // Note: We can't easily test if openAppSettings was called on the mock
        // without adding additional tracking to the mock
    }
}

// MARK: - Error Presentation Tests

final class ErrorPresentationTests: XCTestCase {
    
    func testErrorPresentation_FromCameraPermissionError_HasCorrectProperties() {
        // Given
        let error = AppError.cameraPermissionDenied
        
        // When
        let presentation = ErrorPresentation(from: error)
        
        // Then
        XCTAssertEqual(presentation.title, "Error")
        XCTAssertEqual(presentation.message, error.localizedDescription)
        XCTAssertNotNil(presentation.recoverySuggestion)
        XCTAssertTrue(presentation.shouldShowSettings)
        XCTAssertEqual(presentation.primaryAction, "Open Settings")
        XCTAssertEqual(presentation.secondaryAction, "Cancel")
    }
    
    func testErrorPresentation_FromImageProcessingError_HasCorrectProperties() {
        // Given
        let error = AppError.imageProcessingFailed
        
        // When
        let presentation = ErrorPresentation(from: error)
        
        // Then
        XCTAssertEqual(presentation.title, "Error")
        XCTAssertEqual(presentation.message, error.localizedDescription)
        XCTAssertNotNil(presentation.recoverySuggestion)
        XCTAssertFalse(presentation.shouldShowSettings)
        XCTAssertEqual(presentation.primaryAction, "OK")
        XCTAssertNil(presentation.secondaryAction)
    }
}

// MARK: - Mock Error Service Tests

final class MockErrorServiceTests: XCTestCase {
    var sut: MockErrorService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = MockErrorService()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testHandleAppError_CapturesError() {
        // Given
        let error = AppError.cameraPermissionDenied
        
        // When
        sut.handleAppError(error)
        
        // Then
        XCTAssertEqual(sut.capturedErrors.count, 1)
        XCTAssertEqual(sut.capturedErrors.first, error)
        XCTAssertNotNil(sut.currentError)
    }
    
    func testClearError_RemovesCurrentError() {
        // Given
        sut.handleAppError(.imageProcessingFailed)
        XCTAssertNotNil(sut.currentError)
        
        // When
        sut.clearError()
        
        // Then
        XCTAssertNil(sut.currentError)
    }
}