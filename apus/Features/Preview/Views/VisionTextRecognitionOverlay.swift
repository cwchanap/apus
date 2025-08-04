//
//  VisionTextRecognitionOverlay.swift
//  apus
//
//  Created by Rovo Dev on 3/8/2025.
//

import SwiftUI

struct VisionTextRecognitionOverlay: View {
    let detectedTexts: [DetectedText]
    let imageSize: CGSize
    let displaySize: CGSize
    @State private var opacity: Double = 0.9
    
    var body: some View {
        ZStack {
            ForEach(detectedTexts) { detectedText in
                TextDetectionBox(
                    detectedText: detectedText,
                    imageSize: imageSize,
                    displaySize: displaySize,
                    opacity: opacity
                )
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                opacity = opacity > 0.5 ? 0.3 : 0.9
            }
        }
    }
}

struct TextDetectionBox: View {
    let detectedText: DetectedText
    let imageSize: CGSize
    let displaySize: CGSize
    let opacity: Double
    
    private var scaledBoundingBox: CGRect {
        scaleRectToDisplaySize(detectedText.boundingBox)
    }
    
    private var textColor: Color {
        // Use different colors based on confidence level
        if detectedText.confidence > 0.9 {
            return .green
        } else if detectedText.confidence > 0.7 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var lineWidth: CGFloat {
        // Thicker lines for higher confidence
        return detectedText.confidence > 0.8 ? 2.0 : 1.5
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Bounding box rectangle
            Rectangle()
                .stroke(textColor, lineWidth: lineWidth)
                .background(
                    Rectangle()
                        .fill(textColor.opacity(0.1))
                )
                .frame(width: scaledBoundingBox.width, height: scaledBoundingBox.height)
                .position(
                    x: scaledBoundingBox.midX,
                    y: scaledBoundingBox.midY
                )
            
            // Text label with confidence
            Text("\(detectedText.text) (\(Int(detectedText.confidence * 100))%)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(textColor.opacity(0.8))
                )
                .position(
                    x: scaledBoundingBox.midX,
                    y: max(scaledBoundingBox.minY - 10, 10) // Position above box, but not off-screen
                )
        }
        .opacity(opacity)
    }
    
    private func scaleRectToDisplaySize(_ rect: CGRect) -> CGRect {
        // Calculate the scaling factors
        let scaleX = displaySize.width / imageSize.width
        let scaleY = displaySize.height / imageSize.height
        
        // Use the smaller scale to maintain aspect ratio
        let scale = min(scaleX, scaleY)
        
        // Calculate the actual display area size
        let scaledImageWidth = imageSize.width * scale
        let scaledImageHeight = imageSize.height * scale
        
        // Calculate offsets to center the image in the display area
        let offsetX = (displaySize.width - scaledImageWidth) / 2
        let offsetY = (displaySize.height - scaledImageHeight) / 2
        
        // Scale and offset the bounding box
        return CGRect(
            x: rect.origin.x * scale + offsetX,
            y: rect.origin.y * scale + offsetY,
            width: rect.width * scale,
            height: rect.height * scale
        )
    }
}

// MARK: - Preview

#if DEBUG
struct VisionTextRecognitionOverlay_Previews: PreviewProvider {
    static var previews: some View {
        let mockTexts = [
            DetectedText(
                text: "RECEIPT",
                boundingBox: CGRect(x: 100, y: 50, width: 200, height: 40),
                confidence: 0.95,
                characterBoxes: []
            ),
            DetectedText(
                text: "Coffee Shop",
                boundingBox: CGRect(x: 80, y: 120, width: 240, height: 30),
                confidence: 0.92,
                characterBoxes: []
            ),
            DetectedText(
                text: "Total: $7.75",
                boundingBox: CGRect(x: 60, y: 200, width: 180, height: 25),
                confidence: 0.88,
                characterBoxes: []
            )
        ]
        
        VisionTextRecognitionOverlay(
            detectedTexts: mockTexts,
            imageSize: CGSize(width: 400, height: 300),
            displaySize: CGSize(width: 350, height: 250)
        )
        .frame(width: 350, height: 250)
        .background(Color.gray.opacity(0.3))
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Text Recognition Overlay")
    }
}
#endif