//
//  DetectionResultsManager+AsyncLoading.swift
//  apus
//

import Foundation

extension DetectionResultsManager {
    // MARK: - Async Loading Helpers

    func loadOCRResultsAsync(from data: Data) async -> [StoredOCRResult] {
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

    func loadObjectDetectionResultsAsync(from data: Data) async -> [StoredObjectDetectionResult] {
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

    func loadClassificationResultsAsync(from data: Data) async -> [StoredClassificationResult] {
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

    func loadBarcodeDetectionResultsAsync(from data: Data) async -> [StoredBarcodeDetectionResult] {
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

    func loadContourDetectionResultsAsync(from data: Data) async -> [StoredContourDetectionResult] {
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
}
