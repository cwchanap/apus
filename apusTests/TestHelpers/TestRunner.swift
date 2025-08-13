//
//  TestRunner.swift
//  apusTests
//
//  Created by Rovo Dev on 28/7/2025.
//

import XCTest
@testable import apus

/// Test runner utility for setting up and running tests
class TestRunner {

    /// Run all service tests
    static func runServiceTests() {
        let testSuite = XCTestSuite(name: "Service Tests")

        // Add service test cases
        testSuite.addTest(PhotoLibraryServiceTests.defaultTestSuite)
        testSuite.addTest(PermissionServiceTests.defaultTestSuite)
        testSuite.addTest(ErrorServiceTests.defaultTestSuite)

        // Run the tests
        testSuite.run()
    }

    /// Run all ViewModel tests
    static func runViewModelTests() {
        let testSuite = XCTestSuite(name: "ViewModel Tests")

        // Add ViewModel test cases
        testSuite.addTest(CameraViewModelTests.defaultTestSuite)

        // Run the tests
        testSuite.run()
    }

    /// Run all dependency injection tests
    static func runDependencyInjectionTests() {
        let testSuite = XCTestSuite(name: "Dependency Injection Tests")

        // Add DI test cases
        testSuite.addTest(DIContainerTests.defaultTestSuite)

        // Run the tests
        testSuite.run()
    }

    /// Setup test environment with clean dependencies
    static func setupTestEnvironment() {
        // Clear and setup test dependencies
        DIContainer.shared.clear()

        // Register test dependencies
        TestDependencySetup.setupMockDependencies(container: TestDIContainer())
    }

    /// Cleanup test environment
    static func cleanupTestEnvironment() {
        // Reset to default dependencies
        DIContainer.shared.reset()
    }
}
