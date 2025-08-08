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
    }
}