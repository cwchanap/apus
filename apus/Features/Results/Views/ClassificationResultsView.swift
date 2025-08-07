//
//  ClassificationResultsView.swift
//  apus
//
//  Created by Rovo Dev on 3/8/2025.
//

import SwiftUI

struct ClassificationResultsView: View {
    @ObservedObject var resultsManager: DetectionResultsManager
    @State private var selectedResult: StoredClassificationResult?
    @State private var showingDetailView = false

    var body: some View {
        NavigationView {
            Group {
                if resultsManager.classificationResults.isEmpty {
                    EmptyResultsView(
                        category: .classification,
                        message: "No classification results yet",
                        description: "Classify images to see results here"
                    )
                } else {
                    List {
                        ForEach(resultsManager.classificationResults) { result in
                            ClassificationResultRow(result: result) {
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
            .navigationTitle("Classification")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !resultsManager.classificationResults.isEmpty {
                        Button("Clear All") {
                            resultsManager.clearClassificationResults()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingDetailView) {
                if let result = selectedResult {
                    ClassificationResultDetailView(result: result)
                }
            }
        }
    }

    private func deleteResults(at offsets: IndexSet) {
        resultsManager.classificationResults.remove(atOffsets: offsets)
    }
}

struct ClassificationResultRow: View {
    let result: StoredClassificationResult
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
                    // Top classification result
                    if let topResult = result.topResult {
                        Text(topResult.identifier.capitalized)
                            .font(.body)
                            .lineLimit(2)
                            .foregroundColor(.primary)
                    } else {
                        Text("No classification")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    // Statistics
                    HStack(spacing: 16) {
                        Label("\(result.classificationResults.count)", systemImage: "brain.head.profile")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if let topResult = result.topResult {
                            Label("\(Int(topResult.confidence * 100))%", systemImage: "checkmark.circle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Label("\(Int(result.averageConfidence * 100))% avg", systemImage: "chart.bar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Timestamp
                    Text(result.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Confidence indicator
                if let topResult = result.topResult {
                    VStack {
                        Text("\(Int(topResult.confidence * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(confidenceColor(topResult.confidence))

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func confidenceColor(_ confidence: Float) -> Color {
        if confidence > 0.8 {
            return .green
        } else if confidence > 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

struct ClassificationResultDetailView: View {
    let result: StoredClassificationResult
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
                                    .frame(maxHeight: 250)
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
                            if let topResult = result.topResult {
                                StatRow(label: "Top Classification", value: topResult.identifier.capitalized)
                                StatRow(label: "Top Confidence", value: "\(Int(topResult.confidence * 100))%")
                            }
                            StatRow(label: "Total Results", value: "\(result.classificationResults.count)")
                            StatRow(label: "Average Confidence", value: "\(Int(result.averageConfidence * 100))%")
                            StatRow(label: "Image Size", value: "\(Int(result.imageSize.width)) × \(Int(result.imageSize.height))")
                            StatRow(label: "Classified", value: result.timestamp.formatted(date: .abbreviated, time: .shortened))
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Classification results section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Classification Results")
                            .font(.headline)

                        if result.classificationResults.isEmpty {
                            Text("No classifications available")
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(Array(result.classificationResults.enumerated()), id: \.element.id) { index, classification in
                                    ClassificationRow(
                                        classification: classification,
                                        rank: index + 1,
                                        isTopResult: index == 0
                                    )
                                }
                            }
                        }
                    }

                    // Confidence distribution chart
                    if !result.classificationResults.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confidence Distribution")
                                .font(.headline)

                            ConfidenceChartView(results: result.classificationResults)
                                .frame(height: 120)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Classification")
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

struct ClassificationRow: View {
    let classification: StoredClassification
    let rank: Int
    let isTopResult: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Rank indicator
            Text("#\(rank)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isTopResult ? .white : .secondary)
                .frame(width: 24, height: 24)
                .background(isTopResult ? Color.green : Color.gray.opacity(0.3))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(classification.identifier.capitalized)
                    .font(isTopResult ? .body.weight(.semibold) : .body)
                    .foregroundColor(.primary)

                if isTopResult {
                    Text("Top Result")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }

            Spacer()

            // Confidence bar and percentage
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(classification.confidence * 100))%")
                    .font(.caption)
                    .fontWeight(isTopResult ? .semibold : .regular)
                    .foregroundColor(confidenceColor)

                // Confidence bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)

                        Rectangle()
                            .fill(confidenceColor)
                            .frame(width: geometry.size.width * CGFloat(classification.confidence), height: 4)
                    }
                }
                .frame(width: 60, height: 4)
            }
        }
        .padding()
        .background(isTopResult ? Color.green.opacity(0.1) : Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isTopResult ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }

    private var confidenceColor: Color {
        if classification.confidence > 0.8 {
            return .green
        } else if classification.confidence > 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

struct ConfidenceChartView: View {
    let results: [StoredClassification]

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(Array(results.prefix(10).enumerated()), id: \.element.id) { _, result in
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(barColor(for: result.confidence))
                            .frame(width: max(8, (geometry.size.width - CGFloat(results.count - 1) * 2) / CGFloat(min(results.count, 10))),
                                   height: CGFloat(result.confidence) * (geometry.size.height - 20))

                        Text("\(Int(result.confidence * 100))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }

    private func barColor(for confidence: Float) -> Color {
        if confidence > 0.8 {
            return .green
        } else if confidence > 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

#if DEBUG
struct ClassificationResultsView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DetectionResultsManager()

        // Add sample data
        let sampleImage = UIImage(systemName: "photo") ?? UIImage()
        let sampleResults = [
            ClassificationResult(identifier: "golden retriever", confidence: 0.92),
            ClassificationResult(identifier: "dog", confidence: 0.85),
            ClassificationResult(identifier: "animal", confidence: 0.78),
            ClassificationResult(identifier: "pet", confidence: 0.65)
        ]

        manager.saveClassificationResult(classificationResults: sampleResults, image: sampleImage)

        return ClassificationResultsView(resultsManager: manager)
    }
}
#endif
