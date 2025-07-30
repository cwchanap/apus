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
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                // Camera controls positioned at bottom with perfect center alignment
                HStack {
                    // Gallery button (left side)
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
                    .frame(width: 70) // Fixed width for consistent spacing
                    
                    Spacer()
                    
                    // Capture button (center)
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
                    
                    Spacer()
                    
                    // Flash button (right side)
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
                    .frame(width: 70) // Fixed width for consistent spacing
                }
                .frame(maxWidth: .infinity) // Ensure full width
                .padding(.horizontal, 40) // Side padding
                .padding(.bottom, geometry.safeAreaInsets.bottom + 30)
            }
        }
    }
}