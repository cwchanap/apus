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

    @Published var isRealTimeObjectDetectionEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isRealTimeObjectDetectionEnabled, forKey: UserDefaults.Keys.isRealTimeObjectDetectionEnabled)
        }
    }

    @Published var isRealTimeBarcodeDetectionEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isRealTimeBarcodeDetectionEnabled, forKey: UserDefaults.Keys.isRealTimeBarcodeDetectionEnabled)
        }
    }

    @Published var objectDetectionFramework: ObjectDetectionFramework {
        didSet {
            UserDefaults.standard.set(objectDetectionFramework.rawValue, forKey: UserDefaults.Keys.objectDetectionFramework)
        }
    }

    private init() {
        // Load saved settings or defaults (optimized for performance)
        let defaults = UserDefaults.standard
        
        // Use bool(forKey:) which is faster than object(forKey:)
        self.isRealTimeObjectDetectionEnabled = defaults.object(forKey: UserDefaults.Keys.isRealTimeObjectDetectionEnabled) != nil ? 
            defaults.bool(forKey: UserDefaults.Keys.isRealTimeObjectDetectionEnabled) : true
        
        self.isRealTimeBarcodeDetectionEnabled = defaults.object(forKey: UserDefaults.Keys.isRealTimeBarcodeDetectionEnabled) != nil ? 
            defaults.bool(forKey: UserDefaults.Keys.isRealTimeBarcodeDetectionEnabled) : true

        let frameworkRawValue = defaults.string(forKey: UserDefaults.Keys.objectDetectionFramework) ?? ObjectDetectionFramework.vision.rawValue
        self.objectDetectionFramework = ObjectDetectionFramework(rawValue: frameworkRawValue) ?? .vision
    }

    func resetToDefaults() {
        isRealTimeObjectDetectionEnabled = true
        isRealTimeBarcodeDetectionEnabled = true
        objectDetectionFramework = .vision
    }
}

/// UserDefaults keys for settings
extension UserDefaults {
    enum Keys {
        static let isRealTimeObjectDetectionEnabled = "isRealTimeObjectDetectionEnabled"
        static let isRealTimeBarcodeDetectionEnabled = "isRealTimeBarcodeDetectionEnabled"
        static let objectDetectionFramework = "objectDetectionFramework"
    }
}
