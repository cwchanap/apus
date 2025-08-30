//
//  DetectionResultsManager+OCR.swift
//  apus
//

import Foundation
import UIKit

extension DetectionResultsManager {
    // MARK: - OCR Results Management

    func saveOCRResult(detectedTexts: [DetectedText], image: UIImage) {
        let newResult = StoredOCRResult(detectedTexts: detectedTexts, image: image)

        ocrResults.insert(newResult, at: 0)
        let limit = appSettings.getStorageLimit(for: .ocr)
        enforceLimit(for: &ocrResults, limit: limit)

        updateCachedValues()
        saveOCRResults()
    }

    func clearOCRResults() {
        ocrResults.removeAll()
        saveOCRResults()
        updateCachedValues()
    }

    func deleteOCRResults(at offsets: IndexSet) {
        ocrResults.remove(atOffsets: offsets)
        saveOCRResults()
        updateCachedValues()
    }

    func deleteOCRResult(id: UUID) {
        if let index = ocrResults.firstIndex(where: { $0.id == id }) {
            ocrResults.remove(at: index)
            saveOCRResults()
            updateCachedValues()
        }
    }

    func saveOCRResults() {
        let resultsToSave = ocrResults
        Task.detached(priority: .utility) {
            do {
                let data = try self.encoder.encode(resultsToSave)
                await MainActor.run { self.ocrResultsData = data }
            } catch {
                print("Failed to save OCR results: \(error)")
            }
        }
    }

    func loadOCRResults() {
        guard !ocrResultsData.isEmpty else { return }
        do {
            ocrResults = try decoder.decode([StoredOCRResult].self, from: ocrResultsData)
        } catch {
            print("Failed to load OCR results: \(error)")
            ocrResults = []
        }
    }
}
