//
//  AppSettings.swift
//  apus
//
//  Created by Rovo Dev on 29/7/2025.
//

import Foundation

/// Object detection framework options
enum ObjectDetectionFramework: String, CaseIterable {
    case vision = "vision"
    case tensorflowLite = "tensorflow_lite"
    
    var displayName: String {
        switch self {
        case .vision:
            return "Apple Vision"
        case .tensorflowLite:
            return "TensorFlow Lite"
        }
    }
    
    var description: String {
        switch self {
        case .vision:
            return "Native iOS framework with optimized performance"
        case .tensorflowLite:
            return "Google's lightweight ML framework"
        }
    }
    
    var icon: String {
        switch self {
        case .vision:
            return "eye.circle"
        case .tensorflowLite:
            return "cpu.fill"
        }
    }
}

/// Centralized app settings management
class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var isObjectDetectionEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isObjectDetectionEnabled, forKey: UserDefaults.Keys.isObjectDetectionEnabled)
        }
    }
    
    @Published var objectDetectionFramework: ObjectDetectionFramework {
        didSet {
            UserDefaults.standard.set(objectDetectionFramework.rawValue, forKey: UserDefaults.Keys.objectDetectionFramework)
        }
    }
    
    private init() {
        // Load saved settings or defaults
        self.isObjectDetectionEnabled = UserDefaults.standard.object(forKey: UserDefaults.Keys.isObjectDetectionEnabled) as? Bool ?? true
        
        let frameworkRawValue = UserDefaults.standard.string(forKey: UserDefaults.Keys.objectDetectionFramework) ?? ObjectDetectionFramework.vision.rawValue
        self.objectDetectionFramework = ObjectDetectionFramework(rawValue: frameworkRawValue) ?? .vision
    }
    
    func resetToDefaults() {
        isObjectDetectionEnabled = true
        objectDetectionFramework = .vision
    }
}

/// UserDefaults keys for settings
extension UserDefaults {
    enum Keys {
        static let isObjectDetectionEnabled = "isObjectDetectionEnabled"
        static let objectDetectionFramework = "objectDetectionFramework"
    }
}