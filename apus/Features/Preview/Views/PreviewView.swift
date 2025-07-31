
//
//  PreviewView.swift
//  apus
//
//  Created by Chan Wai Chan on 21/7/2025.
//

import SwiftUI
import Photos

struct PreviewView: View {
    @Binding var capturedImage: UIImage?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSaved = false
    @State private var classificationResults: [ClassificationResult] = []
    @State private var showingClassificationResults = false
    @State private var isClassifying = false
    @State private var showingHistory = false
    
    @Injected private var imageClassificationManager: ImageClassificationProtocol
    @Injected private var historyManager: ClassificationHistoryManager
    @Injected private var hapticService: HapticServiceProtocol

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Image display area with zoom/pan functionality - fixed height
                ZStack {
                    if let image = capturedImage {
                        ZoomableImageView(image: image)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                    } else {
                        Rectangle()
                            .fill(Color.black)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    // Classification results overlay
                    if showingClassificationResults && !classificationResults.isEmpty {
                        VStack {
                            Spacer()
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Classification Results:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ForEach(classificationResults.prefix(3), id: \.identifier) { result in
                                    HStack {
                                        Text(result.identifier.capitalized)
                                            .font(.body)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(Int(result.confidence * 100))%")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
                .frame(height: geometry.size.height - 120) // Reserve space for buttons
                
                // Action buttons in a single row - fixed height
                HStack(spacing: 20) {
                    // Classify button
                    Button(action: {
                        hapticService.actionFeedback()
                        classifyImage()
                    }) {
                        HStack(spacing: 6) {
                            if isClassifying {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("Classifying...")
                            } else {
                                Image(systemName: "brain.head.profile")
                                Text("Classify")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.purple)
                        .clipShape(Capsule())
                    }
                    .disabled(isClassifying)
                    
                    // Discard button
                    Button(action: {
                        hapticService.buttonTap()
                        capturedImage = nil
                    }) {
                        Text("Discard")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Capsule())
                    }
                    
                    // Save button
                    Button(action: {
                        hapticService.actionFeedback()
                        if let image = capturedImage {
                            saveImageToPhotos(image)
                        }
                    }) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
                .frame(height: 120) // Fixed height for button area
                .padding(.horizontal, 20)
                .background(Color(.systemBackground))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    hapticService.buttonTap()
                    showingHistory = true
                }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.primary)
                }
            }
        }
        .alert("Photo", isPresented: $showingAlert) {
            Button("OK") {
                if isSaved {
                    capturedImage = nil
                }
            }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingHistory) {
            ClassificationHistoryView()
        }
    }

    private func classifyImage() {
        guard let image = capturedImage else { return }
        
        isClassifying = true
        showingClassificationResults = false
        
        imageClassificationManager.classifyImage(image) { result in
            DispatchQueue.main.async {
                self.isClassifying = false
                
                switch result {
                case .success(let results):
                    self.classificationResults = results
                    self.showingClassificationResults = true
                    self.hapticService.success() // Success haptic feedback
                    
                    // Save to history if we have results and an image
                    if !results.isEmpty, let image = self.capturedImage {
                        let historyItem = ClassificationHistoryItem(results: results, image: image)
                        Task { @MainActor in
                            self.historyManager.addHistoryItem(historyItem)
                        }
                    }
                    
                case .failure(let error):
                    self.alertMessage = "Classification failed: \(error.localizedDescription)"
                    self.showingAlert = true
                    self.hapticService.error() // Error haptic feedback
                }
            }
        }
    }
    
    private func saveImageToPhotos(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCreationRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            self.hapticService.success() // Success haptic for save
                            alertMessage = "Photo saved to gallery!"
                            isSaved = true
                        } else {
                            self.hapticService.error() // Error haptic for save failure
                            alertMessage = "Failed to save photo: \(error?.localizedDescription ?? "Unknown error")"
                            isSaved = false
                        }
                        showingAlert = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    alertMessage = "Photo library access denied"
                    isSaved = false
                    showingAlert = true
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    struct PreviewWrapper: View {
        @State var image: UIImage? = UIImage(systemName: "camera")
        var body: some View {
            NavigationView {
                PreviewView(capturedImage: $image)
            }
        }
    }
    return PreviewWrapper()
}
#endif
