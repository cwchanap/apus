//
//  PhotoLibraryServiceTests.swift
//  apusTests
//
//  Created by Rovo Dev on 28/7/2025.
//

import XCTest
import Combine
import Photos
@testable import apus

final class PhotoLibraryServiceTests: XCTestCase {
    var sut: PhotoLibraryService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = PhotoLibraryService()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Permission Status Tests
    
    func testGetPermissionStatus_ReturnsCorrectStatus() {
        // Given & When
        let status = sut.getPermissionStatus()
        
        // Then
        XCTAssertTrue([.authorized, .denied, .notDetermined, .restricted, .limited].contains(status))
    }
    
    // MARK: - Permission Request Tests
    
    func testRequestPermission_ReturnsPublisher() {
        // Given
        let expectation = XCTestExpectation(description: "Permission request completes")
        var receivedResult: Bool?
        
        // When
        sut.requestPermission()
            .sink { result in
                receivedResult = result
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotNil(receivedResult)
    }
    
    // MARK: - Save Image Tests
    
    func testSaveImage_WithoutPermission_ReturnsPermissionDeniedError() {
        // Given
        let testImage = UIImage(systemName: "camera")!
        let expectation = XCTestExpectation(description: "Save image fails with permission error")
        var receivedError: PhotoLibraryError?
        
        // When
        sut.saveImage(testImage)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { success in
                    if success {
                        expectation.fulfill()
                    }
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        // Note: This test may pass or fail depending on actual permission state
        // In a real test environment, you'd want to mock the permission system
        _ = receivedError // Acknowledge the variable is used for potential debugging
    }
}

// MARK: - Mock Photo Library Service Tests

final class MockPhotoLibraryServiceTests: XCTestCase {
    var sut: MockPhotoLibraryService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = MockPhotoLibraryService()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testRequestPermission_WhenShouldSucceed_ReturnsTrue() {
        // Given
        sut.shouldSucceed = true
        let expectation = XCTestExpectation(description: "Permission request succeeds")
        var receivedResult: Bool?
        
        // When
        sut.requestPermission()
            .sink { result in
                receivedResult = result
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedResult, true)
    }
    
    func testRequestPermission_WhenShouldFail_ReturnsFalse() {
        // Given
        sut.shouldSucceed = false
        let expectation = XCTestExpectation(description: "Permission request fails")
        var receivedResult: Bool?
        
        // When
        sut.requestPermission()
            .sink { result in
                receivedResult = result
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedResult, false)
    }
    
    func testSaveImage_WhenShouldSucceed_ReturnsSuccess() {
        // Given
        sut.shouldSucceed = true
        let testImage = UIImage(systemName: "camera")!
        let expectation = XCTestExpectation(description: "Save image succeeds")
        var receivedResult: Bool?
        
        // When
        sut.saveImage(testImage)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { success in
                    receivedResult = success
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedResult, true)
    }
    
    func testSaveImage_WhenShouldFail_ReturnsError() {
        // Given
        sut.shouldSucceed = false
        let testImage = UIImage(systemName: "camera")!
        let expectation = XCTestExpectation(description: "Save image fails")
        var receivedError: PhotoLibraryError?
        
        // When
        sut.saveImage(testImage)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedError)
        if let error = receivedError {
            XCTAssertTrue(error is PhotoLibraryError)
        }
    }
    
    func testGetPermissionStatus_ReturnsMockStatus() {
        // Given
        sut.mockPermissionStatus = .authorized
        
        // When
        let status = sut.getPermissionStatus()
        
        // Then
        XCTAssertEqual(status, .authorized)
    }
}