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
    
    // Storage limits - published for UI updates
    @Published var ocrResultsLimit: Int = 10
    @Published var objectDetectionResultsLimit: Int = 10
    @Published var classificationResultsLimit: Int = 10
    @Published var contourDetectionResultsLimit: Int = 10
    @Published var barcodeDetectionResultsLimit: Int = 10

    // MARK: - Initialization
    init() {
        // Initialize with current settings (fast, no heavy operations)
        self.isRealTimeObjectDetectionEnabled = appSettings.isRealTimeObjectDetectionEnabled
        self.isRealTimeBarcodeDetectionEnabled = appSettings.isRealTimeBarcodeDetectionEnabled
        self.objectDetectionFramework = appSettings.objectDetectionFramework
        
        // Initialize storage limits
        self.ocrResultsLimit = appSettings.ocrResultsLimit
        self.objectDetectionResultsLimit = appSettings.objectDetectionResultsLimit
        self.classificationResultsLimit = appSettings.classificationResultsLimit
        self.contourDetectionResultsLimit = appSettings.contourDetectionResultsLimit
        self.barcodeDetectionResultsLimit = appSettings.barcodeDetectionResultsLimit

        // Defer binding setup to avoid blocking main thread during init
        Task { @MainActor in
            setupBindings()
        }
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
                // When enabling real-time detection, preload models asynchronously
                if newValue {
                    self?.preloadModelsInBackground()
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

        // Bindings for storage limits - AppSettings to ViewModel
        appSettings.$ocrResultsLimit
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.ocrResultsLimit != newValue {
                    self?.ocrResultsLimit = newValue
                }
            }
            .store(in: &cancellables)

        appSettings.$objectDetectionResultsLimit
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.objectDetectionResultsLimit != newValue {
                    self?.objectDetectionResultsLimit = newValue
                }
            }
            .store(in: &cancellables)

        appSettings.$classificationResultsLimit
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.classificationResultsLimit != newValue {
                    self?.classificationResultsLimit = newValue
                }
            }
            .store(in: &cancellables)

        appSettings.$contourDetectionResultsLimit
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.contourDetectionResultsLimit != newValue {
                    self?.contourDetectionResultsLimit = newValue
                }
            }
            .store(in: &cancellables)

        appSettings.$barcodeDetectionResultsLimit
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.barcodeDetectionResultsLimit != newValue {
                    self?.barcodeDetectionResultsLimit = newValue
                }
            }
            .store(in: &cancellables)

        // Bindings for storage limits - ViewModel to AppSettings
        $ocrResultsLimit
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.appSettings.ocrResultsLimit != newValue {
                    self?.appSettings.ocrResultsLimit = newValue
                }
            }
            .store(in: &cancellables)

        $objectDetectionResultsLimit
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.appSettings.objectDetectionResultsLimit != newValue {
                    self?.appSettings.objectDetectionResultsLimit = newValue
                }
            }
            .store(in: &cancellables)

        $classificationResultsLimit
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.appSettings.classificationResultsLimit != newValue {
                    self?.appSettings.classificationResultsLimit = newValue
                }
            }
            .store(in: &cancellables)

        $contourDetectionResultsLimit
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.appSettings.contourDetectionResultsLimit != newValue {
                    self?.appSettings.contourDetectionResultsLimit = newValue
                }
            }
            .store(in: &cancellables)

        $barcodeDetectionResultsLimit
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.appSettings.barcodeDetectionResultsLimit != newValue {
                    self?.appSettings.barcodeDetectionResultsLimit = newValue
                }
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Private Methods
    private func preloadModelsInBackground() {
        // Use Task to avoid blocking main thread with DI resolution
        Task.detached(priority: .utility) {
            do {
                // Resolve DI on background thread to avoid main thread blocking
                let manager: ObjectDetectionProtocol = DIContainer.shared.resolve(ObjectDetectionProtocol.self)
                manager.preload()
            } catch {
                print("Failed to preload models: \(error)")
            }
        }
    }

    // MARK: - Public Methods
    func resetToDefaults() {
        appSettings.resetToDefaults()
    }

    func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    // MARK: - Storage Limit Methods
    func getStorageLimit(for category: DetectionCategory) -> Int {
        switch category {
        case .ocr:
            return ocrResultsLimit
        case .objectDetection:
            return objectDetectionResultsLimit
        case .classification:
            return classificationResultsLimit
        case .contourDetection:
            return contourDetectionResultsLimit
        case .barcode:
            return barcodeDetectionResultsLimit
        }
    }
    
    func setStorageLimit(for category: DetectionCategory, limit: Int) {
        let clampedLimit = max(1, min(100, limit))
        switch category {
        case .ocr:
            ocrResultsLimit = clampedLimit
        case .objectDetection:
            objectDetectionResultsLimit = clampedLimit
        case .classification:
            classificationResultsLimit = clampedLimit
        case .contourDetection:
            contourDetectionResultsLimit = clampedLimit
        case .barcode:
            barcodeDetectionResultsLimit = clampedLimit
        }
    }
}
