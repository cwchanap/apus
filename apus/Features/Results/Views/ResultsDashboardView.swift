//
//  ResultsDashboardView.swift
//  apus
//
//  Created by Rovo Dev on 3/8/2025.
//

import SwiftUI

struct ResultsDashboardView: View {
    @Injected private var resultsManager: DetectionResultsManager
    @State private var selectedCategory: DetectionCategory?
    @State private var showingCategoryView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with total count
                    VStack(spacing: 8) {
                        Text("Detection Results")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if resultsManager.hasAnyResults {
                            Text("\(resultsManager.totalResultsCount) total results stored")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            Text("No results yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top)
                    
                    if resultsManager.hasAnyResults {
                        // Category summary cards
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(DetectionCategory.allCases, id: \.rawValue) { category in
                                ResultsSummaryCard(
                                    category: category,
                                    count: resultsManager.getResultsCount(for: category)
                                ) {
                                    selectedCategory = category
                                    showingCategoryView = true
                                }
                            }
                        }
                        
                        // Recent results preview for each category
                        ForEach(DetectionCategory.allCases, id: \.rawValue) { category in
                            if resultsManager.getResultsCount(for: category) > 0 {
                                Button(action: {
                                    selectedCategory = category
                                    showingCategoryView = true
                                }) {
                                    RecentResultsPreview(
                                        resultsManager: resultsManager,
                                        category: category
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // Storage management section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Storage Management")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 8) {
                                StorageInfoRow(
                                    label: "OCR Results",
                                    count: resultsManager.ocrResults.count,
                                    maxCount: 10,
                                    color: .purple
                                )
                                
                                StorageInfoRow(
                                    label: "Object Detection",
                                    count: resultsManager.objectDetectionResults.count,
                                    maxCount: 10,
                                    color: .blue
                                )
                                
                                StorageInfoRow(
                                    label: "Classification",
                                    count: resultsManager.classificationResults.count,
                                    maxCount: 10,
                                    color: .green
                                )
                            }
                            
                            Text("Only the most recent 10 results are kept for each category")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Clear all button
                        Button(action: {
                            resultsManager.clearAllResults()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear All Results")
                            }
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top)
                        
                    } else {
                        // Empty state
                        VStack(spacing: 24) {
                            Image(systemName: "tray")
                                .font(.system(size: 80))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            VStack(spacing: 8) {
                                Text("No Results Yet")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text("Start analyzing images to see your detection results here")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            VStack(spacing: 12) {
                                Text("Available Analysis Types:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    AnalysisTypeRow(icon: "textformat", title: "OCR Text Recognition", color: .purple)
                                    AnalysisTypeRow(icon: "viewfinder", title: "Object Detection", color: .blue)
                                    AnalysisTypeRow(icon: "brain.head.profile", title: "Image Classification", color: .green)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top, 40)
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .refreshable {
                // Refresh results if needed
            }
        }
        .sheet(isPresented: $showingCategoryView) {
            if let category = selectedCategory {
                CategoryResultsView(category: category, resultsManager: resultsManager)
            }
        }
    }
}

struct StorageInfoRow: View {
    let label: String
    let count: Int
    let maxCount: Int
    let color: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(label)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("\(count)")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("/ \(maxCount)")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(count) / CGFloat(maxCount), height: 4)
                }
            }
            .frame(width: 60, height: 4)
        }
    }
}

struct AnalysisTypeRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct CategoryResultsView: View {
    let category: DetectionCategory
    @ObservedObject var resultsManager: DetectionResultsManager
    
    var body: some View {
        Group {
            switch category {
            case .ocr:
                OCRResultsView(resultsManager: resultsManager)
            case .objectDetection:
                ObjectDetectionResultsView(resultsManager: resultsManager)
            case .classification:
                ClassificationResultsView(resultsManager: resultsManager)
            }
        }
    }
}

#if DEBUG
struct ResultsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DetectionResultsManager()
        
        // Add sample data
        let sampleImage = UIImage(systemName: "photo") ?? UIImage()
        
        // OCR sample
        let sampleTexts = [
            DetectedText(text: "Sample Receipt", boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.1), confidence: 0.95, characterBoxes: [])
        ]
        manager.saveOCRResult(detectedTexts: sampleTexts, image: sampleImage)
        
        // Object detection sample
        let sampleObjects = [
            DetectedObject(boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.3, height: 0.4), className: "person", confidence: 0.92, framework: .vision)
        ]
        manager.saveObjectDetectionResult(detectedObjects: sampleObjects, image: sampleImage)
        
        // Classification sample
        let sampleResults = [
            ClassificationResult(identifier: "dog", confidence: 0.85)
        ]
        manager.saveClassificationResult(classificationResults: sampleResults, image: sampleImage)
        
        return ResultsDashboardView()
            .environmentObject(manager)
    }
}
#endif