//
//  DetectionResultsManager+Classification.swift
//  apus
//

import Foundation
import UIKit

extension DetectionResultsManager {
    // MARK: - Classification Results Management

    func saveClassificationResult(classificationResults: [ClassificationResult], image: UIImage) {
        let newResult = StoredClassificationResult(classificationResults: classificationResults, image: image)

        self.classificationResults.insert(newResult, at: 0)
        let limit = appSettings.getStorageLimit(for: .classification)
        enforceLimit(for: &self.classificationResults, limit: limit)

        updateCachedValues()
        saveClassificationResults()
    }

    func clearClassificationResults() {
        classificationResults.removeAll()
        saveClassificationResults()
        updateCachedValues()
    }

    func deleteClassificationResults(at offsets: IndexSet) {
        classificationResults.remove(atOffsets: offsets)
        saveClassificationResults()
        updateCachedValues()
    }

    func deleteClassificationResult(id: UUID) {
        if let index = classificationResults.firstIndex(where: { $0.id == id }) {
            classificationResults.remove(at: index)
            saveClassificationResults()
            updateCachedValues()
        }
    }

    func saveClassificationResults() {
        let resultsToSave = classificationResults
        Task.detached(priority: .utility) {
            do {
                let data = try self.encoder.encode(resultsToSave)
                await MainActor.run { self.classificationResultsData = data }
            } catch {
                print("Failed to save classification results: \(error)")
            }
        }
    }

    func loadClassificationResults() {
        guard !classificationResultsData.isEmpty else { return }
        do {
            classificationResults = try decoder.decode([StoredClassificationResult].self, from: classificationResultsData)
        } catch {
            print("Failed to load classification results: \(error)")
            classificationResults = []
        }
    }
}
