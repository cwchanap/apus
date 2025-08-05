//
//  ObjectDetectionResultsView.swift
//  apus
//
//  Created by Rovo Dev on 3/8/2025.
//

import SwiftUI

struct ObjectDetectionResultsView: View {
    @ObservedObject var resultsManager: DetectionResultsManager
    @State private var selectedResult: StoredObjectDetectionResult?
    @State private var showingDetailView = false
    
    var body: some View {
        NavigationView {
            Group {
                if resultsManager.objectDetectionResults.isEmpty {
                    EmptyResultsView(
                        category: .objectDetection,
                        message: "No object detection results yet",
                        description: "Detect objects in images to see results here"
                    )
                } else {
                    List {
                        ForEach(resultsManager.objectDetectionResults) { result in
                            ObjectDetectionResultRow(result: result) {
                                selectedResult = result
                                showingDetailView = true
                            }
                        }
                        .onDelete(perform: deleteResults)
                    }
                    .refreshable {
                        // Refresh functionality if needed
                    }
                }
            }
            .navigationTitle("Object Detection")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !resultsManager.objectDetectionResults.isEmpty {
                        Button("Clear All") {
                            resultsManager.clearObjectDetectionResults()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingDetailView) {
                if let result = selectedResult {
                    ObjectDetectionResultDetailView(result: result)
                }
            }
        }
    }
    
    private func deleteResults(at offsets: IndexSet) {
        resultsManager.objectDetectionResults.remove(atOffsets: offsets)
    }
}

struct ObjectDetectionResultRow: View {
    let result: StoredObjectDetectionResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Thumbnail
                if let image = result.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Object classes preview
                    Text(result.uniqueClasses.isEmpty ? "No objects detected" : result.uniqueClasses.prefix(3).joined(separator: ", "))
                        .font(.body)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    // Statistics
                    HStack(spacing: 16) {
                        Label("\(result.totalObjectCount)", systemImage: "viewfinder")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("\(Int(result.averageConfidence * 100))%", systemImage: "checkmark.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label(result.framework, systemImage: "cpu")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Timestamp
                    Text(result.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ObjectDetectionResultDetailView: View {
    let result: StoredObjectDetectionResult
    @Environment(\.dismiss) private var dismiss
    @State private var showingImage = false
    @State private var showingOverlay = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image section with overlay toggle
                    if let image = result.image {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Image")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button(showingOverlay ? "Hide Overlay" : "Show Overlay") {
                                    showingOverlay.toggle()
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                            
                            Button(action: { showingImage = true }) {
                                ZStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 250)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    if showingOverlay {
                                        GeometryReader { geometry in
                                            ForEach(result.detectedObjects) { obj in
                                                let detectedObject = obj.toDetectedObject()
                                                let displayBox = detectedObject.displayBoundingBox(
                                                    imageSize: result.imageSize,
                                                    displaySize: geometry.size
                                                )
                                                
                                                Rectangle()
                                                    .stroke(frameworkColor(obj.framework), lineWidth: 2)
                                                    .frame(width: displayBox.width, height: displayBox.height)
                                                    .position(x: displayBox.midX, y: displayBox.midY)
                                            }
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Statistics section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Statistics")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            StatRow(label: "Objects Detected", value: "\(result.totalObjectCount)")
                            StatRow(label: "Unique Classes", value: "\(result.uniqueClasses.count)")
                            StatRow(label: "Average Confidence", value: "\(Int(result.averageConfidence * 100))%")
                            StatRow(label: "Framework", value: result.framework)
                            StatRow(label: "Image Size", value: "\(Int(result.imageSize.width)) × \(Int(result.imageSize.height))")
                            StatRow(label: "Detected", value: result.timestamp.formatted(date: .abbreviated, time: .shortened))
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Detected objects section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Detected Objects")
                            .font(.headline)
                        
                        if result.detectedObjects.isEmpty {
                            Text("No objects detected")
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(result.detectedObjects) { detectedObject in
                                    DetectedObjectRow(detectedObject: detectedObject)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Object Detection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingImage) {
            if let image = result.image {
                ImageDetailView(image: image)
            }
        }
    }
    
    private func frameworkColor(_ framework: String) -> Color {
        return framework.lowercased().contains("vision") ? .blue : .orange
    }
}

struct DetectedObjectRow: View {
    let detectedObject: StoredDetectedObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(detectedObject.className.capitalized)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text("Framework: \(detectedObject.framework)")
                        .font(.caption2)
                        .foregroundColor(.tertiary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(detectedObject.confidence * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(confidenceColor.opacity(0.2))
                        .clipShape(Capsule())
                    
                    Text(frameworkBadge)
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(frameworkColor)
                        .clipShape(Capsule())
                }
            }
            
            Text("Position: (\(String(format: "%.2f", detectedObject.boundingBox.origin.x)), \(String(format: "%.2f", detectedObject.boundingBox.origin.y)))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var confidenceColor: Color {
        if detectedObject.confidence > 0.9 {
            return .green
        } else if detectedObject.confidence > 0.7 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var frameworkColor: Color {
        return detectedObject.framework.lowercased().contains("vision") ? .blue : .orange
    }
    
    private var frameworkBadge: String {
        return detectedObject.framework.lowercased().contains("vision") ? "VN" : "TF"
    }
}

#if DEBUG
struct ObjectDetectionResultsView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DetectionResultsManager()
        
        // Add sample data
        let sampleImage = UIImage(systemName: "photo") ?? UIImage()
        let sampleObjects = [
            DetectedObject(boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.3, height: 0.4), className: "person", confidence: 0.92, framework: .vision),
            DetectedObject(boundingBox: CGRect(x: 0.6, y: 0.2, width: 0.25, height: 0.3), className: "dog", confidence: 0.87, framework: .tensorflowLite)
        ]
        
        manager.saveObjectDetectionResult(detectedObjects: sampleObjects, image: sampleImage)
        
        return ObjectDetectionResultsView(resultsManager: manager)
    }
}
#endif