//
//  HapticService.swift
//  apus
//
//  Created by Rovo Dev on 30/7/2025.
//

import UIKit

protocol HapticServiceProtocol {
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle)
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType)
    func selection()
    
    // Convenience methods
    func buttonTap()
    func actionFeedback()
    func strongFeedback()
    func success()
    func warning()
    func error()
    func selectionChanged()
}

class HapticService: HapticServiceProtocol {
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    init() {
        // Prepare generators for better performance
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        case .soft:
            impactLight.impactOccurred() // Use light for soft
        case .rigid:
            impactHeavy.impactOccurred() // Use heavy for rigid
        @unknown default:
            impactMedium.impactOccurred()
        }
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(type)
    }
    
    func selection() {
        selectionGenerator.selectionChanged()
    }
}

// Mock implementation for testing
#if DEBUG
class MockHapticService: HapticServiceProtocol {
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        print("Mock haptic impact: \(style)")
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        print("Mock haptic notification: \(type)")
    }
    
    func selection() {
        print("Mock haptic selection")
    }
    
    // Convenience methods
    func buttonTap() {
        print("Mock haptic button tap")
    }
    
    func actionFeedback() {
        print("Mock haptic action feedback")
    }
    
    func strongFeedback() {
        print("Mock haptic strong feedback")
    }
    
    func success() {
        print("Mock haptic success")
    }
    
    func warning() {
        print("Mock haptic warning")
    }
    
    func error() {
        print("Mock haptic error")
    }
    
    func selectionChanged() {
        print("Mock haptic selection changed")
    }
}
#endif

// Convenience extension for common haptic patterns
extension HapticService {
    /// Light haptic for UI interactions like button taps
    func buttonTap() {
        impact(.light)
    }
    
    /// Medium haptic for important actions
    func actionFeedback() {
        impact(.medium)
    }
    
    /// Heavy haptic for significant events
    func strongFeedback() {
        impact(.heavy)
    }
    
    /// Success haptic for completed actions
    func success() {
        notification(.success)
    }
    
    /// Warning haptic for cautionary actions
    func warning() {
        notification(.warning)
    }
    
    /// Error haptic for failed actions
    func error() {
        notification(.error)
    }
    
    /// Selection haptic for picker/segmented controls
    func selectionChanged() {
        selection()
    }
}