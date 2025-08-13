//
//  DetectionResultsManager.swift
//  apus
//
//  Created by Rovo Dev on 3/8/2025.
//

import Foundation
import UIKit
import SwiftUI

/// Manager for storing and retrieving detection results with AppStorage
class DetectionResultsManager: ObservableObject {

    // MARK: - AppStorage Properties

    @AppStorage("stored_ocr_results") private var ocrResultsData: Data = Data()
    @AppStorage("stored_object_detection_results") private var objectDetectionResultsData: Data = Data()
    @AppStorage("stored_classification_results") private var classificationResultsData: Data = Data()

    // MARK: - Published Properties

    @Published var ocrResults: [StoredOCRResult] = [] {
        didSet { updateCachedValues() }
    }
    @Published var objectDetectionResults: [StoredObjectDetectionResult] = [] {
        didSet { updateCachedValues() }
    }
    @Published var classificationResults: [StoredClassificationResult] = [] {
        didSet { updateCachedValues() }
    }
    @Published var isLoading: Bool = true

    // Cached computed properties to avoid recalculation
    @Published private(set) var cachedTotalCount: Int = 0
    @Published private(set) var cachedHasResults: Bool = false

    // MARK: - Constants

    private let maxResultsPerCategory = 10
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Initialization

    init() {
        loadAllResultsAsync()
    }

    // MARK: - OCR Results Management

    func saveOCRResult(detectedTexts: [DetectedText], image: UIImage) {
        let newResult = StoredOCRResult(detectedTexts: detectedTexts, image: image)

        // Add to beginning of array and limit to max count
        ocrResults.insert(newResult, at: 0)
        if ocrResults.count > maxResultsPerCategory {
            ocrResults = Array(ocrResults.prefix(maxResultsPerCategory))
        }

        updateCachedValues()
        saveOCRResults()
    }

    func clearOCRResults() {
        ocrResults.removeAll()
        saveOCRResults()
        // Ensure cached values reflect immediate change
        updateCachedValues()
    }

    private func saveOCRResults() {
        let resultsToSave = ocrResults // Capture current state
        Task.detached(priority: .utility) {
            do {
                let data = try self.encoder.encode(resultsToSave)
                await MainActor.run {
                    self.ocrResultsData = data
                }
            } catch {
                print("Failed to save OCR results: \(error)")
            }
        }
    }

    private func loadOCRResults() {
        guard !ocrResultsData.isEmpty else { return }

        do {
            ocrResults = try decoder.decode([StoredOCRResult].self, from: ocrResultsData)
        } catch {
            print("Failed to load OCR results: \(error)")
            ocrResults = []
        }
    }

    // MARK: - Object Detection Results Management

    func saveObjectDetectionResult(detectedObjects: [DetectedObject], image: UIImage) {
        let newResult = StoredObjectDetectionResult(detectedObjects: detectedObjects, image: image)

        // Add to beginning of array and limit to max count
        objectDetectionResults.insert(newResult, at: 0)
        if objectDetectionResults.count > maxResultsPerCategory {
            objectDetectionResults = Array(objectDetectionResults.prefix(maxResultsPerCategory))
        }

        updateCachedValues()
        saveObjectDetectionResults()
    }

    func clearObjectDetectionResults() {
        objectDetectionResults.removeAll()
        saveObjectDetectionResults()
        updateCachedValues()
    }

    private func saveObjectDetectionResults() {
        let resultsToSave = objectDetectionResults // Capture current state
        Task.detached(priority: .utility) {
            do {
                let data = try self.encoder.encode(resultsToSave)
                await MainActor.run {
                    self.objectDetectionResultsData = data
                }
            } catch {
                print("Failed to save object detection results: \(error)")
            }
        }
    }

    private func loadObjectDetectionResults() {
        guard !objectDetectionResultsData.isEmpty else { return }

        do {
            objectDetectionResults = try decoder.decode([StoredObjectDetectionResult].self, from: objectDetectionResultsData)
        } catch {
            print("Failed to load object detection results: \(error)")
            objectDetectionResults = []
        }
    }

    // MARK: - Classification Results Management

    func saveClassificationResult(classificationResults: [ClassificationResult], image: UIImage) {
        let newResult = StoredClassificationResult(classificationResults: classificationResults, image: image)

        // Add to beginning of array and limit to max count
        self.classificationResults.insert(newResult, at: 0)
        if self.classificationResults.count > maxResultsPerCategory {
            self.classificationResults = Array(self.classificationResults.prefix(maxResultsPerCategory))
        }

        updateCachedValues()
        saveClassificationResults()
    }

    func clearClassificationResults() {
        classificationResults.removeAll()
        saveClassificationResults()
        updateCachedValues()
    }

    private func saveClassificationResults() {
        let resultsToSave = classificationResults // Capture current state
        Task.detached(priority: .utility) {
            do {
                let data = try self.encoder.encode(resultsToSave)
                await MainActor.run {
                    self.classificationResultsData = data
                }
            } catch {
                print("Failed to save classification results: \(error)")
            }
        }
    }

    private func loadClassificationResults() {
        guard !classificationResultsData.isEmpty else { return }

        do {
            classificationResults = try decoder.decode([StoredClassificationResult].self, from: classificationResultsData)
        } catch {
            print("Failed to load classification results: \(error)")
            classificationResults = []
        }
    }

    // MARK: - General Management

    private func loadAllResultsAsync() {
        Task {
            await loadAllResults()
        }
    }

    @MainActor
    private func loadAllResults() async {
        // Load all results on background queue to avoid blocking main thread
        let (ocrData, objectData, classificationData) = (ocrResultsData, objectDetectionResultsData, classificationResultsData)

        let results = await withTaskGroup(of: (String, Any).self) { group in
            var loadedResults: [String: Any] = [:]

            group.addTask {
                let ocr = await self.loadOCRResultsAsync(from: ocrData)
                return ("ocr", ocr)
            }

            group.addTask {
                let objects = await self.loadObjectDetectionResultsAsync(from: objectData)
                return ("objects", objects)
            }

            group.addTask {
                let classifications = await self.loadClassificationResultsAsync(from: classificationData)
                return ("classifications", classifications)
            }

            for await (key, value) in group {
                loadedResults[key] = value
            }

            return loadedResults
        }

        // Update published properties on main actor
        if let ocrResults = results["ocr"] as? [StoredOCRResult] {
            self.ocrResults = ocrResults
        }
        if let objectResults = results["objects"] as? [StoredObjectDetectionResult] {
            self.objectDetectionResults = objectResults
        }
        if let classificationResults = results["classifications"] as? [StoredClassificationResult] {
            self.classificationResults = classificationResults
        }

        // Update cached values and mark loading as complete
        updateCachedValues()
        self.isLoading = false
    }

    private func loadOCRResultsAsync(from data: Data) async -> [StoredOCRResult] {
        guard !data.isEmpty else { return [] }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let results = try self.decoder.decode([StoredOCRResult].self, from: data)
                    continuation.resume(returning: results)
                } catch {
                    print("Failed to load OCR results: \(error)")
                    continuation.resume(returning: [])
                }
            }
        }
    }

    private func loadObjectDetectionResultsAsync(from data: Data) async -> [StoredObjectDetectionResult] {
        guard !data.isEmpty else { return [] }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let results = try self.decoder.decode([StoredObjectDetectionResult].self, from: data)
                    continuation.resume(returning: results)
                } catch {
                    print("Failed to load object detection results: \(error)")
                    continuation.resume(returning: [])
                }
            }
        }
    }

    private func loadClassificationResultsAsync(from data: Data) async -> [StoredClassificationResult] {
        guard !data.isEmpty else { return [] }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let results = try self.decoder.decode([StoredClassificationResult].self, from: data)
                    continuation.resume(returning: results)
                } catch {
                    print("Failed to load classification results: \(error)")
                    continuation.resume(returning: [])
                }
            }
        }
    }

    func clearAllResults() {
        clearOCRResults()
        clearObjectDetectionResults()
        clearClassificationResults()
        updateCachedValues()
    }

    // MARK: - Statistics

    var totalResultsCount: Int {
        return cachedTotalCount
    }

    var hasAnyResults: Bool {
        return cachedHasResults
    }

    private func updateCachedValues() {
        let newTotalCount = ocrResults.count + objectDetectionResults.count + classificationResults.count
        cachedTotalCount = newTotalCount
        cachedHasResults = newTotalCount > 0
    }

    func getResultsCount(for category: DetectionCategory) -> Int {
        switch category {
        case .ocr:
            return ocrResults.count
        case .objectDetection:
            return objectDetectionResults.count
        case .classification:
            return classificationResults.count
        }
    }
}

// MARK: - Detection Category Enum

enum DetectionCategory: String, CaseIterable {
    case ocr = "OCR"
    case objectDetection = "Object Detection"
    case classification = "Classification"

    var icon: String {
        switch self {
        case .ocr:
            return "textformat"
        case .objectDetection:
            return "viewfinder"
        case .classification:
            return "brain.head.profile"
        }
    }

    var color: Color {
        switch self {
        case .ocr:
            return .purple
        case .objectDetection:
            return .blue
        case .classification:
            return .green
        }
    }
}
