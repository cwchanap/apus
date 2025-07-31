//
//  AppSettings.swift
//  apus
//
//  Created by Rovo Dev on 29/7/2025.
//

import Foundation

/// Centralized app settings management
class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var isObjectDetectionEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isObjectDetectionEnabled, forKey: "isObjectDetectionEnabled")
        }
    }
    
    private init() {
        // Load saved setting or default to true
        self.isObjectDetectionEnabled = UserDefaults.standard.object(forKey: "isObjectDetectionEnabled") as? Bool ?? true
    }
    
    func resetToDefaults() {
        isObjectDetectionEnabled = true
    }
}

/// UserDefaults keys for settings
extension UserDefaults {
    enum Keys {
        static let isObjectDetectionEnabled = "isObjectDetectionEnabled"
    }
}