//
//  TimelineView.swift
//  apus
//
//  Created by Claude Code on 5/1/2026.
//

import SwiftUI

// MARK: - Timeline View

/// Main timeline view showing all detection results in chronological order
/// with filtering by category, search, and date range
struct TimelineView: View {
    @StateObject private var viewModel = TimelineViewModel()

    /// Currently selected result for detail sheet presentation
    @State private var selectedResult: TimelineResult?

    var body: some View {
        VStack(spacing: 0) {
            // Filter bar (search, categories, date presets)
            TimelineFilterBar(viewModel: viewModel)

            // Results count indicator
            if !viewModel.isEmpty {
                resultsCountBar
            }

            // Timeline content
            if viewModel.isEmpty {
                EmptyTimelineView(hasFilters: viewModel.hasActiveFilters) {
                    viewModel.clearFilters()
                }
            } else if viewModel.sections.isEmpty {
                EmptyTimelineView(hasFilters: viewModel.hasActiveFilters) {
                    viewModel.clearFilters()
                }
            } else {
                timelineList
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Timeline")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.hasActiveFilters {
                    Button("Clear") {
                        viewModel.clearFilters()
                    }
                }
            }
        }
        .sheet(item: $selectedResult) { result in
            TimelineDetailSheet(result: result)
        }
    }

    // MARK: - Results Count Bar

    private var resultsCountBar: some View {
        HStack {
            Text("\(viewModel.filteredCount) results")
                .font(.caption)
                .foregroundColor(.secondary)

            if viewModel.hasActiveFilters {
                Text("\u{2022}")
                    .foregroundColor(.secondary)

                Text("Filtered")
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Timeline List

    private var timelineList: some View {
        ScrollView {
            LazyVStack(spacing: 12, pinnedViews: .sectionHeaders) {
                ForEach(viewModel.sections) { section in
                    Section {
                        ForEach(section.results, id: \.id) { result in
                            TimelineRowView(result: result)
                                .onTapGesture {
                                    selectedResult = result
                                }
                                .padding(.horizontal)
                        }
                    } header: {
                        TimelineSectionHeader(title: section.title)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Timeline Detail Sheet

/// Sheet that presents the appropriate detail view based on result category
struct TimelineDetailSheet: View {
    let result: TimelineResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            detailContent
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private var detailContent: some View {
        switch result {
        case .ocr(let ocrResult):
            TimelineOCRDetailView(result: ocrResult)

        case .objectDetection(let objResult):
            TimelineObjectDetectionDetailView(result: objResult)

        case .classification(let classResult):
            TimelineClassificationDetailView(result: classResult)

        case .contour(let contourResult):
            TimelineContourDetectionDetailView(result: contourResult)

        case .barcode(let barcodeResult):
            TimelineBarcodeDetectionDetailView(result: barcodeResult)
        }
    }
}

// MARK: - Detail View Wrappers

/// OCR result detail view wrapper for timeline
struct TimelineOCRDetailView: View {
    let result: StoredOCRResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image
                if let image = result.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Stats
                VStack(spacing: 8) {
                    StatRow(label: "Text Blocks", value: "\(result.totalTextCount)")
                    StatRow(label: "Average Confidence", value: "\(Int(result.averageConfidence * 100))%")
                    StatRow(label: "Captured", value: result.timestamp.formatted(date: .abbreviated, time: .shortened))
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Detected text
                if !result.allText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Detected Text")
                            .font(.headline)

                        Text(result.allText)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("OCR Result")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Object detection result detail view wrapper for timeline
struct TimelineObjectDetectionDetailView: View {
    let result: StoredObjectDetectionResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image
                if let image = result.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Stats
                VStack(spacing: 8) {
                    StatRow(label: "Objects Detected", value: "\(result.totalObjectCount)")
                    StatRow(label: "Framework", value: result.framework)
                    StatRow(label: "Average Confidence", value: "\(Int(result.averageConfidence * 100))%")
                    StatRow(label: "Captured", value: result.timestamp.formatted(date: .abbreviated, time: .shortened))
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Detected objects
                if !result.detectedObjects.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Detected Objects")
                            .font(.headline)

                        ForEach(result.detectedObjects) { obj in
                            HStack {
                                Text(obj.className)
                                    .font(.body)
                                Spacer()
                                Text("\(Int(obj.confidence * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("Object Detection")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Classification result detail view wrapper for timeline
struct TimelineClassificationDetailView: View {
    let result: StoredClassificationResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image
                if let image = result.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Stats
                VStack(spacing: 8) {
                    if let top = result.topResult {
                        StatRow(label: "Top Result", value: top.identifier.capitalized)
                        StatRow(label: "Confidence", value: "\(Int(top.confidence * 100))%")
                    }
                    StatRow(label: "Captured", value: result.timestamp.formatted(date: .abbreviated, time: .shortened))
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // All classifications
                if !result.classificationResults.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("All Classifications")
                            .font(.headline)

                        ForEach(result.classificationResults) { classification in
                            HStack {
                                Text(classification.identifier.capitalized)
                                    .font(.body)
                                Spacer()
                                Text("\(Int(classification.confidence * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("Classification")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Contour detection result detail view wrapper for timeline
struct TimelineContourDetectionDetailView: View {
    let result: StoredContourDetectionResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image
                if let image = result.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Stats
                VStack(spacing: 8) {
                    StatRow(label: "Contours Detected", value: "\(result.totalContourCount)")
                    StatRow(label: "Average Confidence", value: "\(Int(result.averageConfidence * 100))%")
                    StatRow(label: "Captured", value: result.timestamp.formatted(date: .abbreviated, time: .shortened))
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Type breakdown
                if !result.typeBreakdown.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Contour Types")
                            .font(.headline)

                        ForEach(Array(result.typeBreakdown.keys.sorted()), id: \.self) { type in
                            HStack {
                                Text(type)
                                    .font(.body)
                                Spacer()
                                Text("\(result.typeBreakdown[type] ?? 0)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("Contour Detection")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Barcode detection result detail view wrapper for timeline
struct TimelineBarcodeDetectionDetailView: View {
    let result: StoredBarcodeDetectionResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image
                if let image = result.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Stats
                VStack(spacing: 8) {
                    StatRow(label: "Barcodes Detected", value: "\(result.totalBarcodeCount)")
                    StatRow(label: "Captured", value: result.timestamp.formatted(date: .abbreviated, time: .shortened))
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Detected barcodes
                if !result.detectedBarcodes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detected Barcodes")
                            .font(.headline)

                        ForEach(result.detectedBarcodes) { barcode in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(barcode.symbology)
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                if !barcode.payload.isEmpty {
                                    Text(barcode.payload)
                                        .font(.body)
                                        .textSelection(.enabled)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("Barcode Detection")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

#if DEBUG
struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TimelineView()
        }
    }
}
#endif
