//
//  SharedResultComponents.swift
//  apus
//
//  Created by Rovo Dev on 3/8/2025.
//

import SwiftUI

// MARK: - Empty Results View

struct EmptyResultsView: View {
    let category: DetectionCategory
    let message: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: category.icon)
                .font(.system(size: 60))
                .foregroundColor(category.color.opacity(0.6))
            
            VStack(spacing: 8) {
                Text(message)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.05))
    }
}

// MARK: - Statistics Row

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Image Detail View

struct ImageDetailView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width * scale, height: geometry.size.height * scale)
                        .offset(offset)
                        .scaleEffect(scale)
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = max(1.0, min(5.0, value))
                                    },
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring()) {
                                if scale > 1.0 {
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                } else {
                                    scale = 2.0
                                }
                            }
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            }
            .navigationTitle("Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - Results Summary Card

struct ResultsSummaryCard: View {
    let category: DetectionCategory
    let count: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: category.icon)
                        .font(.title2)
                        .foregroundColor(category.color)
                    
                    Spacer()
                    
                    Text("\(count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text(category.rawValue)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(category.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Recent Results Preview

struct RecentResultsPreview: View {
    @ObservedObject var resultsManager: DetectionResultsManager
    let category: DetectionCategory
    let maxItems: Int = 3
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recent \(category.rawValue)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if resultsManager.getResultsCount(for: category) > 0 {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(category.color)
                }
            }
            
            if resultsManager.getResultsCount(for: category) == 0 {
                Text("No recent results")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                LazyVStack(spacing: 8) {
                    switch category {
                    case .ocr:
                        ForEach(Array(resultsManager.ocrResults.prefix(maxItems))) { result in
                            RecentOCRRow(result: result)
                        }
                    case .objectDetection:
                        ForEach(Array(resultsManager.objectDetectionResults.prefix(maxItems))) { result in
                            RecentObjectDetectionRow(result: result)
                        }
                    case .classification:
                        ForEach(Array(resultsManager.classificationResults.prefix(maxItems))) { result in
                            RecentClassificationRow(result: result)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct RecentOCRRow: View {
    let result: StoredOCRResult
    
    var body: some View {
        HStack(spacing: 8) {
            if let image = result.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(result.allText.isEmpty ? "No text" : String(result.allText.prefix(30)) + (result.allText.count > 30 ? "..." : ""))
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text("\(result.totalTextCount) texts • \(Int(result.averageConfidence * 100))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(result.timestamp, style: .relative)
                .font(.caption2)
                .foregroundColor(Color.secondary)
        }
    }
}

struct RecentObjectDetectionRow: View {
    let result: StoredObjectDetectionResult
    
    var body: some View {
        HStack(spacing: 8) {
            if let image = result.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(result.uniqueClasses.isEmpty ? "No objects" : result.uniqueClasses.prefix(2).joined(separator: ", "))
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text("\(result.totalObjectCount) objects • \(result.framework)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(result.timestamp, style: .relative)
                .font(.caption2)
                .foregroundColor(Color.secondary)
        }
    }
}

struct RecentClassificationRow: View {
    let result: StoredClassificationResult
    
    var body: some View {
        HStack(spacing: 8) {
            if let image = result.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(result.topResult?.identifier.capitalized ?? "No classification")
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                if let topResult = result.topResult {
                    Text("\(Int(topResult.confidence * 100))% confidence")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(result.timestamp, style: .relative)
                .font(.caption2)
                .foregroundColor(Color.secondary)
        }
    }
}

#if DEBUG
struct SharedResultComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            EmptyResultsView(
                category: .ocr,
                message: "No OCR results yet",
                description: "Perform text recognition on images to see results here"
            )
            .frame(height: 200)
            
            ResultsSummaryCard(category: .objectDetection, count: 5) {
                // Action
            }
            
            StatRow(label: "Total Results", value: "42")
        }
        .padding()
    }
}
#endif