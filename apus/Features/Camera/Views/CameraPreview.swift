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
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Remove existing preview layer
        uiView.layer.sublayers?.removeAll { $0 is AVCaptureVideoPreviewLayer }
        
        // Only add preview layer if view has proper size
        guard uiView.bounds.width > 0 && uiView.bounds.height > 0 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.updateUIView(uiView, context: context)
            }
            return
        }
        
        // Wait a bit for session to be properly configured
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Create and configure preview layer
            let previewLayer = AVCaptureVideoPreviewLayer(session: self.camera.session)
            previewLayer.frame = uiView.bounds
            previewLayer.videoGravity = .resizeAspectFill
            
            // Add the preview layer
            uiView.layer.addSublayer(previewLayer)
            
            // Force preview layer to update
            previewLayer.connection?.isEnabled = true
        }
    }
}