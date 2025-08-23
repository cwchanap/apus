//
//  ResultsDashboardView.swift
//  apus
//
//  Created by Rovo Dev on 3/8/2025.
//

import SwiftUI

struct ResultsDashboardView: View {
    @EnvironmentObject var resultsManager: DetectionResultsManager
    @Binding var path: [DetectionCategory]
    @State private var showClearAllConfirm = false
    @State private var showStorageLimitsSettings = false
    private let appSettings = AppSettings.shared

    var body: some View {
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
                                            path.append(category)
                                            // navigation handled by path.append above
                                        }
                                    }
                                }

                                // Recent results preview for each category
                                ForEach(DetectionCategory.allCases, id: \.rawValue) { category in
                                    if resultsManager.getResultsCount(for: category) > 0 {
                                        Button(action: {
                                            path.append(category)
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
                                            maxCount: appSettings.ocrResultsLimit,
                                            color: .purple
                                        )

                                        StorageInfoRow(
                                            label: "Object Detection",
                                            count: resultsManager.objectDetectionResults.count,
                                            maxCount: appSettings.objectDetectionResultsLimit,
                                            color: .blue
                                        )

                                        StorageInfoRow(
                                            label: "Image Classification",
                                            count: resultsManager.classificationResults.count,
                                            maxCount: appSettings.classificationResultsLimit,
                                            color: .green
                                        )

                                        StorageInfoRow(
                                            label: "Contour Detection",
                                            count: resultsManager.contourResults.count,
                                            maxCount: appSettings.contourDetectionResultsLimit,
                                            color: .orange
                                        )

                                        StorageInfoRow(
                                            label: "Barcode Detection",
                                            count: resultsManager.barcodeResults.count,
                                            maxCount: appSettings.barcodeDetectionResultsLimit,
                                            color: .red
                                        )
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Storage limits can be configured per category")
                                            .font(.caption)
                                            .foregroundColor(.secondary)

                                        Text("Oldest results are automatically removed when limits are exceeded")
                                            .font(.caption2)
                                            .foregroundColor(.secondary.opacity(0.8))
                                    }
                                    .padding(.top, 8)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                                // Separate button section outside the storage management card
                                VStack {
                                    HStack {
                                        Spacer()

                                        Text("⚙️ Adjust Storage Limits")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 12)
                                            .background(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)

                                        Spacer()
                                    }
                                }
                                .padding(.top, 12)
                                .onTapGesture {
                                    showStorageLimitsSettings = true
                                }

                                // Clear all data section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Data Management")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text("Clear all stored detection results. This action cannot be undone.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    Button(action: {
                                        showClearAllConfirm = true
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
                                    .alert("Clear All Results?", isPresented: $showClearAllConfirm) {
                                        Button("Cancel", role: .cancel) { }
                                        Button("Delete", role: .destructive) {
                                            resultsManager.clearAllResults()
                                        }
                                    } message: {
                                        Text("This will remove all OCR, Object Detection, Classification, Contour and Barcode results. This action cannot be undone.")
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
            .navigationTitle("Detection Results")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                // Refresh results if needed
            }
            .sheet(isPresented: $showStorageLimitsSettings) {
                StorageLimitsSettingsView()
            }
    }
}

// MARK: - Supporting Views

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

struct CategoryResultsView: View {
    @Environment(\.dismiss) private var dismiss
    let category: DetectionCategory
    @EnvironmentObject var resultsManager: DetectionResultsManager

    var body: some View {
        Group {
            switch category {
            case .ocr:
                OCRResultsView()
            case .objectDetection:
                ObjectDetectionResultsView()
            case .classification:
                ClassificationResultsView()
            case .contourDetection:
                ContourDetectionResultsView()
            case .barcode:
                BarcodeDetectionResultsView()
            }
        }
        .environmentObject(resultsManager)
    }
}
