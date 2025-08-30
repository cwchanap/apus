//
//  DetectionResultsManager+ObjectDetection.swift
//  apus
//

import Foundation
import UIKit

extension DetectionResultsManager {
    // MARK: - Object Detection Results Management

    func saveObjectDetectionResult(detectedObjects: [DetectedObject], image: UIImage) {
        let newResult = StoredObjectDetectionResult(detectedObjects: detectedObjects, image: image)

        objectDetectionResults.insert(newResult, at: 0)
        let limit = appSettings.getStorageLimit(for: .objectDetection)
        enforceLimit(for: &objectDetectionResults, limit: limit)

        updateCachedValues()
        saveObjectDetectionResults()
    }

    func clearObjectDetectionResults() {
        objectDetectionResults.removeAll()
        saveObjectDetectionResults()
        updateCachedValues()
    }

    func deleteObjectDetectionResults(at offsets: IndexSet) {
        objectDetectionResults.remove(atOffsets: offsets)
        saveObjectDetectionResults()
        updateCachedValues()
    }

    func deleteObjectDetectionResult(id: UUID) {
        if let index = objectDetectionResults.firstIndex(where: { $0.id == id }) {
            objectDetectionResults.remove(at: index)
            saveObjectDetectionResults()
            updateCachedValues()
        }
    }

    func saveObjectDetectionResults() {
        let resultsToSave = objectDetectionResults
        Task.detached(priority: .utility) {
            do {
                let data = try self.encoder.encode(resultsToSave)
                await MainActor.run { self.objectDetectionResultsData = data }
            } catch {
                print("Failed to save object detection results: \(error)")
            }
        }
    }

    func loadObjectDetectionResults() {
        guard !objectDetectionResultsData.isEmpty else { return }
        do {
            objectDetectionResults = try decoder.decode([StoredObjectDetectionResult].self, from: objectDetectionResultsData)
        } catch {
            print("Failed to load object detection results: \(error)")
            objectDetectionResults = []
        }
    }
}
