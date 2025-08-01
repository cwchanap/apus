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
                CameraPreview(camera: viewModel.concreteCameraManager)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                // Object detection overlay - fill entire screen
                ObjectDetectionOverlay(detections: viewModel.detections)
                
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
