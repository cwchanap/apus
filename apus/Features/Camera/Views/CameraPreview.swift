//
//  CameraPreview.swift
//  apus
//
//  Created by Rovo Dev on 28/7/2025.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraManager
    
    func makeUIView(context: Context) -> FullScreenCameraView {
        let view = FullScreenCameraView()
        view.backgroundColor = .black
        view.setupCamera(session: camera.session)
        return view
    }
    
    func updateUIView(_ uiView: FullScreenCameraView, context: Context) {
        uiView.updateSession(camera.session)
    }
}

class FullScreenCameraView: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    func setupCamera(session: AVCaptureSession) {
        // Remove existing preview layer
        previewLayer?.removeFromSuperlayer()
        
        // Create new preview layer
        let newPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        newPreviewLayer.videoGravity = .resizeAspectFill
        
        // Add to view
        layer.addSublayer(newPreviewLayer)
        previewLayer = newPreviewLayer
        
        // Set initial frame
        updateLayerFrame()
    }
    
    func updateSession(_ session: AVCaptureSession) {
        previewLayer?.session = session
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerFrame()
    }
    
    private func updateLayerFrame() {
        // Force the preview layer to fill the entire view bounds
        previewLayer?.frame = bounds
    }
}