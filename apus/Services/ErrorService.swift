//
//  ErrorService.swift
//  apus
//
//  Created by Rovo Dev on 28/7/2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - App Error Types
enum AppError: LocalizedError, Equatable {
    case cameraPermissionDenied
    case photoLibraryPermissionDenied
    case objectDetectionInitializationFailed
    case imageProcessingFailed
    case networkError(String)
    case fileSystemError(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .cameraPermissionDenied:
            return "Camera access is required to use this feature. Please enable camera access in Settings."
        case .photoLibraryPermissionDenied:
            return "Photo library access is required to save images. Please enable access in Settings."
        case .objectDetectionInitializationFailed:
            return "Failed to initialize object detection. Please restart the app."
        case .imageProcessingFailed:
            return "Failed to process the image. Please try again."
        case .networkError(let message):
            return "Network error: \(message)"
        case .fileSystemError(let message):
            return "File system error: \(message)"
        case .unknown(let message):
            return "An unexpected error occurred: \(message)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .cameraPermissionDenied, .photoLibraryPermissionDenied:
            return "Go to Settings > Privacy & Security > Camera/Photos and enable access for this app."
        case .objectDetectionInitializationFailed:
            return "Try restarting the app. If the problem persists, please contact support."
        case .imageProcessingFailed:
            return "Try taking another photo or selecting a different image."
        case .networkError:
            return "Check your internet connection and try again."
        case .fileSystemError:
            return "Ensure you have enough storage space available."
        case .unknown:
            return "Please try again. If the problem persists, contact support."
        }
    }

    var shouldShowSettings: Bool {
        switch self {
        case .cameraPermissionDenied, .photoLibraryPermissionDenied:
            return true
        default:
            return false
        }
    }
}

// MARK: - Error Presentation Model
struct ErrorPresentation {
    let title: String
    let message: String
    let recoverySuggestion: String?
    let shouldShowSettings: Bool
    let primaryAction: String
    let secondaryAction: String?

    init(from error: AppError) {
        self.title = "Error"
        self.message = error.localizedDescription
        self.recoverySuggestion = error.recoverySuggestion
        self.shouldShowSettings = error.shouldShowSettings
        self.primaryAction = error.shouldShowSettings ? "Open Settings" : "OK"
        self.secondaryAction = error.shouldShowSettings ? "Cancel" : nil
    }
}

// MARK: - Error Service Protocol
protocol ErrorServiceProtocol {
    var currentError: ErrorPresentation? { get }
    var errorPublisher: AnyPublisher<ErrorPresentation?, Never> { get }

    func handleError(_ error: Error)
    func handleAppError(_ error: AppError)
    func clearError()
    func openSettings()
}

// MARK: - Error Service Implementation
class ErrorService: ErrorServiceProtocol, ObservableObject {
    @Published private(set) var currentError: ErrorPresentation?

    var errorPublisher: AnyPublisher<ErrorPresentation?, Never> {
        $currentError.eraseToAnyPublisher()
    }

    private let permissionService: PermissionServiceProtocol

    init(permissionService: PermissionServiceProtocol) {
        self.permissionService = permissionService
    }

    func handleError(_ error: Error) {
        if let appError = error as? AppError {
            handleAppError(appError)
        } else if let photoError = error as? PhotoLibraryError {
            handlePhotoLibraryError(photoError)
        } else {
            handleAppError(.unknown(error.localizedDescription))
        }
    }

    func handleAppError(_ error: AppError) {
        DispatchQueue.main.async {
            self.currentError = ErrorPresentation(from: error)
        }
    }

    func clearError() {
        DispatchQueue.main.async {
            self.currentError = nil
        }
    }

    func openSettings() {
        permissionService.openAppSettings()
        clearError()
    }

    // MARK: - Private Methods

    private func handlePhotoLibraryError(_ error: PhotoLibraryError) {
        let appError: AppError
        switch error {
        case .permissionDenied:
            appError = .photoLibraryPermissionDenied
        case .saveFailed(let underlyingError):
            appError = .fileSystemError(underlyingError.localizedDescription)
        case .unknown:
            appError = .unknown("Failed to access photo library")
        }
        handleAppError(appError)
    }
}

// MARK: - Mock Error Service for Testing
class MockErrorService: ErrorServiceProtocol, ObservableObject {
    @Published private(set) var currentError: ErrorPresentation?

    var errorPublisher: AnyPublisher<ErrorPresentation?, Never> {
        $currentError.eraseToAnyPublisher()
    }

    var capturedErrors: [AppError] = []

    func handleError(_ error: Error) {
        if let appError = error as? AppError {
            handleAppError(appError)
        }
    }

    func handleAppError(_ error: AppError) {
        capturedErrors.append(error)
        currentError = ErrorPresentation(from: error)
    }

    func clearError() {
        currentError = nil
    }

    func openSettings() {
        // Mock implementation
        clearError()
    }
}
