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
        let key = String(describing: type)

        // Check if we have a singleton instance
        if let instance = services[key] as? T {
            return instance
        }

        // Check if we have a factory
        if let typedFactory = factories[key] as? () -> T {
            let instance = typedFactory()
            return instance
        }

        XCTFail("Test dependency \\(type) not registered in TestDIContainer")
        fatalError("Test dependency \\(type) not registered")
    }

    func resolveOptional<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)

        // Check if we have a singleton instance
        if let instance = services[key] as? T {
            return instance
        }

        // Check if we have a factory
        if let typedFactory = factories[key] as? () -> T {
            let instance = typedFactory()
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
        // Use unified object detection mock for modern path
        container.register(UnifiedObjectDetectionProtocol.self, instance: MockUnifiedObjectDetectionManager(framework: .vision))

        // Register mock text recognition
        container.register(VisionTextRecognitionProtocol.self, instance: MockVisionTextRecognitionManager())

        // Register mock image classification
        container.register(ImageClassificationProtocol.self, instance: MockImageClassificationManager())

        // Register mock services
        container.register(PermissionServiceProtocol.self, instance: MockPermissionService())
        container.register(PhotoLibraryServiceProtocol.self, instance: MockPhotoLibraryService())
        container.register(ErrorServiceProtocol.self, instance: MockErrorService())
        container.register(HapticServiceProtocol.self, instance: MockHapticService())
    }
}

// MARK: - Additional Mock Services for Testing

class MockHapticService: HapticServiceProtocol {
    var impactCalled = false
    var notificationCalled = false
    var selectionCalled = false
    var actionFeedbackCalled = false
    var buttonTapCalled = false
    var strongFeedbackCalled = false
    var successCalled = false
    var errorCalled = false
    var warningCalled = false
    var selectionChangedCalled = false

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        impactCalled = true
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationCalled = true
    }

    func selection() {
        selectionCalled = true
    }

    func actionFeedback() {
        actionFeedbackCalled = true
    }

    func buttonTap() {
        buttonTapCalled = true
    }

    func strongFeedback() {
        strongFeedbackCalled = true
    }

    func success() {
        successCalled = true
    }

    func error() {
        errorCalled = true
    }

    func warning() {
        warningCalled = true
    }

    func selectionChanged() {
        selectionChangedCalled = true
    }
}

class MockImageClassificationManager: ImageClassificationProtocol {
    @Published var isClassifying = false
    @Published var lastClassificationResults: [ClassificationResult] = []
    var classifyImageCalled = false
    var lastClassifiedImage: UIImage?

    func classifyImage(_ image: UIImage, completion: @escaping (Result<[ClassificationResult], Error>) -> Void) {
        classifyImageCalled = true
        lastClassifiedImage = image

        // Simulate processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let mockResults = [
                ClassificationResult(identifier: "document", confidence: 0.75),
                ClassificationResult(identifier: "paper", confidence: 0.65),
                ClassificationResult(identifier: "text", confidence: 0.55),
                ClassificationResult(identifier: "photo", confidence: 0.45)
            ]
            self.lastClassificationResults = mockResults
            completion(.success(mockResults))
        }
    }
}
