//
//  CameraView.swift
//  apus
//
//  Created by Chan Wai Chan on 29/6/2025.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Camera preview - fill entire screen
                Group {
                    if let cameraManager = viewModel.concreteCameraManager {
                        CameraPreview(camera: cameraManager)
                    } else {
                        Text("Camera not available")
                            .foregroundColor(.white)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()

                // Object detection overlay - fill entire screen
                ObjectDetectionOverlay(detections: viewModel.detections)

                // Barcode detection overlay
                if viewModel.isRealTimeBarcodeDetectionEnabled {
                    BarcodeOverlayView(barcodes: viewModel.detectedBarcodes, imageSize: viewModel.imageSize, displaySize: geometry.size)
                }

                // Camera controls - respect safe areas for interaction
                CameraControlsView(viewModel: viewModel)
            }
        }
        .ignoresSafeArea(.all, edges: .all) // Make the entire view fill the screen
        .navigationBarHidden(true) // Hide navigation bar if present
        .onAppear {
            viewModel.startCamera()
        }
        .onDisappear {
            viewModel.stopCamera()
        }
        .sheet(isPresented: $viewModel.showingImagePicker) {
            ImagePicker(selectedImage: $viewModel.capturedImage)
        }
        .fullScreenCover(isPresented: viewModel.isShowingPreview) {
            NavigationView {
                PreviewView(capturedImage: $viewModel.capturedImage)
            }
        }
    }
}

#Preview {
    CameraView()
}
