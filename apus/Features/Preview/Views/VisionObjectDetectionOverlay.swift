//
//  VisionObjectDetectionOverlay.swift
//  apus
//
//  Created by Rovo Dev on 1/8/2025.
//

import SwiftUI

struct VisionObjectDetectionOverlay: View {
    let detections: [VisionDetection]
    let imageSize: CGSize
    let displaySize: CGSize
    @State private var overlayOpacity: Double = 0.9

    var body: some View {
        ZStack {
            ForEach(Array(detections.enumerated()), id: \.element.id) { _, detection in
                VisionDetectionBox(
                    detection: detection,
                    imageSize: imageSize,
                    displaySize: displaySize,
                    opacity: overlayOpacity
                )
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                overlayOpacity = overlayOpacity > 0.5 ? 0.3 : 0.9
            }
        }
    }
}

struct VisionDetectionBox: View {
    let detection: VisionDetection
    let imageSize: CGSize
    let displaySize: CGSize
    let opacity: Double

    // Convert normalized coordinates to display coordinates
    private var displayBoundingBox: CGRect {
        // Calculate how the image is actually displayed within the view bounds
        let (imageDisplaySize, imageOffset) = calculateImageDisplayBounds()

        // Convert from Vision normalized coordinates to display coordinates
        let visionBox = detection.displayBoundingBox  // Already flipped for SwiftUI

        let displayBox = CGRect(
            x: visionBox.minX * imageDisplaySize.width + imageOffset.x,
            y: visionBox.minY * imageDisplaySize.height + imageOffset.y,
            width: visionBox.width * imageDisplaySize.width,
            height: visionBox.height * imageDisplaySize.height
        )

        return displayBox
    }

    // Calculate how the image is actually displayed within the view bounds
    private func calculateImageDisplayBounds() -> (size: CGSize, offset: CGPoint) {
        let imageAspectRatio = imageSize.width / imageSize.height
        let displayAspectRatio = displaySize.width / displaySize.height

        var imageDisplaySize: CGSize
        var imageOffset: CGPoint

        if imageAspectRatio > displayAspectRatio {
            // Image is wider - fit to width
            imageDisplaySize = CGSize(
                width: displaySize.width,
                height: displaySize.width / imageAspectRatio
            )
            imageOffset = CGPoint(
                x: 0,
                y: (displaySize.height - imageDisplaySize.height) / 2
            )
        } else {
            // Image is taller - fit to height
            imageDisplaySize = CGSize(
                width: displaySize.height * imageAspectRatio,
                height: displaySize.height
            )
            imageOffset = CGPoint(
                x: (displaySize.width - imageDisplaySize.width) / 2,
                y: 0
            )
        }

        return (imageDisplaySize, imageOffset)
    }

    private var boxColor: Color {
        // Color based on object class
        switch detection.className.lowercased() {
        case "person", "people":
            return .blue
        case "dog", "cat", "animal":
            return .green
        case "car", "truck", "vehicle", "bicycle", "motorcycle":
            return .red
        case "food", "pizza", "apple", "banana", "sandwich":
            return .orange
        case "cup", "bottle", "glass":
            return .cyan
        case "chair", "table", "furniture":
            return .purple
        case "laptop", "computer", "phone", "tv":
            return .pink
        default:
            return .yellow
        }
    }

    private var strokeWidth: CGFloat {
        // Vary stroke width based on confidence
        let baseWidth: CGFloat = 2.0
        let confidenceMultiplier = CGFloat(detection.confidence)
        return baseWidth * (0.5 + confidenceMultiplier * 0.5)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Bounding box
            Rectangle()
                .stroke(boxColor, lineWidth: strokeWidth)
                .background(
                    Rectangle()
                        .fill(boxColor.opacity(0.1))
                )
                .frame(
                    width: displayBoundingBox.width,
                    height: displayBoundingBox.height
                )
                .position(
                    x: displayBoundingBox.midX,
                    y: displayBoundingBox.midY
                )

            // Label background and text
            VStack(alignment: .leading, spacing: 2) {
                Text(detection.className.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("\(Int(detection.confidence * 100))%")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(boxColor.opacity(0.9))
            )
            .position(
                x: displayBoundingBox.minX + 40,  // Offset from box corner
                y: max(15, displayBoundingBox.minY - 5)  // Above box, but not off-screen
            )
        }
        .opacity(opacity)
        .animation(.easeInOut(duration: 0.2), value: opacity)
    }
}

#if DEBUG
#Preview {
    GeometryReader { geometry in
        ZStack {
            Color.black

            VisionObjectDetectionOverlay(
                detections: [
                    VisionDetection(
                        boundingBox: CGRect(x: 0.2, y: 0.3, width: 0.3, height: 0.4),
                        className: "person",
                        confidence: 0.92
                    ),
                    VisionDetection(
                        boundingBox: CGRect(x: 0.6, y: 0.1, width: 0.25, height: 0.3),
                        className: "dog",
                        confidence: 0.87
                    )
                ],
                imageSize: CGSize(width: 400, height: 300),
                displaySize: geometry.size
            )
        }
    }
    .frame(width: 300, height: 400)
}
#endif
