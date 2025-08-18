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

    // Button text and color helpers moved to PreviewView+Helpers.swift to avoid duplication
}
