//
//  UnifiedObjectDetectionOverlay.swift
//  apus
//
//  Created by Rovo Dev on 1/8/2025.
//

import SwiftUI

struct UnifiedObjectDetectionOverlay: View {
    let detections: [DetectedObject]
    let imageSize: CGSize
    let displaySize: CGSize
    @State private var overlayOpacity: Double = 0.9
    
    var body: some View {
        ZStack {
            ForEach(Array(detections.enumerated()), id: \.element.id) { index, detection in
                UnifiedDetectionBox(
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

struct UnifiedDetectionBox: View {
    let detection: DetectedObject
    let imageSize: CGSize
    let displaySize: CGSize
    let opacity: Double
    
    // Use the built-in display bounding box calculation from DetectedObject
    private var displayBoundingBox: CGRect {
        detection.displayBoundingBox(imageSize: imageSize, displaySize: displaySize)
    }
    
    private var boxColor: Color {
        // Color based on framework first, then object class
        switch detection.framework {
        case .vision:
            return visionFrameworkColor(for: detection.className)
        case .tensorflowLite:
            return tensorFlowFrameworkColor(for: detection.className)
        }
    }
    
    private func visionFrameworkColor(for className: String) -> Color {
        // Apple Vision framework colors (more iOS-native feel)
        switch className.lowercased() {
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
            return .blue.opacity(0.8)
        }
    }
    
    private func tensorFlowFrameworkColor(for className: String) -> Color {
        // TensorFlow Lite colors (more technical/vibrant feel)
        switch className.lowercased() {
        case let name where name.contains("person") || name.contains("human") || name.contains("face"):
            return .indigo
        case let name where name.contains("dog") || name.contains("cat") || name.contains("animal"):
            return .mint
        case let name where name.contains("car") || name.contains("vehicle") || name.contains("bike"):
            return .red.opacity(0.9)
        case let name where name.contains("food") || name.contains("pizza") || name.contains("apple"):
            return .yellow
        case let name where name.contains("cup") || name.contains("bottle") || name.contains("mug"):
            return .teal
        case let name where name.contains("chair") || name.contains("table") || name.contains("office"):
            return .purple.opacity(0.8)
        case let name where name.contains("laptop") || name.contains("computer") || name.contains("macbook"):
            return .pink.opacity(0.9)
        default:
            return .orange.opacity(0.8)
        }
    }
    
    private var strokeWidth: CGFloat {
        // Vary stroke width based on confidence and framework
        let baseWidth: CGFloat = detection.framework == .tensorflowLite ? 2.5 : 2.0
        let confidenceMultiplier = CGFloat(detection.confidence)
        return baseWidth * (0.5 + confidenceMultiplier * 0.5)
    }
    
    private var frameworkBadge: some View {
        Text(detection.framework.displayName.prefix(2).uppercased())
            .font(.system(size: 8, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(detection.framework == .vision ? Color.blue : Color.orange)
            )
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
                HStack(spacing: 4) {
                    Text(detection.className.capitalized)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    frameworkBadge
                }
                
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
                x: displayBoundingBox.minX + 50,  // Offset from box corner
                y: max(20, displayBoundingBox.minY - 5)  // Above box, but not off-screen
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
            
            UnifiedObjectDetectionOverlay(
                detections: [
                    DetectedObject(
                        boundingBox: CGRect(x: 0.2, y: 0.3, width: 0.3, height: 0.4),
                        className: "person",
                        confidence: 0.92,
                        framework: .vision
                    ),
                    DetectedObject(
                        boundingBox: CGRect(x: 0.6, y: 0.1, width: 0.25, height: 0.3),
                        className: "golden_retriever",
                        confidence: 0.87,
                        framework: .tensorflowLite
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