//
//  PreviewView+UI.swift
//  apus
//
//  Created by Rovo Dev on 5/8/2025.
//

import SwiftUI

// MARK: - PreviewView UI Components Extension
extension PreviewView {
    
    // MARK: - Action Buttons View
    @ViewBuilder
    func actionButtonsView() -> some View {
        VStack(spacing: 12) {
            // First row: OCR + Classification and Object Detection
            HStack(spacing: 12) {
                // Classification button
                Button(action: {
                    hapticService.actionFeedback()
                    toggleClassification()
                }) {
                    HStack(spacing: 4) {
                        if isClassifying {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.7)
                            Text("Classifying...")
                                .font(.caption)
                        } else {
                            Image(systemName: showingClassificationResults ? "brain.head.profile.fill" : "brain.head.profile")
                                .font(.caption)
                            Text(getClassificationButtonText())
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(getClassificationButtonColor())
                    .clipShape(Capsule())
                }
                .disabled(isClassifying)
                
                // Object detection button
                Button(action: {
                    hapticService.actionFeedback()
                    toggleObjects()
                }) {
                    HStack(spacing: 4) {
                        if isDetectingObjects {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.7)
                            Text("Detecting...")
                                .font(.caption)
                        } else {
                            Image(systemName: showingObjects ? "viewfinder.circle.fill" : "viewfinder.circle")
                                .font(.caption)
                            Text(getObjectButtonText())
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(getObjectButtonColor())
                    .clipShape(Capsule())
                }
                .disabled(isDetectingObjects)
            }
            
            // Second row: Contour Detection
            HStack(spacing: 12) {
                // Contour detection button
                Button(action: {
                    hapticService.actionFeedback()
                    toggleContours()
                }) {
                    HStack(spacing: 4) {
                        if isDetectingContours {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.7)
                            Text("Detecting...")
                                .font(.caption)
                        } else {
                            Image(systemName: showingContours ? "eye.slash" : "eye")
                                .font(.caption)
                            Text(getContourButtonText())
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(getContourButtonColor())
                    .clipShape(Capsule())
                }
                .disabled(isDetectingContours)
                
                // Text recognition (OCR) button
                Button(action: {
                    hapticService.actionFeedback()
                    toggleTextRecognition()
                }) {
                    HStack(spacing: 4) {
                        if isDetectingTexts {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.7)
                            Text("Reading Text...")
                                .font(.caption)
                        } else {
                            Image(systemName: showingTexts ? "textformat.abc" : "textformat")
                                .font(.caption)
                            Text(getTextRecognitionButtonText())
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(getTextRecognitionButtonColor())
                    .clipShape(Capsule())
                }
                .disabled(isDetectingTexts)
                
                Spacer() // Fill remaining space
            }
        }
    }
    
    // MARK: - Bottom Controls View
    @ViewBuilder
    func bottomControlsView() -> some View {
        HStack(spacing: 20) {
            // Discard button
            Button(action: {
                hapticService.buttonTap()
                capturedImage = nil
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.title2)
                    Text("Discard")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.red)
                .clipShape(Capsule())
            }
            
            Spacer()
            
            // Save button
            Button(action: {
                hapticService.actionFeedback()
                saveImageToPhotoLibrary()
                if isSaved {
                    hapticService.success()
                    alertMessage = "Image saved to Photos"
                    showingAlert = true
                } else {
                    hapticService.error()
                    alertMessage = "Permission denied to save to Photos"
                    showingAlert = true
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                        .font(.title2)
                    Text(isSaved ? "Saved" : "Save")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(isSaved ? Color.green : Color.blue)
                .clipShape(Capsule())
            }
            .disabled(isSaved)
        }
    }
    
    // MARK: - Image Overlay View
    @ViewBuilder
    func imageOverlayView(image: UIImage, geometry: GeometryProxy) -> some View {
        ZStack {
            // Contour detection overlay
            if showingContours && !detectedContours.isEmpty {
                ContourOverlayView(
                    contours: detectedContours,
                    imageSize: image.size,
                    displaySize: geometry.size
                )
            }
            
            // Object detection overlay
            if showingObjects && !detectedObjects.isEmpty {
                UnifiedObjectDetectionOverlay(
                    detections: detectedObjects,
                    imageSize: image.size,
                    displaySize: geometry.size
                )
            }
            
            // Text recognition overlay
            if showingTexts && !detectedTexts.isEmpty {
                VisionTextRecognitionOverlay(
                    detectedTexts: detectedTexts,
                    imageSize: image.size,
                    displaySize: geometry.size
                )
            }
        }
    }
    
    // MARK: - Results Panel View
    @ViewBuilder
    func resultsPanelView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if showingClassificationResults && !classificationResults.isEmpty {
                Text("Classification Results")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(classificationResults.enumerated()), id: \.offset) { _, result in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.identifier)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                
                                Text("\(Int(result.confidence * 100))%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            // Results history button
            Button(action: {
                showingHistory = true
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.caption)
                    Text("View All Results")
                        .font(.caption)
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .clipShape(Capsule())
            }
        }
    }
}