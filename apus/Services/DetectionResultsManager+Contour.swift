//
//  DetectionResultsManager+Contour.swift
//  apus
//

import Foundation
import UIKit

extension DetectionResultsManager {
    // MARK: - Contour Detection Results Management

    func saveContourDetectionResult(detectedContours: [DetectedContour], image: UIImage) {
        let newResult = StoredContourDetectionResult(detectedContours: detectedContours, image: image)

        contourResults.insert(newResult, at: 0)
        let limit = appSettings.getStorageLimit(for: .contourDetection)
        enforceLimit(for: &contourResults, limit: limit)

        updateCachedValues()
        saveContourDetectionResults()
    }

    func clearContourDetectionResults() {
        contourResults.removeAll()
        saveContourDetectionResults()
        updateCachedValues()
    }

    func deleteContourDetectionResults(at offsets: IndexSet) {
        contourResults.remove(atOffsets: offsets)
        saveContourDetectionResults()
        updateCachedValues()
    }

    func deleteContourDetectionResult(id: UUID) {
        if let index = contourResults.firstIndex(where: { $0.id == id }) {
            contourResults.remove(at: index)
            saveContourDetectionResults()
            updateCachedValues()
        }
    }

    func saveContourDetectionResults() {
        let resultsToSave = contourResults
        Task.detached(priority: .utility) {
            do {
                let data = try self.encoder.encode(resultsToSave)
                await MainActor.run { self.contourDetectionResultsData = data }
            } catch {
                print("Failed to save contour detection results: \(error)")
            }
        }
    }

    func loadContourDetectionResults() {
        guard !contourDetectionResultsData.isEmpty else { return }
        do {
            contourResults = try decoder.decode([StoredContourDetectionResult].self, from: contourDetectionResultsData)
        } catch {
            print("Failed to load contour detection results: \(error)")
            contourResults = []
        }
    }
}
