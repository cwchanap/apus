//
//  PermissionServiceTests.swift
//  apusTests
//
//  Created by Rovo Dev on 28/7/2025.
//

import XCTest
import Combine
@testable import apus

final class PermissionServiceTests: XCTestCase {
    var sut: PermissionService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        sut = PermissionService()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Permission Status Tests

    func testGetPermissionStatus_ForCamera_ReturnsValidStatus() {
        // When
        let status = sut.getPermissionStatus(for: .camera)

        // Then
        XCTAssertTrue([.authorized, .denied, .notDetermined, .restricted].contains(status))
    }

    func testGetPermissionStatus_ForPhotoLibrary_ReturnsValidStatus() {
        // When
        let status = sut.getPermissionStatus(for: .photoLibrary)

        // Then
        XCTAssertTrue([.authorized, .denied, .notDetermined, .restricted].contains(status))
    }

    func testGetPermissionStatus_ForMicrophone_ReturnsValidStatus() {
        // When
        let status = sut.getPermissionStatus(for: .microphone)

        // Then
        XCTAssertTrue([.authorized, .denied, .notDetermined, .restricted].contains(status))
    }

    // MARK: - Permission Request Tests

    func testRequestPermission_ForCamera_ReturnsPublisher() {
        // Given
        let expectation = XCTestExpectation(description: "Camera permission request completes")
        var receivedStatus: PermissionStatus?

        // When
        sut.requestPermission(for: .camera)
            .sink { status in
                receivedStatus = status
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotNil(receivedStatus)
    }

    // MARK: - Permission Status Helper Tests

    func testPermissionStatus_IsAuthorized_ReturnsCorrectValue() {
        // Given & When & Then
        XCTAssertTrue(PermissionStatus.authorized.isAuthorized)
        XCTAssertFalse(PermissionStatus.denied.isAuthorized)
        XCTAssertFalse(PermissionStatus.notDetermined.isAuthorized)
        XCTAssertFalse(PermissionStatus.restricted.isAuthorized)
    }
}

// MARK: - Mock Permission Service Tests

final class MockPermissionServiceTests: XCTestCase {
    var sut: MockPermissionService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        sut = MockPermissionService()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }

    func testRequestPermission_WhenShouldGrant_ReturnsAuthorized() {
        // Given
        sut.shouldGrantPermissions = true
        let expectation = XCTestExpectation(description: "Permission granted")
        var receivedStatus: PermissionStatus?

        // When
        sut.requestPermission(for: .camera)
            .sink { status in
                receivedStatus = status
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedStatus, .authorized)
        XCTAssertEqual(sut.getPermissionStatus(for: .camera), .authorized)
    }

    func testRequestPermission_WhenShouldDeny_ReturnsDenied() {
        // Given
        sut.shouldGrantPermissions = false
        let expectation = XCTestExpectation(description: "Permission denied")
        var receivedStatus: PermissionStatus?

        // When
        sut.requestPermission(for: .camera)
            .sink { status in
                receivedStatus = status
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedStatus, .denied)
        XCTAssertEqual(sut.getPermissionStatus(for: .camera), .denied)
    }

    func testGetPermissionStatus_WithoutPreviousRequest_ReturnsNotDetermined() {
        // When
        let status = sut.getPermissionStatus(for: .camera)

        // Then
        XCTAssertEqual(status, .notDetermined)
    }

    func testOpenAppSettings_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow(sut.openAppSettings())
    }
}
