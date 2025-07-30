//
//  AppDependencies.swift
//  apus
//
//  Created by Rovo Dev on 28/7/2025.
//

import Foundation
import SwiftUI
import AVFoundation
import CoreVideo

/// Centralized dependency configuration for the entire app
class AppDependencies: ObservableObject {
    static let shared = AppDependencies()
    
    private let container: DIContainer
    
    private init() {
        self.container = DIContainer.shared
        configureDependencies()
    }
    
    /// Configure all app dependencies
    private func configureDependencies() {
        // Camera dependencies
        configureCameraDependencies()
        
        // Service dependencies
        configureServiceDependencies()
        
        // Navigation dependencies
        // configureNavigationDependencies()
    }
    
    // MARK: - Camera Dependencies
    private func configureCameraDependencies() {
        // Register camera manager as singleton
        container.register(CameraManagerProtocol.self) {
            CameraManager() as any CameraManagerProtocol
        }
        
        // Register object detection manager
        container.register(ObjectDetectionProtocol.self) {
            ObjectDetectionProvider() as any ObjectDetectionProtocol
        }
    }
    
    // MARK: - Service Dependencies
    private func configureServiceDependencies() {
        // Register permission service first (needed by error service)
        container.register(PermissionServiceProtocol.self) {
            PermissionService() as any PermissionServiceProtocol
        }
        
        // Register photo library service
        container.register(PhotoLibraryServiceProtocol.self) {
            PhotoLibraryService() as any PhotoLibraryServiceProtocol
        }
        
        // Register error service with permission service dependency
        container.register(ErrorServiceProtocol.self) {
            let permissionService: any PermissionServiceProtocol = self.container.resolve(PermissionServiceProtocol.self)
            return ErrorService(permissionService: permissionService) as any ErrorServiceProtocol
        }
    }
    
    // MARK: - Testing Support
    func configureForTesting() {
        container.clear()
        
        // Register mock dependencies for testing
        container.register(CameraManagerProtocol.self) {
            MockCameraManager() as any CameraManagerProtocol
        }
        
        container.register(ObjectDetectionProtocol.self) {
            MockObjectDetectionManager() as any ObjectDetectionProtocol
        }
        
        // Register mock services
        container.register(PermissionServiceProtocol.self) {
            MockPermissionService() as any PermissionServiceProtocol
        }
        
        container.register(PhotoLibraryServiceProtocol.self) {
            MockPhotoLibraryService() as any PhotoLibraryServiceProtocol
        }
        
        container.register(ErrorServiceProtocol.self) {
            MockErrorService() as any ErrorServiceProtocol
        }
    }
    
    // MARK: - Dependency Access
    var diContainer: DIContainerProtocol {
        return self.container
    }
}

// MARK: - Mock Dependencies for Testing
class MockCameraManager: ObservableObject, CameraManagerProtocol {
    @Published var isSessionRunning = false
    @Published var isFlashOn = false
    @Published var currentZoomFactor: CGFloat = 1.0
    
    let session = AVCaptureSession()
    
    func startSession() {
        isSessionRunning = true
    }
    
    func stopSession() {
        isSessionRunning = false
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        // Return a mock image
        completion(UIImage(systemName: "camera"))
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
    }
    
    func zoom(factor: CGFloat) {
        currentZoomFactor = factor
    }
    
    func setObjectDetectionHandler(_ handler: @escaping (CVPixelBuffer) -> Void) {
        // Mock implementation
    }
    
    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        // Mock implementation
    }
}