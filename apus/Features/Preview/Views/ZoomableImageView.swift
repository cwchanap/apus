//
//  ZoomableImageView.swift
//  apus
//
//  Created by Rovo Dev on 30/7/2025.
//

import SwiftUI

struct ZoomableImageView: View {
    let image: UIImage
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 4.0
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    SimultaneousGesture(
                        // Magnification gesture for zooming
                        MagnificationGesture()
                            .onChanged { value in
                                let newScale = lastScale * value
                                scale = min(max(newScale, minScale), maxScale)
                            }
                            .onEnded { _ in
                                lastScale = scale
                                
                                // Reset to fit if zoomed out too much
                                if scale <= minScale {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        scale = minScale
                                        offset = .zero
                                        lastOffset = .zero
                                    }
                                }
                                lastScale = scale
                            },
                        
                        // Drag gesture for panning
                        DragGesture()
                            .onChanged { value in
                                let newOffset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                                
                                // Limit panning based on zoom level and image bounds
                                let imageSize = getImageDisplaySize(in: geometry)
                                let maxOffsetX = max(0, (imageSize.width * scale - geometry.size.width) / 2)
                                let maxOffsetY = max(0, (imageSize.height * scale - geometry.size.height) / 2)
                                
                                offset = CGSize(
                                    width: min(max(newOffset.width, -maxOffsetX), maxOffsetX),
                                    height: min(max(newOffset.height, -maxOffsetY), maxOffsetY)
                                )
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                )
                .onTapGesture(count: 2) {
                    // Double tap to zoom in/out
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if scale > minScale {
                            scale = minScale
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            scale = 2.0
                        }
                        lastScale = scale
                    }
                }
                .clipped()
        }
    }
    
    private func getImageDisplaySize(in geometry: GeometryProxy) -> CGSize {
        let imageAspectRatio = image.size.width / image.size.height
        let containerAspectRatio = geometry.size.width / geometry.size.height
        
        if imageAspectRatio > containerAspectRatio {
            // Image is wider than container
            let displayWidth = geometry.size.width
            let displayHeight = displayWidth / imageAspectRatio
            return CGSize(width: displayWidth, height: displayHeight)
        } else {
            // Image is taller than container
            let displayHeight = geometry.size.height
            let displayWidth = displayHeight * imageAspectRatio
            return CGSize(width: displayWidth, height: displayHeight)
        }
    }
}