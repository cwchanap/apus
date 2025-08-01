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
            ForEach(Array(contours.enumerated()), id: \.element.id) { index, contour in
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
        contour.points.map { point in
            CGPoint(
                x: point.x * displaySize.width,
                y: (1 - point.y) * displaySize.height // Flip Y coordinate
            )
        }
    }
    
    private var edgePath: Path {
        var path = Path()
        guard scaledPoints.count >= 2 else { return path }
        
        // Create smooth curves for edge highlighting
        if scaledPoints.count == 2 {
            // Simple line for 2 points
            path.move(to: scaledPoints[0])
            path.addLine(to: scaledPoints[1])
        } else {
            // Smooth curve for multiple points
            path.move(to: scaledPoints[0])
            
            for i in 1..<scaledPoints.count {
                let currentPoint = scaledPoints[i]
                
                if i == scaledPoints.count - 1 {
                    // Last point - close the path if it's a closed contour
                    if scaledPoints.count > 3 {
                        path.addLine(to: currentPoint)
                        path.closeSubpath()
                    } else {
                        path.addLine(to: currentPoint)
                    }
                } else {
                    // Add smooth curve to next point
                    path.addLine(to: currentPoint)
                }
            }
        }
        
        return path
    }
    
    private var edgeColor: Color {
        // Use different colors based on contour size for better visibility
        if contour.area > 0.1 {
            return .cyan  // Large contours in cyan
        } else if contour.area > 0.05 {
            return .green  // Medium contours in green
        } else if contour.area > 0.01 {
            return .yellow  // Small contours in yellow
        } else {
            return .red  // Very small contours in red
        }
    }
    
    private var lineWidth: CGFloat {
        // Vary line width based on contour size
        if contour.area > 0.1 {
            return 2.5
        } else if contour.area > 0.05 {
            return 2.0
        } else if contour.area > 0.01 {
            return 1.5
        } else {
            return 1.0
        }
    }
    
    var body: some View {
        // Edge highlighting - no fills, just outlines
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
            .shadow(color: .black.opacity(0.3), radius: 0.5)
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