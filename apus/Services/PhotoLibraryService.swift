//
//  PhotoLibraryService.swift
//  apus
//
//  Created by Rovo Dev on 28/7/2025.
//

import Foundation
import Photos
import UIKit
import Combine

// MARK: - Photo Library Service Protocol
protocol PhotoLibraryServiceProtocol {
    func requestPermission() -> AnyPublisher<Bool, Never>
    func saveImage(_ image: UIImage) -> AnyPublisher<Bool, PhotoLibraryError>
    func getPermissionStatus() -> PHAuthorizationStatus
}

// MARK: - Photo Library Errors
enum PhotoLibraryError: LocalizedError {
    case permissionDenied
    case saveFailed(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Photo library access denied. Please enable access in Settings."
        case .saveFailed(let error):
            return "Failed to save photo: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred while accessing the photo library."
        }
    }
}

// MARK: - Photo Library Service Implementation
class PhotoLibraryService: PhotoLibraryServiceProtocol {

    func requestPermission() -> AnyPublisher<Bool, Never> {
        Future<Bool, Never> { promise in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                DispatchQueue.main.async {
                    promise(.success(status == .authorized))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func saveImage(_ image: UIImage) -> AnyPublisher<Bool, PhotoLibraryError> {
        Future<Bool, PhotoLibraryError> { promise in
            // Check permission first
            let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
            guard status == .authorized else {
                promise(.failure(.permissionDenied))
                return
            }

            // Save the image
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAsset(from: image)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        promise(.success(true))
                    } else if let error = error {
                        promise(.failure(.saveFailed(error)))
                    } else {
                        promise(.failure(.unknown))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func getPermissionStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: .addOnly)
    }
}

// MARK: - Mock Photo Library Service for Testing
class MockPhotoLibraryService: PhotoLibraryServiceProtocol {
    var shouldSucceed = true
    var mockPermissionStatus: PHAuthorizationStatus = .authorized

    func requestPermission() -> AnyPublisher<Bool, Never> {
        Just(shouldSucceed)
            .eraseToAnyPublisher()
    }

    func saveImage(_ image: UIImage) -> AnyPublisher<Bool, PhotoLibraryError> {
        if shouldSucceed {
            return Just(true)
                .setFailureType(to: PhotoLibraryError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: PhotoLibraryError.saveFailed(NSError(domain: "MockError", code: 1)))
                .eraseToAnyPublisher()
        }
    }

    func getPermissionStatus() -> PHAuthorizationStatus {
        return mockPermissionStatus
    }
}
