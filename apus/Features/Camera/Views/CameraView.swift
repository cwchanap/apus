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
        ZStack {
            // Camera preview
            CameraPreview(camera: viewModel.concreteCameraManager)
                .ignoresSafeArea()
            
            // Object detection overlay
            ObjectDetectionOverlay(detections: viewModel.detections)
                .ignoresSafeArea()
            
            // Camera controls
            CameraControlsView(viewModel: viewModel)
        }
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
