//
//  PermissionService.swift
//  apus
//
//  Created by Rovo Dev on 28/7/2025.
//

import Foundation
import AVFoundation
import Photos
import Combine
import UIKit

// MARK: - Permission Types
enum PermissionType {
    case camera
    case photoLibrary
    case microphone
}

enum PermissionStatus {
    case authorized
    case denied
    case notDetermined
    case restricted

    var isAuthorized: Bool {
        return self == .authorized
    }
}

// MARK: - Permission Service Protocol
protocol PermissionServiceProtocol {
    func requestPermission(for type: PermissionType) -> AnyPublisher<PermissionStatus, Never>
    func getPermissionStatus(for type: PermissionType) -> PermissionStatus
    func openAppSettings()
}

// MARK: - Permission Service Implementation
class PermissionService: PermissionServiceProtocol {

    func requestPermission(for type: PermissionType) -> AnyPublisher<PermissionStatus, Never> {
        switch type {
        case .camera:
            return requestCameraPermission()
        case .photoLibrary:
            return requestPhotoLibraryPermission()
        case .microphone:
            return requestMicrophonePermission()
        }
    }

    func getPermissionStatus(for type: PermissionType) -> PermissionStatus {
        switch type {
        case .camera:
            return convertAVAuthorizationStatus(AVCaptureDevice.authorizationStatus(for: .video))
        case .photoLibrary:
            return convertPHAuthorizationStatus(PHPhotoLibrary.authorizationStatus(for: .addOnly))
        case .microphone:
            return convertAVAuthorizationStatus(AVCaptureDevice.authorizationStatus(for: .audio))
        }
    }

    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    // MARK: - Private Methods

    private func requestCameraPermission() -> AnyPublisher<PermissionStatus, Never> {
        Future<PermissionStatus, Never> { promise in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    let status: PermissionStatus = granted ? .authorized : .denied
                    promise(.success(status))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func requestPhotoLibraryPermission() -> AnyPublisher<PermissionStatus, Never> {
        Future<PermissionStatus, Never> { promise in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                DispatchQueue.main.async {
                    promise(.success(self.convertPHAuthorizationStatus(status)))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func requestMicrophonePermission() -> AnyPublisher<PermissionStatus, Never> {
        Future<PermissionStatus, Never> { promise in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    let status: PermissionStatus = granted ? .authorized : .denied
                    promise(.success(status))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func convertAVAuthorizationStatus(_ status: AVAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }

    private func convertPHAuthorizationStatus(_ status: PHAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .limited:
            return .authorized // Treat limited as authorized for our use case
        @unknown default:
            return .denied
        }
    }
}

// MARK: - Mock Permission Service for Testing
class MockPermissionService: PermissionServiceProtocol {
    var mockPermissions: [PermissionType: PermissionStatus] = [:]
    var shouldGrantPermissions = true

    func requestPermission(for type: PermissionType) -> AnyPublisher<PermissionStatus, Never> {
        let status: PermissionStatus = shouldGrantPermissions ? .authorized : .denied
        mockPermissions[type] = status
        return Just(status)
            .eraseToAnyPublisher()
    }

    func getPermissionStatus(for type: PermissionType) -> PermissionStatus {
        return mockPermissions[type] ?? .notDetermined
    }

    func openAppSettings() {
        // Mock implementation - do nothing
        print("Mock: Opening app settings")
    }
}
