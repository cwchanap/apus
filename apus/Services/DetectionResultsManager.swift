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
    private let appSettings = AppSettings.shared

    // MARK: - AppStorage Properties

    @AppStorage("stored_ocr_results") private var ocrResultsData: Data = Data()
    @AppStorage("stored_object_detection_results") private var objectDetectionResultsData: Data = Data()
    @AppStorage("stored_classification_results") private var classificationResultsData: Data = Data()
    @AppStorage("stored_contour_detection_results") private var contourDetectionResultsData: Data = Data()
    @AppStorage("stored_barcode_detection_results") private var barcodeDetectionResultsData: Data = Data()

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
        let limit = appSettings.getStorageLimit(for: .ocr)
        enforceLimit(for: &ocrResults, limit: limit)

        updateCachedValues()
        saveOCRResults()
    }

    func clearOCRResults() {
        ocrResults.removeAll()
        saveOCRResults()
        // Ensure cached values reflect immediate change
        updateCachedValues()
    }

    // Delete specific OCR results
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

    // Delete specific Object Detection results
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
        let limit = appSettings.getStorageLimit(for: .classification)
        enforceLimit(for: &classificationResults, limit: limit)

        updateCachedValues()
        saveClassificationResults()
    }

    func clearClassificationResults() {
        classificationResults.removeAll()
        saveClassificationResults()
        updateCachedValues()
    }

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

    private func loadBarcodeDetectionResultsAsync(from data: Data) async -> [StoredBarcodeDetectionResult] {
        guard !data.isEmpty else { return [] }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let results = try self.decoder.decode([StoredBarcodeDetectionResult].self, from: data)
                    continuation.resume(returning: results)
                } catch {
                    print("Failed to load barcode detection results: \(error)")
                    continuation.resume(returning: [])
                }
            }
        }
    }

    // MARK: - Statistics

    var totalResultsCount: Int {
        return cachedTotalCount
    }

    var hasAnyResults: Bool {
        return cachedHasResults
    }

    private func updateCachedValues() {
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
}

// MARK: - Barcode Detection Results Management

extension DetectionResultsManager {
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

    private func saveBarcodeDetectionResults() {
        let resultsToSave = barcodeResults
        Task.detached(priority: .utility) {
            do {
                let data = try self.encoder.encode(resultsToSave)
                await MainActor.run {
                    self.barcodeDetectionResultsData = data
                }
            } catch {
                print("Failed to save barcode detection results: \(error)")
            }
        }
    }

    private func loadBarcodeDetectionResults() {
        guard !barcodeDetectionResultsData.isEmpty else { return }
        do {
            barcodeResults = try decoder.decode([StoredBarcodeDetectionResult].self, from: barcodeDetectionResultsData)
        } catch {
            print("Failed to load barcode detection results: \(error)")
            barcodeResults = []
        }
    }
}

// MARK: - Contour Detection Results Management

extension DetectionResultsManager {
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

    private func saveContourDetectionResults() {
        let resultsToSave = contourResults
        Task.detached(priority: .utility) {
            do {
                let data = try self.encoder.encode(resultsToSave)
                await MainActor.run {
                    self.contourDetectionResultsData = data
                }
            } catch {
                print("Failed to save contour detection results: \(error)")
            }
        }
    }

    private func loadContourDetectionResults() {
        guard !contourDetectionResultsData.isEmpty else { return }
        do {
            contourResults = try decoder.decode([StoredContourDetectionResult].self, from: contourDetectionResultsData)
        } catch {
            print("Failed to load contour detection results: \(error)")
            contourResults = []
        }
    }

    private func loadContourDetectionResultsAsync(from data: Data) async -> [StoredContourDetectionResult] {
        guard !data.isEmpty else { return [] }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let results = try self.decoder.decode([StoredContourDetectionResult].self, from: data)
                    continuation.resume(returning: results)
                } catch {
                    print("Failed to load contour detection results: \(error)")
                    continuation.resume(returning: [])
                }
            }
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

// MARK: - Helper Extensions
private extension DetectionResultsManager {
    func enforceLimit<T>(for results: inout [T], limit: Int) {
        if results.count > limit {
            results = Array(results.prefix(limit))
        }
    }
}
