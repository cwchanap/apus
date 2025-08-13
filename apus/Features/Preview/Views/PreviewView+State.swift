//
//  PreviewView+State.swift
//  apus
//
//  Created by Rovo Dev on 5/8/2025.
//

import SwiftUI

// MARK: - PreviewView State Management Extension
extension PreviewView {

    // MARK: - State Properties
    struct PreviewState {
        // Classification state
        var classificationResults: [ClassificationResult] = []
        var showingClassificationResults = false
        var isClassifying = false
        var cachedClassificationResults: [ClassificationResult] = []
        var hasClassificationResults = false

        // Contour detection state
        var detectedContours: [DetectedContour] = []
        var showingContours = false
        var isDetectingContours = false
        var cachedContours: [DetectedContour] = []
        var hasDetectedContours = false

        // Object detection state
        var detectedObjects: [DetectedObject] = []
        var showingObjects = false
        var isDetectingObjects = false
        var cachedObjects: [DetectedObject] = []
        var hasDetectedObjects = false

        // Text recognition state
        var detectedTexts: [DetectedText] = []
        var showingTexts = false
        var isDetectingTexts = false
        var cachedTexts: [DetectedText] = []
        var hasDetectedTexts = false

        // UI state
        var showingAlert = false
        var alertMessage = ""
        var isSaved = false
        var showingHistory = false
    }

    // MARK: - Button Text Helpers
    func getClassificationButtonText() -> String {
        if showingClassificationResults {
            return "Hide Results"
        } else if hasClassificationResults {
            return "Show Results"
        } else {
            return "Classify"
        }
    }

    func getClassificationButtonColor() -> Color {
        if showingClassificationResults {
            return .orange  // Orange when showing
        } else if hasClassificationResults {
            return .blue    // Blue when cached (quick show)
        } else {
            return .green   // Green when needs classification
        }
    }

    func getObjectButtonText() -> String {
        if showingObjects {
            return "Hide Objects"
        } else if hasDetectedObjects {
            return "Show Objects"
        } else {
            return "Detect Objects"
        }
    }

    func getObjectButtonColor() -> Color {
        if showingObjects {
            return .orange  // Orange when showing
        } else if hasDetectedObjects {
            return .blue    // Blue when cached (quick show)
        } else {
            return .green   // Green when needs detection
        }
    }

    func getContourButtonText() -> String {
        if showingContours {
            return "Hide Contours"
        } else if hasDetectedContours {
            return "Show Contours"
        } else {
            return "Detect Contours"
        }
    }

    func getContourButtonColor() -> Color {
        if showingContours {
            return .orange  // Orange when showing
        } else if hasDetectedContours {
            return .blue    // Blue when cached (quick show)
        } else {
            return .green   // Green when needs detection
        }
    }

    func getTextRecognitionButtonText() -> String {
        if showingTexts {
            return "Hide OCR"
        } else if hasDetectedTexts {
            return "Show OCR"
        } else {
            return "OCR"
        }
    }

    func getTextRecognitionButtonColor() -> Color {
        if showingTexts {
            return .orange  // Orange when showing
        } else if hasDetectedTexts {
            return .blue    // Blue when cached (quick show)
        } else {
            return .green   // Green when needs detection
        }
    }
}
