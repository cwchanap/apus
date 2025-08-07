//
//  ContourOverlayView.swift
//  apus
//
//  Created by Rovo Dev on 30/7/2025.
//

import SwiftUI

struct ContourOverlayView: View {
    let contours: [DetectedContour]
    let imageSize: CGSize
    let displaySize: CGSize
    @State private var contourOpacity: Double = 0.8

    var body: some View {
        ZStack {
            ForEach(Array(contours.enumerated()), id: \.element.id) { _, contour in
                ContourEdgePath(
                    contour: contour,
                    imageSize: imageSize,
                    displaySize: displaySize,
                    opacity: contourOpacity
                )
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                contourOpacity = contourOpacity > 0.5 ? 0.3 : 0.8
            }
        }
    }
}

struct ContourEdgePath: View {
    let contour: DetectedContour
    let imageSize: CGSize
    let displaySize: CGSize
    let opacity: Double

    private var scaledPoints: [CGPoint] {
        contour.points.map { visionPoint in
            // Step 1: Convert from Vision coordinates (bottom-left origin) to top-left origin
            let flippedY = 1.0 - visionPoint.y

            // Step 2: Calculate how the image is actually displayed within the view bounds
            let (imageDisplaySize, imageOffset) = calculateImageDisplayBounds()

            // Step 3: Scale to actual image display area
            let scaledX = visionPoint.x * imageDisplaySize.width + imageOffset.x
            let scaledY = flippedY * imageDisplaySize.height + imageOffset.y

            return CGPoint(x: scaledX, y: scaledY)
        }
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

    private var edgePath: Path {
        var path = Path()
        guard scaledPoints.count >= 2 else { return path }

        path.move(to: scaledPoints[0])

        for index in 1..<scaledPoints.count {
            path.addLine(to: scaledPoints[index])
        }

        // Close path if it's a significant contour with enough points
        if scaledPoints.count > 3 && contour.area > 0.01 {
            path.closeSubpath()
        }

        return path
    }

    private var edgeColor: Color {
        // Use colors based on contour type for better identification
        switch contour.contourType {
        case .document:
            return .blue
        case .rectangle:
            return .green
        case .square:
            return .orange
        case .complex:
            return .purple
        case .simple:
            return .red
        }
    }

    private var lineWidth: CGFloat {
        // Vary line width based on contour confidence and size
        let baseWidth: CGFloat = 1.5
        let confidenceMultiplier = CGFloat(contour.confidence)
        let sizeMultiplier = contour.area > 0.1 ? 1.5 : 1.0

        return baseWidth * confidenceMultiplier * sizeMultiplier
    }

    var body: some View {
        edgePath
            .stroke(
                edgeColor,
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .opacity(opacity)
            .shadow(color: .black.opacity(0.3), radius: 1)
    }
}

#if DEBUG
#Preview {
    let mockContours = [
        DetectedContour(
            points: [
                CGPoint(x: 0.1, y: 0.2),
                CGPoint(x: 0.8, y: 0.2),
                CGPoint(x: 0.8, y: 0.7),
                CGPoint(x: 0.1, y: 0.7)
            ],
            boundingBox: CGRect(x: 0.1, y: 0.2, width: 0.7, height: 0.5),
            confidence: 0.92,
            aspectRatio: 1.4,
            area: 0.35
        )
    ]

    ContourOverlayView(
        contours: mockContours,
        imageSize: CGSize(width: 400, height: 600),
        displaySize: CGSize(width: 300, height: 400)
    )
    .frame(width: 300, height: 400)
    .background(Color.gray.opacity(0.3))
}
#endif
