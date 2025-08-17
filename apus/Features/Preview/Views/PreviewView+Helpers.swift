//
//  PreviewView+Helpers.swift
//  apus
//
//  Created by Rovo Dev on 5/8/2025.
//

import SwiftUI
import Photos

// MARK: - PreviewView Helper Methods Extension
extension PreviewView {

    // MARK: - Image Processing Helpers
    var displayImage: UIImage? {
        capturedImage?.preparedForDisplay()
    }

    var processingImage: UIImage? {
        capturedImage?.preparedForProcessing()
    }

    // MARK: - Photo Library Helpers
    func saveImageToPhotoLibrary() {
        guard let image = capturedImage else { return }

        // hapticService.actionFeedback() // Will be called from main view

        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    self.isSaved = true
                    // self.hapticService.success() // Will be handled in main view
                    // Success will be handled in main view
                } else {
                    // self.hapticService.error() // Will be handled in main view
                    // Error will be handled in main view
                }
            }
        }
    }

    // Text enhancement removed as OCR and image classification are separate workflows.

    // MARK: - Reset Helpers
    func resetAllDetections() {
        // Reset classification
        showingClassificationResults = false
        classificationResults = []
        hasClassificationResults = false
        cachedClassificationResults = []

        // Reset contours
        showingContours = false
        detectedContours = []
        hasDetectedContours = false
        cachedContours = []

        // Reset objects
        showingObjects = false
        detectedObjects = []
        hasDetectedObjects = false
        cachedObjects = []

        // Reset texts
        showingTexts = false
        detectedTexts = []
        hasDetectedTexts = false
        cachedTexts = []

        // Reset barcodes
        showingBarcodes = false
        detectedBarcodes = []
        hasDetectedBarcodes = false
        cachedBarcodes = []
    }

    // MARK: - Button Text Helpers
    func getClassificationButtonText() -> String {
        if showingClassificationResults {
            return "Hide Classification"
        } else if hasClassificationResults {
            return "Show Classification"
        } else {
            return "Run Classification"
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

    func getContourButtonText() -> String {
        if showingContours {
            return "Hide Contours"
        } else if hasDetectedContours {
            return "Show Contours"
        } else {
            return "Detect Contours"
        }
    }

    func getTextRecognitionButtonText() -> String {
        if showingTexts {
            return "Hide Text"
        } else if hasDetectedTexts {
            return "Show Text"
        } else {
            return "Read Text (OCR)"
        }
    }

    func getBarcodeButtonText() -> String {
        if showingBarcodes {
            return "Hide Barcodes"
        } else if hasDetectedBarcodes {
            return "Show Barcodes"
        } else {
            return "Detect Barcodes"
        }
    }

    // MARK: - Button Color Helpers
    func getClassificationButtonColor() -> Color {
        if isClassifying {
            return .gray
        } else if showingClassificationResults {
            return .blue
        } else {
            return .green
        }
    }

    func getObjectButtonColor() -> Color {
        if isDetectingObjects {
            return .gray
        } else if showingObjects {
            return .blue
        } else {
            return .orange
        }
    }

    func getContourButtonColor() -> Color {
        if isDetectingContours {
            return .gray
        } else if showingContours {
            return .blue
        } else {
            return .purple
        }
    }

    func getTextRecognitionButtonColor() -> Color {
        if isDetectingTexts {
            return .gray
        } else if showingTexts {
            return .blue
        } else {
            return .purple
        }
    }

    func getBarcodeButtonColor() -> Color {
        if isDetectingBarcodes {
            return .gray
        } else if showingBarcodes {
            return .blue
        } else {
            return .red
        }
    }
}
