//
//  OCRResultsView.swift
//  apus
//
//  Created by Rovo Dev on 3/8/2025.
//

import SwiftUI

struct OCRResultsView: View {
    @ObservedObject var resultsManager: DetectionResultsManager
    @State private var selectedResult: StoredOCRResult?
    @State private var showingDetailView = false
    
    var body: some View {
        NavigationView {
            Group {
                if resultsManager.ocrResults.isEmpty {
                    EmptyResultsView(
                        category: .ocr,
                        message: "No OCR results yet",
                        description: "Perform text recognition on images to see results here"
                    )
                } else {
                    List {
                        ForEach(resultsManager.ocrResults) { result in
                            OCRResultRow(result: result) {
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
            .navigationTitle("OCR Results")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !resultsManager.ocrResults.isEmpty {
                        Button("Clear All") {
                            resultsManager.clearOCRResults()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingDetailView) {
                if let result = selectedResult {
                    OCRResultDetailView(result: result)
                }
            }
        }
    }
    
    private func deleteResults(at offsets: IndexSet) {
        resultsManager.ocrResults.remove(atOffsets: offsets)
    }
}

struct OCRResultRow: View {
    let result: StoredOCRResult
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
                    // Text preview
                    Text(result.allText.isEmpty ? "No text detected" : result.allText)
                        .font(.body)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    // Statistics
                    HStack(spacing: 16) {
                        Label("\(result.totalTextCount)", systemImage: "textformat")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("\(Int(result.averageConfidence * 100))%", systemImage: "checkmark.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Timestamp
                    Text(result.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.tertiary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.tertiary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OCRResultDetailView: View {
    let result: StoredOCRResult
    @Environment(\.dismiss) private var dismiss
    @State private var showingImage = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image section
                    if let image = result.image {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Image")
                                .font(.headline)
                            
                            Button(action: { showingImage = true }) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
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
                            StatRow(label: "Text Elements", value: "\(result.totalTextCount)")
                            StatRow(label: "Average Confidence", value: "\(Int(result.averageConfidence * 100))%")
                            StatRow(label: "Image Size", value: "\(Int(result.imageSize.width)) × \(Int(result.imageSize.height))")
                            StatRow(label: "Detected", value: result.timestamp.formatted(date: .abbreviated, time: .shortened))
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Detected text section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Detected Text")
                            .font(.headline)
                        
                        if result.detectedTexts.isEmpty {
                            Text("No text detected")
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(result.detectedTexts) { detectedText in
                                    DetectedTextRow(detectedText: detectedText)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("OCR Result")
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
}

struct DetectedTextRow: View {
    let detectedText: StoredDetectedText
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(detectedText.text)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(detectedText.confidence * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(confidenceColor.opacity(0.2))
                    .clipShape(Capsule())
            }
            
            Text("Position: (\(String(format: "%.2f", detectedText.boundingBox.origin.x)), \(String(format: "%.2f", detectedText.boundingBox.origin.y)))")
                .font(.caption2)
                .foregroundColor(.tertiary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var confidenceColor: Color {
        if detectedText.confidence > 0.9 {
            return .green
        } else if detectedText.confidence > 0.7 {
            return .orange
        } else {
            return .red
        }
    }
}

#if DEBUG
struct OCRResultsView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DetectionResultsManager()
        
        // Add sample data
        let sampleImage = UIImage(systemName: "photo") ?? UIImage()
        let sampleTexts = [
            DetectedText(text: "Sample Receipt", boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.1), confidence: 0.95, characterBoxes: []),
            DetectedText(text: "Coffee Shop", boundingBox: CGRect(x: 0.2, y: 0.3, width: 0.6, height: 0.08), confidence: 0.88, characterBoxes: []),
            DetectedText(text: "Total: $12.50", boundingBox: CGRect(x: 0.1, y: 0.7, width: 0.5, height: 0.08), confidence: 0.92, characterBoxes: [])
        ]
        
        manager.saveOCRResult(detectedTexts: sampleTexts, image: sampleImage)
        
        return OCRResultsView(resultsManager: manager)
    }
}
#endif