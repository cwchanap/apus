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
    
    @Published var ocrResults: [StoredOCRResult] = []
    @Published var objectDetectionResults: [StoredObjectDetectionResult] = []
    @Published var classificationResults: [StoredClassificationResult] = []
    
    // MARK: - Constants
    
    private let maxResultsPerCategory = 10
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    
    init() {
        loadAllResults()
    }
    
    // MARK: - OCR Results Management
    
    func saveOCRResult(detectedTexts: [DetectedText], image: UIImage) {
        let newResult = StoredOCRResult(detectedTexts: detectedTexts, image: image)
        
        // Add to beginning of array and limit to max count
        ocrResults.insert(newResult, at: 0)
        if ocrResults.count > maxResultsPerCategory {
            ocrResults = Array(ocrResults.prefix(maxResultsPerCategory))
        }
        
        saveOCRResults()
    }
    
    func clearOCRResults() {
        ocrResults.removeAll()
        saveOCRResults()
    }
    
    private func saveOCRResults() {
        do {
            ocrResultsData = try encoder.encode(ocrResults)
        } catch {
            print("Failed to save OCR results: \(error)")
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
        
        saveObjectDetectionResults()
    }
    
    func clearObjectDetectionResults() {
        objectDetectionResults.removeAll()
        saveObjectDetectionResults()
    }
    
    private func saveObjectDetectionResults() {
        do {
            objectDetectionResultsData = try encoder.encode(objectDetectionResults)
        } catch {
            print("Failed to save object detection results: \(error)")
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
        
        saveClassificationResults()
    }
    
    func clearClassificationResults() {
        classificationResults.removeAll()
        saveClassificationResults()
    }
    
    private func saveClassificationResults() {
        do {
            classificationResultsData = try encoder.encode(classificationResults)
        } catch {
            print("Failed to save classification results: \(error)")
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
    
    private func loadAllResults() {
        loadOCRResults()
        loadObjectDetectionResults()
        loadClassificationResults()
    }
    
    func clearAllResults() {
        clearOCRResults()
        clearObjectDetectionResults()
        clearClassificationResults()
    }
    
    // MARK: - Statistics
    
    var totalResultsCount: Int {
        return ocrResults.count + objectDetectionResults.count + classificationResults.count
    }
    
    var hasAnyResults: Bool {
        return totalResultsCount > 0
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