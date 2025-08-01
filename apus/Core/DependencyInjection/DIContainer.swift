//
//  DIContainer.swift
//  apus
//
//  Created by Rovo Dev on 28/7/2025.
//

import Foundation
import Combine

/// Protocol for dependency injection container
protocol DIContainerProtocol {
    func register<T>(_ type: T.Type, factory: @escaping () -> T)
    func register<T>(_ type: T.Type, instance: T)
    func resolve<T>(_ type: T.Type) -> T
    func resolve<T>(_ type: T.Type) -> T?
}

/// Main dependency injection container
class DIContainer: DIContainerProtocol, ObservableObject {
    static let shared = DIContainer()
    
    private var services: [String: Any] = [:]
    private var factories: [String: () -> Any] = [:]
    
    private init() {
        registerDefaultDependencies()
    }
    
    /// Register a factory function for a type
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }
    
    /// Register a singleton instance for a type
    func register<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        services[key] = instance
    }
    
    /// Resolve a dependency (force unwrap - use when dependency is guaranteed)
    func resolve<T>(_ type: T.Type) -> T {
        guard let resolved: T = resolve(type) else {
            fatalError("Dependency \(type) not registered in DIContainer")
        }
        return resolved
    }
    
    /// Resolve a dependency (optional - use when dependency might not exist)
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
    
    /// Register default dependencies
    private func registerDefaultDependencies() {
        // Register camera-related dependencies
        register(CameraManagerProtocol.self) { CameraManager() }
        register(ObjectDetectionProtocol.self) { ObjectDetectionProvider() }
        register(ImageClassificationProtocol.self) { ImageClassificationProvider() }
        register(HapticServiceProtocol.self) { HapticService() }
        register(ContourDetectionProtocol.self) { ContourDetectionProvider() }
        
        // Register services (will be implemented later)
        // register(PhotoLibraryServiceProtocol.self) { PhotoLibraryService() }
        // register(PermissionServiceProtocol.self) { PermissionService() }
        // register(ErrorServiceProtocol.self) { ErrorService() }
    }
    
    /// Clear all registrations (useful for testing)
    func clear() {
        services.removeAll()
        factories.removeAll()
    }
    
    /// Reset to default registrations
    func reset() {
        clear()
        registerDefaultDependencies()
    }
}

/// Property wrapper for dependency injection
@propertyWrapper
struct Injected<T> {
    private let container: DIContainerProtocol
    
    var wrappedValue: T {
        return container.resolve(T.self)
    }
    
    init(container: DIContainerProtocol = DIContainer.shared) {
        self.container = container
    }
}

/// Property wrapper for optional dependency injection
@propertyWrapper
struct OptionalInjected<T> {
    private let container: DIContainerProtocol
    
    var wrappedValue: T? {
        return container.resolve(T.self)
    }
    
    init(container: DIContainerProtocol = DIContainer.shared) {
        self.container = container
    }
}