//
//  ContourDetectionResultsView.swift
//  apus
//
//  Created by Rovo Dev on 16/8/2025.
//

import SwiftUI

struct ContourDetectionResultsView: View {
    @EnvironmentObject var resultsManager: DetectionResultsManager
    @State private var selectedResult: StoredContourDetectionResult?
    @State private var showClearConfirm = false

    var body: some View {
        Group {
            if resultsManager.contourResults.isEmpty {
                EmptyResultsView(
                    category: .contourDetection,
                    message: "No contour results yet",
                    description: "Detect contours in images to see results here"
                )
            } else {
                List {
                    ForEach(resultsManager.contourResults) { result in
                        Button(action: { selectedResult = result }) {
                            ContourResultRow(result: result)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .onDelete(perform: deleteResults)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Contour Results")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !resultsManager.contourResults.isEmpty {
                    Button(role: .destructive) { showClearConfirm = true } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .alert("Clear All Contour Results?", isPresented: $showClearConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                resultsManager.clearContourDetectionResults()
            }
        } message: {
            Text("This will remove all stored contour detection results.")
        }
        .sheet(item: $selectedResult) { result in
            ContourResultDetailView(result: result)
        }
    }

    private func deleteResults(at offsets: IndexSet) {
        resultsManager.deleteContourDetectionResults(at: offsets)
    }
}

// MARK: - Row

private struct ContourResultRow: View {
    let result: StoredContourDetectionResult

    var body: some View {
        HStack(spacing: 12) {
            if let thumb = result.thumbnailImage ?? result.image {
                Image(uiImage: thumb)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(result.totalContourCount) contours")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    Text(result.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 12) {
                    Label("Avg \(Int(result.averageConfidence * 100))%", systemImage: "percent")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // Show up to two type counts
                    ForEach(typeSummary.prefix(2), id: \.key) { key, value in
                        Text("\(key): \(value)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.gray.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var typeSummary: [(key: String, value: Int)] {
        result.typeBreakdown.sorted { $0.value > $1.value }
    }
}

// MARK: - Detail

private struct ContourResultDetailView: View {
    let result: StoredContourDetectionResult
    @Environment(\.dismiss) private var dismiss
    @State private var showImage = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let image = result.image {
                    Button(action: { showImage = true }) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Summary")
                        .font(.headline)
                    StatRow(label: "Contours", value: "\(result.totalContourCount)")
                    StatRow(label: "Average Confidence", value: "\(Int(result.averageConfidence * 100))%")
                }

                if !result.typeBreakdown.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Types")
                            .font(.headline)
                        ForEach(result.typeBreakdown.sorted { $0.key < $1.key }, id: \.key) { key, value in
                            StatRow(label: key, value: "\(value)")
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Contour Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImage) {
            if let image = result.image {
                ImageDetailView(image: image)
            }
        }
    }
}

