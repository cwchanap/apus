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
            Group {
                if resultsManager.isLoading {
                    // Loading state
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading results...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Content loaded
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
                                
                                // Clear all data section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Data Management")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Clear all stored detection results. This action cannot be undone.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Button(action: {
                                        resultsManager.clearAllResults()
                                    }) {
                                        HStack {
                                            Image(systemName: "trash")
                                            Text("Clear All Results")
                                        }
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                // Empty state
                                VStack(spacing: 20) {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                    
                                    Text("No Detection Results")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    Text("Start using the camera to detect objects, text, or classify images. Your results will appear here.")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                                .padding(.top, 40)
                            }
                        }
                        .padding()
                    }
                }
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