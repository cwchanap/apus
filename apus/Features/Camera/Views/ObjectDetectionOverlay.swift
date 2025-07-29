//
//  ObjectDetectionOverlay.swift
//  apus
//
//  Created by Rovo Dev on 28/7/2025.
//

import SwiftUI

struct ObjectDetectionOverlay: View {
    let detections: [Detection]
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(detections.indices, id: \.self) { index in
                let detection = detections[index]
                
                Rectangle()
                    .stroke(Color.red, lineWidth: 2)
                    .frame(
                        width: detection.boundingBox.width * geometry.size.width,
                        height: detection.boundingBox.height * geometry.size.height
                    )
                    .position(
                        x: detection.boundingBox.midX * geometry.size.width,
                        y: detection.boundingBox.midY * geometry.size.height
                    )
                    .overlay(
                        Text("\(detection.className) \(String(format: "%.1f%%", detection.confidence * 100))")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.red)
                            .position(
                                x: detection.boundingBox.midX * geometry.size.width,
                                y: detection.boundingBox.minY * geometry.size.height - 10
                            )
                    )
            }
        }
    }
}