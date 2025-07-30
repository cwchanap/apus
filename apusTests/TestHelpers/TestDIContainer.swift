//
//  TestDIContainer.swift
//  apusTests
//
//  Created by Rovo Dev on 28/7/2025.
//

import XCTest
@testable import apus

/// Test-specific dependency injection container for isolated testing
class TestDIContainer: DIContainerProtocol {
    private var services: [String: Any] = [:]
    private var factories: [String: () -> Any] = [:]
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }
    
    func register<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        services[key] = instance
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        guard let resolved: T = resolve(type) else {
            XCTFail("Test dependency \(type) not registered in TestDIContainer")
            fatalError("Test dependency \(type) not registered")
        }
        return resolved
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        
        // Check if we have a singleton instance
        if let instance = services[key] as? T {
            return instance
        }
        
        // Check if we have a factory
        if let factory = factories[key] {
            let instance = factory() as! T
            return instance
        }
        
        return nil
    }
    
    func clear() {
        services.removeAll()
        factories.removeAll()
    }
}

/// Test helper for setting up mock dependencies
class TestDependencySetup {
    static func setupMockDependencies(container: TestDIContainer) {
        // Register mock camera dependencies
        container.register(CameraManagerProtocol.self, instance: MockCameraManager())
        container.register(ObjectDetectionProtocol.self, instance: MockObjectDetectionManager())
        
        // Register mock services
        container.register(PermissionServiceProtocol.self, instance: MockPermissionService())
        container.register(PhotoLibraryServiceProtocol.self, instance: MockPhotoLibraryService())
        container.register(ErrorServiceProtocol.self, instance: MockErrorService())
    }
}