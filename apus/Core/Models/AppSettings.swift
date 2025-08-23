//
//  AppSettings.swift
//  apus
//
//  Created by Rovo Dev on 29/7/2025.
//

import Foundation
import SwiftUI

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

/// Detection Category Enum
enum DetectionCategory: String, CaseIterable, Hashable {
    case ocr = "OCR"
    case objectDetection = "Object Detection"
    case classification = "Classification"
    case contourDetection = "Contour Detection"
    case barcode = "Barcode"

    var icon: String {
        switch self {
        case .ocr:
            return "textformat"
        case .objectDetection:
            return "viewfinder"
        case .classification:
            return "brain.head.profile"
        case .contourDetection:
            return "square.dashed"
        case .barcode:
            return "barcode.viewfinder"
        }
    }

    var color: Color {
        switch self {
        case .ocr:
            return .purple
        case .objectDetection:
            return .blue
        case .classification:
            return .green
        case .contourDetection:
            return .orange
        case .barcode:
            return .red
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

    @Published var ocrResultsLimit: Int {
        didSet {
            UserDefaults.standard.set(ocrResultsLimit, forKey: UserDefaults.Keys.ocrResultsLimit)
        }
    }

    @Published var objectDetectionResultsLimit: Int {
        didSet {
            UserDefaults.standard.set(objectDetectionResultsLimit, forKey: UserDefaults.Keys.objectDetectionResultsLimit)
        }
    }

    @Published var classificationResultsLimit: Int {
        didSet {
            UserDefaults.standard.set(classificationResultsLimit, forKey: UserDefaults.Keys.classificationResultsLimit)
        }
    }

    @Published var contourDetectionResultsLimit: Int {
        didSet {
            UserDefaults.standard.set(contourDetectionResultsLimit, forKey: UserDefaults.Keys.contourDetectionResultsLimit)
        }
    }

    @Published var barcodeDetectionResultsLimit: Int {
        didSet {
            UserDefaults.standard.set(barcodeDetectionResultsLimit, forKey: UserDefaults.Keys.barcodeDetectionResultsLimit)
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

        // Load storage limits with default of 10 for all categories
        self.ocrResultsLimit = defaults.object(forKey: UserDefaults.Keys.ocrResultsLimit) != nil ?
            defaults.integer(forKey: UserDefaults.Keys.ocrResultsLimit) : 10

        self.objectDetectionResultsLimit = defaults.object(forKey: UserDefaults.Keys.objectDetectionResultsLimit) != nil ?
            defaults.integer(forKey: UserDefaults.Keys.objectDetectionResultsLimit) : 10

        self.classificationResultsLimit = defaults.object(forKey: UserDefaults.Keys.classificationResultsLimit) != nil ?
            defaults.integer(forKey: UserDefaults.Keys.classificationResultsLimit) : 10

        self.contourDetectionResultsLimit = defaults.object(forKey: UserDefaults.Keys.contourDetectionResultsLimit) != nil ?
            defaults.integer(forKey: UserDefaults.Keys.contourDetectionResultsLimit) : 10

        self.barcodeDetectionResultsLimit = defaults.object(forKey: UserDefaults.Keys.barcodeDetectionResultsLimit) != nil ?
            defaults.integer(forKey: UserDefaults.Keys.barcodeDetectionResultsLimit) : 10
    }

    func resetToDefaults() {
        isRealTimeObjectDetectionEnabled = true
        isRealTimeBarcodeDetectionEnabled = true
        objectDetectionFramework = .vision
        ocrResultsLimit = 10
        objectDetectionResultsLimit = 10
        classificationResultsLimit = 10
        contourDetectionResultsLimit = 10
        barcodeDetectionResultsLimit = 10
    }

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
        let clampedLimit = max(1, min(100, limit)) // Limit between 1 and 100
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

/// UserDefaults keys for settings
extension UserDefaults {
    enum Keys {
        static let isRealTimeObjectDetectionEnabled = "isRealTimeObjectDetectionEnabled"
        static let isRealTimeBarcodeDetectionEnabled = "isRealTimeBarcodeDetectionEnabled"
        static let objectDetectionFramework = "objectDetectionFramework"
        static let ocrResultsLimit = "ocrResultsLimit"
        static let objectDetectionResultsLimit = "objectDetectionResultsLimit"
        static let classificationResultsLimit = "classificationResultsLimit"
        static let contourDetectionResultsLimit = "contourDetectionResultsLimit"
        static let barcodeDetectionResultsLimit = "barcodeDetectionResultsLimit"
    }
}
