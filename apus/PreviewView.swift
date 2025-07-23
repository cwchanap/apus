
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

    var body: some View {
        ZStack {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
            }

            VStack {
                Spacer()
                HStack(spacing: 60) {
                    Button(action: {
                        capturedImage = nil
                    }) {
                        Text("Discard")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Capsule())
                    }

                    Button(action: {
                        if let image = capturedImage {
                            saveImageToPhotos(image)
                        }
                    }) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Photo", isPresented: $showingAlert) {
            Button("OK") {
                if isSaved {
                    capturedImage = nil
                }
            }
        } message: {
            Text(alertMessage)
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
