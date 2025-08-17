
//
//  BarcodeDetectionResultsView.swift
//  apus
//
//  Created by wa-ik on 2025/08/17
//
import SwiftUI

struct BarcodeDetectionResultsView: View {
    @EnvironmentObject var resultsManager: DetectionResultsManager
    
    var body: some View {
        List {
            ForEach(resultsManager.barcodeResults) { result in
                VStack(alignment: .leading) {
                    Text("\(result.totalBarcodeCount) barcodes detected")
                        .font(.headline)
                    Text("\(result.timestamp, formatter: dateFormatter)")
                        .font(.subheadline)
                    if let image = result.thumbnailImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                    }
                }
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Barcode Results")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        resultsManager.deleteBarcodeDetectionResults(at: offsets)
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
