//
//  CameraControlsView.swift
//  apus
//
//  Created by Rovo Dev on 28/7/2025.
//

import SwiftUI

struct CameraControlsView: View {
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            // Camera controls
            HStack(spacing: 50) {
                // Gallery button
                Button(action: {
                    viewModel.selectImageFromLibrary()
                }) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                
                // Capture button
                Button(action: {
                    viewModel.capturePhoto()
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                                .frame(width: 60, height: 60)
                        )
                }
                
                // Flash button
                Button(action: {
                    viewModel.toggleFlash()
                }) {
                    Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash")
                        .font(.title2)
                        .foregroundColor(viewModel.isFlashOn ? .yellow : .white)
                        .frame(width: 50, height: 50)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 50)
        }
    }
}