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
        // Don't configure dependencies immediately - do it lazily when first needed
    }
    
    private var dependenciesConfigured = false
    
    /// Configure all app dependencies lazily
    private func ensureDependenciesConfigured() {
        guard !dependenciesConfigured else { return }
        
        configureDependencies()
        dependenciesConfigured = true
    }
    
    /// Configure all app dependencies
    private func configureDependencies() {
        // Core app settings
        configureAppSettings()
        
        // Camera dependencies
        configureCameraDependencies()
        
        // Service dependencies
        configureServiceDependencies()
        
        // Navigation dependencies
        // configureNavigationDependencies()
    }
    
    // MARK: - App Settings
    private func configureAppSettings() {
        // Register app settings as singleton
        let appSettings = AppSettings.shared
        container.register(AppSettings.self, instance: appSettings)
    }
    
    // MARK: - Camera Dependencies
    private func configureCameraDependencies() {
        // Register camera manager as singleton instance (not factory)
        let cameraManager = CameraManager()
        container.register(CameraManagerProtocol.self, instance: cameraManager)
        
        // Register object detection manager as singleton instance
        let objectDetectionManager = ObjectDetectionProvider()
        container.register(ObjectDetectionProtocol.self, instance: objectDetectionManager)
        
        // Register image classification manager as singleton instance
        let imageClassificationManager = ImageClassificationProvider()
        container.register(ImageClassificationProtocol.self, instance: imageClassificationManager)
        
        
        // Register haptic service as singleton instance
        let hapticService = HapticService()
        container.register(HapticServiceProtocol.self, instance: hapticService)
        
        // Register contour detection manager as singleton instance
        let contourDetectionManager = ContourDetectionProvider()
        container.register(ContourDetectionProtocol.self, instance: contourDetectionManager)
        
        // Register unified object detection manager as singleton instance
        // Use default factory to avoid circular dependency with AppSettings
        let unifiedObjectDetectionManager = ObjectDetectionFactory.createObjectDetectionManager()
        container.register(UnifiedObjectDetectionProtocol.self, instance: unifiedObjectDetectionManager)
        
        // Register text recognition manager as singleton instance
        let textRecognitionManager = VisionTextRecognitionProvider()
        container.register(VisionTextRecognitionProtocol.self, instance: textRecognitionManager)
        
        // Register detection results manager as singleton instance
        let detectionResultsManager = DetectionResultsManager()
        container.register(DetectionResultsManager.self, instance: detectionResultsManager)
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
        
        container.register(ImageClassificationProtocol.self) {
            MockImageClassificationManager() as any ImageClassificationProtocol
        }
        
        container.register(HapticServiceProtocol.self) {
            MockHapticService() as any HapticServiceProtocol
        }
        
        container.register(ContourDetectionProtocol.self) {
            MockContourDetectionManager() as any ContourDetectionProtocol
        }
        
        container.register(UnifiedObjectDetectionProtocol.self) {
            ObjectDetectionFactory.createObjectDetectionManager()
        }
        
        container.register(VisionTextRecognitionProtocol.self) {
            VisionTextRecognitionProvider() as any VisionTextRecognitionProtocol
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
        ensureDependenciesConfigured()
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