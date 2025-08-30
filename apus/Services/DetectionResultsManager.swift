//
//  DetectionResultsManager.swift
//  apus
//
//  Created by Rovo Dev on 3/8/2025.
//

import Foundation
import UIKit
import SwiftUI
import Vision

/// Manager for storing and retrieving detection results with AppStorage
class DetectionResultsManager: ObservableObject {

    // Reference to app settings for storage limits
    let appSettings = AppSettings.shared

    // MARK: - AppStorage Properties

    @AppStorage("stored_ocr_results") var ocrResultsData: Data = Data()
    @AppStorage("stored_object_detection_results") var objectDetectionResultsData: Data = Data()
    @AppStorage("stored_classification_results") var classificationResultsData: Data = Data()
    @AppStorage("stored_contour_detection_results") var contourDetectionResultsData: Data = Data()
    @AppStorage("stored_barcode_detection_results") var barcodeDetectionResultsData: Data = Data()

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
    @Published var contourResults: [StoredContourDetectionResult] = [] {
        didSet { updateCachedValues() }
    }
    @Published var barcodeResults: [StoredBarcodeDetectionResult] = [] {
        didSet { updateCachedValues() }
    }
    @Published var isLoading: Bool = true

    // Cached computed properties to avoid recalculation
    @Published private(set) var cachedTotalCount: Int = 0
    @Published private(set) var cachedHasResults: Bool = false

    // MARK: - Constants

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    // MARK: - Initialization

    init() {
        loadAllResultsAsync()
    }

    // MARK: - Feature Results are split into extensions

    // Delete specific Classification results
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

    // See DetectionResultsManager+Classification.swift

    // MARK: - General Management

    private func loadAllResultsAsync() {
        Task {
            await loadAllResults()
        }
    }

    @MainActor
    private func loadAllResults() async {
        // Load all results on background queue to avoid blocking main thread
        let ocrData = ocrResultsData
        let objectData = objectDetectionResultsData
        let classificationData = classificationResultsData
        let contourData = contourDetectionResultsData
        let barcodeData = barcodeDetectionResultsData

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

            group.addTask {
                let contours = await self.loadContourDetectionResultsAsync(from: contourData)
                return ("contours", contours)
            }

            group.addTask {
                let barcodes = await self.loadBarcodeDetectionResultsAsync(from: barcodeData)
                return ("barcodes", barcodes)
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
        if let contourResults = results["contours"] as? [StoredContourDetectionResult] {
            self.contourResults = contourResults
        }
        if let barcodeResults = results["barcodes"] as? [StoredBarcodeDetectionResult] {
            self.barcodeResults = barcodeResults
        }

        // Update cached values and mark loading as complete
        updateCachedValues()
        self.isLoading = false
    }

    // Async loaders moved to DetectionResultsManager+AsyncLoading.swift

    // MARK: - Statistics

    var totalResultsCount: Int {
        return cachedTotalCount
    }

    var hasAnyResults: Bool {
        return cachedHasResults
    }

    func updateCachedValues() {
        let newTotalCount = ocrResults.count + objectDetectionResults.count + classificationResults.count + contourResults.count + barcodeResults.count
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
        case .contourDetection:
            return contourResults.count
        case .barcode:
            return barcodeResults.count
        }
    }

    func clearAllResults() {
        clearOCRResults()
        clearObjectDetectionResults()
        clearClassificationResults()
        clearContourDetectionResults()
        clearBarcodeDetectionResults()
        updateCachedValues()
    }
}

// MARK: - Barcode Detection Results Management

// Barcode management moved to DetectionResultsManager+Barcode.swift

// MARK: - Contour Detection Results Management

// Contour management moved to DetectionResultsManager+Contour.swift

// MARK: - Helper Extensions
// Helpers moved to DetectionResultsManager+Helpers.swift
