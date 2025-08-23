//
//  PreviewView+UI.swift
//  apus
//
//  Created by Rovo Dev on 5/8/2025.
//

import SwiftUI

// MARK: - PreviewView UI Components Extension
extension PreviewView {

    // MARK: - Classification Results Overlay
    @ViewBuilder
    func classificationResultsOverlayView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Classification")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    withAnimation { showingClassificationResults = false }
                }) {
                    Label("Hide", systemImage: "xmark.circle.fill")
                        .labelStyle(.iconOnly)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(classificationResults.enumerated()), id: \.offset) { _, result in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.identifier)
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .lineLimit(2)
                            Text("\(Int(result.confidence * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 12)
        .padding(.bottom, 68) // keep above the Actions bar
        .shadow(radius: 2)
    }

    // MARK: - Actions Sheet View (Popup)
    @ViewBuilder
    func actionsSheetView(showSheet: Binding<Bool>) -> some View {
        NavigationStack {
            List {
                analysisSection(showSheet: showSheet)
                photoSection(showSheet: showSheet)
                resultsSection(showSheet: showSheet)
            }
            .navigationTitle("Actions")
            .navigationBarTitleDisplayMode(.inline)
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

            // Barcode detection overlay
            if showingBarcodes && !detectedBarcodes.isEmpty {
                BarcodeOverlayView(
                    barcodes: detectedBarcodes,
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

    // MARK: - Action Sheet Sections
    @ViewBuilder
    private func analysisSection(showSheet: Binding<Bool>) -> some View {
        Section(header: Text("Analysis")) {
            analysisButton(
                icon: "brain.head.profile",
                title: isClassifying ? "Classifying…" : getClassificationButtonText(),
                disabled: isClassifying,
                action: { toggleClassification() },
                showSheet: showSheet
            )

            analysisButton(
                icon: "viewfinder.circle",
                title: isDetectingObjects ? "Detecting…" : getObjectButtonText(),
                disabled: isDetectingObjects,
                action: { toggleObjects() },
                showSheet: showSheet
            )

            analysisButton(
                icon: "eye",
                title: isDetectingContours ? "Detecting…" : getContourButtonText(),
                disabled: isDetectingContours,
                action: { toggleContours() },
                showSheet: showSheet
            )

            analysisButton(
                icon: "textformat",
                title: isDetectingTexts ? "Reading Text…" : getTextRecognitionButtonText(),
                disabled: isDetectingTexts,
                action: { toggleTextRecognition() },
                showSheet: showSheet
            )

            analysisButton(
                icon: "barcode.viewfinder",
                title: isDetectingBarcodes ? "Detecting…" : getBarcodeButtonText(),
                disabled: isDetectingBarcodes,
                action: { toggleBarcodes() },
                showSheet: showSheet
            )
        }
    }

    @ViewBuilder
    private func photoSection(showSheet: Binding<Bool>) -> some View {
        Section(header: Text("Photo")) {
            Button {
                hapticService.actionFeedback()
                saveImageToPhotoLibrary()
                handleSaveResult()
                showSheet.wrappedValue = false
            } label: {
                HStack {
                    Image(systemName: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                        .foregroundColor(isSaved ? .green : .accentColor)
                    Text(isSaved ? "Saved" : "Save Photo")
                    Spacer()
                }
            }
            .disabled(isSaved)

            Button(role: .destructive) {
                hapticService.buttonTap()
                capturedImage = nil
                showSheet.wrappedValue = false
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                    Text("Discard Photo")
                    Spacer()
                }
            }
        }
    }

    @ViewBuilder
    private func resultsSection(showSheet: Binding<Bool>) -> some View {
        Section(header: Text("Results")) {
            Button {
                showSheet.wrappedValue = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showingHistory = true
                }
            } label: {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.accentColor)
                    Text("View All Results")
                    Spacer()
                }
            }

            Button {
                resetAllDetections()
                showSheet.wrappedValue = false
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundColor(.accentColor)
                    Text("Reset Overlays")
                    Spacer()
                }
            }
        }
    }

    @ViewBuilder
    private func analysisButton(
        icon: String,
        title: String,
        disabled: Bool,
        action: @escaping () -> Void,
        showSheet: Binding<Bool>
    ) -> some View {
        Button {
            hapticService.actionFeedback()
            action()
            showSheet.wrappedValue = false
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                Text(title)
                Spacer()
            }
        }
        .disabled(disabled)
    }

    private func handleSaveResult() {
        if isSaved {
            hapticService.success()
            alertMessage = "Image saved to Photos"
            showingAlert = true
        } else {
            hapticService.error()
            alertMessage = "Permission denied to save to Photos"
            showingAlert = true
        }
    }
}
