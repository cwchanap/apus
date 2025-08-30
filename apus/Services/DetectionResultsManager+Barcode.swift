//
//  DetectionResultsManager+Barcode.swift
//  apus
//

import Foundation
import UIKit
import Vision

extension DetectionResultsManager {
    // MARK: - Barcode Detection Results Management

    func saveBarcodeResult(detectedBarcodes: [VNBarcodeObservation], image: UIImage) {
        let newResult = StoredBarcodeDetectionResult(detectedBarcodes: detectedBarcodes, image: image)

        barcodeResults.insert(newResult, at: 0)
        let limit = appSettings.getStorageLimit(for: .barcode)
        enforceLimit(for: &barcodeResults, limit: limit)

        updateCachedValues()
        saveBarcodeDetectionResults()
    }

    func clearBarcodeDetectionResults() {
        barcodeResults.removeAll()
        saveBarcodeDetectionResults()
        updateCachedValues()
    }

    func deleteBarcodeDetectionResults(at offsets: IndexSet) {
        barcodeResults.remove(atOffsets: offsets)
        saveBarcodeDetectionResults()
        updateCachedValues()
    }

    func deleteBarcodeDetectionResult(id: UUID) {
        if let index = barcodeResults.firstIndex(where: { $0.id == id }) {
            barcodeResults.remove(at: index)
            saveBarcodeDetectionResults()
            updateCachedValues()
        }
    }

    func saveBarcodeDetectionResults() {
        let resultsToSave = barcodeResults
        Task.detached(priority: .utility) {
            do {
                let data = try self.encoder.encode(resultsToSave)
                await MainActor.run { self.barcodeDetectionResultsData = data }
            } catch {
                print("Failed to save barcode detection results: \(error)")
            }
        }
    }

    func loadBarcodeDetectionResults() {
        guard !barcodeDetectionResultsData.isEmpty else { return }
        do {
            barcodeResults = try decoder.decode([StoredBarcodeDetectionResult].self, from: barcodeDetectionResultsData)
        } catch {
            print("Failed to load barcode detection results: \(error)")
            barcodeResults = []
        }
    }
}
