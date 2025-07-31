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
    @Published var isObjectDetectionEnabled: Bool = true
    
    // MARK: - Initialization
    init() {
        // Initialize with current setting
        self.isObjectDetectionEnabled = appSettings.isObjectDetectionEnabled
        
        // Set up two-way binding
        setupBindings()
    }
    
    private func setupBindings() {
        // Update ViewModel when AppSettings changes (but avoid loops)
        appSettings.$isObjectDetectionEnabled
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.isObjectDetectionEnabled != newValue {
                    self?.isObjectDetectionEnabled = newValue
                }
            }
            .store(in: &cancellables)
        
        // Update AppSettings when ViewModel changes (but avoid loops)
        $isObjectDetectionEnabled
            .dropFirst() // Skip initial value
            .removeDuplicates()
            .sink { [weak self] newValue in
                if self?.appSettings.isObjectDetectionEnabled != newValue {
                    self?.appSettings.isObjectDetectionEnabled = newValue
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