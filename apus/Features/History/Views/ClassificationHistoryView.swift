//
//  ClassificationHistoryView.swift
//  apus
//
//  Created by Rovo Dev on 30/7/2025.
//

import SwiftUI

struct ClassificationHistoryView: View {
    @Injected private var historyManager: ClassificationHistoryManager
    @State private var selectedItem: ClassificationHistoryItem?
    @State private var showingDeleteAlert = false
    @Injected private var hapticService: HapticServiceProtocol
    
    var body: some View {
        NavigationView {
            Group {
                if historyManager.historyItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Classification History")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Classify some images to see your history here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(historyManager.historyItems) { item in
                            HistoryItemRow(item: item) {
                                selectedItem = item
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
            }
            .navigationTitle("Classification History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !historyManager.historyItems.isEmpty {
                        Button("Clear All") {
                            hapticService.warning()
                            showingDeleteAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .alert("Clear History", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    hapticService.strongFeedback()
                    historyManager.clearHistory()
                }
            } message: {
                Text("Are you sure you want to clear all classification history? This action cannot be undone.")
            }
            .sheet(item: $selectedItem) { item in
                HistoryDetailView(item: item)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        hapticService.actionFeedback()
        for index in offsets {
            historyManager.deleteItem(at: index)
        }
    }
}

struct HistoryItemRow: View {
    let item: ClassificationHistoryItem
    let onTap: () -> Void
    @Injected private var hapticService: HapticServiceProtocol
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        Button(action: {
            hapticService.buttonTap()
            onTap()
        }) {
            HStack(spacing: 12) {
                // Thumbnail
                if let image = item.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
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
                    if let topResult = item.results.first {
                        Text(topResult.identifier.capitalized)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text("\(Int(topResult.confidence * 100))% confidence")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Timestamp
                    Text(dateFormatter.string(from: item.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Additional results count
                    if item.results.count > 1 {
                        Text("+\(item.results.count - 1) more results")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
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

struct HistoryDetailView: View {
    let item: ClassificationHistoryItem
    @Environment(\.dismiss) private var dismiss
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        return formatter
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image
                    if let image = item.image {
                        ZoomableImageView(image: image)
                            .frame(height: 300)
                            .background(Color.black)
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Timestamp
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Classified")
                                .font(.headline)
                            Text(dateFormatter.string(from: item.timestamp))
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        // Classification Results
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Results")
                                .font(.headline)
                            
                            ForEach(Array(item.results.enumerated()), id: \.offset) { index, result in
                                HStack {
                                    Text("\(index + 1).")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .frame(width: 20, alignment: .leading)
                                    
                                    Text(result.identifier.capitalized)
                                        .font(.body)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(result.confidence * 100))%")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Classification Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    ClassificationHistoryView()
}
#endif