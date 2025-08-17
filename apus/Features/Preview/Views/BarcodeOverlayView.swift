
//
//  BarcodeOverlayView.swift
//  apus
//
//  Created by wa-ik on 2025/08/17.
//

import SwiftUI
import Vision

/// A view that displays an overlay with bounding boxes and labels for detected barcodes.
struct BarcodeOverlayView: View {
    let barcodes: [VNBarcodeObservation]
    let imageSize: CGSize
    let displaySize: CGSize

    var body: some View {
        ZStack {
            ForEach(barcodes, id: \.uuid) { barcode in
                let transformedRect = transformBoundingBox(barcode.boundingBox, from: imageSize, to: displaySize)

                // Draw bounding box
                Rectangle()
                    .stroke(Color.red, lineWidth: 2)
                    .frame(width: transformedRect.width, height: transformedRect.height)
                    .position(x: transformedRect.midX, y: transformedRect.midY)

                // Display barcode payload
                Text(barcode.payloadStringValue ?? "N/A")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.red.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .position(x: transformedRect.minX, y: transformedRect.minY - 12) // Position above the box
            }
        }
    }

    /// Transforms a bounding box from image coordinates to display coordinates.
    private func transformBoundingBox(_ box: CGRect, from imageSize: CGSize, to displaySize: CGSize) -> CGRect {
        let scaleX = displaySize.width / imageSize.width
        let scaleY = displaySize.height / imageSize.height

        // Vision framework coordinates are normalized and have origin at bottom-left.
        // We need to convert to top-left origin for SwiftUI.
        return CGRect(
            x: box.origin.x * displaySize.width,
            y: (1 - box.origin.y - box.height) * displaySize.height,
            width: box.width * displaySize.width,
            height: box.height * displaySize.height
        )
    }
}

struct BarcodeDetectionOverlay: View {
    let barcodes: [VNBarcodeObservation]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(barcodes, id: \.self) { barcode in
                    let boundingBox = barcode.boundingBox
                    let rect = CGRect(
                        x: boundingBox.origin.x * geometry.size.width,
                        y: (1 - boundingBox.origin.y - boundingBox.height) * geometry.size.height,
                        width: boundingBox.width * geometry.size.width,
                        height: boundingBox.height * geometry.size.height
                    )
                    
                    Rectangle()
                        .stroke(Color.red, lineWidth: 2)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)
                    
                    Text(barcode.payloadStringValue ?? "")
                        .foregroundColor(.white)
                        .background(Color.red)
                        .position(x: rect.midX, y: rect.midY)
                }
            }
        }
    }
}
