
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

    var body: some View {
        VStack(spacing: 0) {
            // Image display area with zoom/pan functionality
            if let image = capturedImage {
                ZoomableImageView(image: image)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
            } else {
                Rectangle()
                    .fill(Color.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Classification results display
            if showingClassificationResults && !classificationResults.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Classification Results:")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    ForEach(classificationResults.prefix(3), id: \.identifier) { result in
                        HStack {
                            Text(result.identifier.capitalized)
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(Int(result.confidence * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 16)
            }
            
            // Action buttons in a single row
            HStack(spacing: 20) {
                // Classify button
                Button(action: {
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
            .padding(.horizontal, 20)
            .padding(.top, showingClassificationResults && !classificationResults.isEmpty ? 16 : 20)
            .padding(.bottom, 34) // Safe area bottom padding
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
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
                            alertMessage = "Photo saved to gallery!"
                            isSaved = true
                        } else {
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
