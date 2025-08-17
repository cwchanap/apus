//
//  SettingsViewModel.swift
//  apus
//
//  Created by Rovo Dev on 29/7/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Settings Reference
    @ObservedObject private var appSettings = AppSettings.shared

    // MARK: - Published Properties (for direct binding)
    @Published var isRealTimeObjectDetectionEnabled: Bool = true
    @Published var isRealTimeBarcodeDetectionEnabled: Bool = true
    @Published var objectDetectionFramework: ObjectDetectionFramework = .vision

    // MARK: - Initialization
    init() {
        // Initialize with current settings
        self.isRealTimeObjectDetectionEnabled = appSettings.isRealTimeObjectDetectionEnabled
        self.isRealTimeBarcodeDetectionEnabled = appSettings.isRealTimeBarcodeDetectionEnabled
        self.objectDetectionFramework = appSettings.objectDetectionFramework

        // Set up two-way binding
        setupBindings()
    }

    private func setupBindings() {
        // Update ViewModel when AppSettings changes (but avoid loops)
        appSettings.$isRealTimeObjectDetectionEnabled
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.isRealTimeObjectDetectionEnabled != newValue {
                    self?.isRealTimeObjectDetectionEnabled = newValue
                }
            }
            .store(in: &cancellables)

        appSettings.$isRealTimeBarcodeDetectionEnabled
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.isRealTimeBarcodeDetectionEnabled != newValue {
                    self?.isRealTimeBarcodeDetectionEnabled = newValue
                }
            }
            .store(in: &cancellables)

        appSettings.$objectDetectionFramework
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.objectDetectionFramework != newValue {
                    self?.objectDetectionFramework = newValue
                }
            }
            .store(in: &cancellables)

        // Update AppSettings when ViewModel changes (but avoid loops)
        $isRealTimeObjectDetectionEnabled
            .dropFirst() // Skip initial value
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.appSettings.isRealTimeObjectDetectionEnabled != newValue {
                    self?.appSettings.isRealTimeObjectDetectionEnabled = newValue
                }
                // When enabling real-time detection, proactively preload heavy models off-main
                if newValue {
                    DispatchQueue.global(qos: .utility).async {
                        let manager: ObjectDetectionProtocol = DIContainer.shared.resolve(ObjectDetectionProtocol.self)
                        manager.preload()
                    }
                }
            }
            .store(in: &cancellables)

        $isRealTimeBarcodeDetectionEnabled
            .dropFirst() // Skip initial value
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.appSettings.isRealTimeBarcodeDetectionEnabled != newValue {
                    self?.appSettings.isRealTimeBarcodeDetectionEnabled = newValue
                }
            }
            .store(in: &cancellables)

        $objectDetectionFramework
            .dropFirst() // Skip initial value
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.appSettings.objectDetectionFramework != newValue {
                    self?.appSettings.objectDetectionFramework = newValue
                }
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Methods
    func resetToDefaults() {
        appSettings.resetToDefaults()
    }

    func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
