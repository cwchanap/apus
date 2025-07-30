//
//  ServiceLocator.swift
//  apus
//
//  Created by Rovo Dev on 28/7/2025.
//

import Foundation

/// Service locator pattern for accessing dependencies
/// This provides a simpler alternative to property wrappers
class ServiceLocator {
    static let shared = ServiceLocator()
    private let container: DIContainerProtocol
    
    private init(container: DIContainerProtocol = DIContainer.shared) {
        self.container = container
    }
    
    // MARK: - Camera Dependencies
    var cameraManager: CameraManagerProtocol {
        return container.resolve(CameraManagerProtocol.self)
    }
    
    var objectDetectionManager: ObjectDetectionProtocol {
        return container.resolve(ObjectDetectionProtocol.self)
    }
    
    // MARK: - Service Dependencies
    var photoLibraryService: any PhotoLibraryServiceProtocol {
        return container.resolve(PhotoLibraryServiceProtocol.self)
    }
    
    var permissionService: any PermissionServiceProtocol {
        return container.resolve(PermissionServiceProtocol.self)
    }
    
    var errorService: any ErrorServiceProtocol {
        return container.resolve(ErrorServiceProtocol.self)
    }
    
    // MARK: - Testing Support
    func setContainer(_ container: DIContainerProtocol) {
        // This would require making init public and container mutable
        // For now, we'll use DIContainer.shared directly in tests
    }
}