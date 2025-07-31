//
//  ClassificationHistory.swift
//  apus
//
//  Created by Rovo Dev on 30/7/2025.
//

import Foundation
import UIKit

struct ClassificationHistoryItem: Identifiable, Codable {
    let id = UUID()
    let timestamp: Date
    let results: [ClassificationResult]
    let imageData: Data
    
    var image: UIImage? {
        return UIImage(data: imageData)
    }
    
    init(results: [ClassificationResult], image: UIImage) {
        self.timestamp = Date()
        self.results = results
        self.imageData = image.jpegData(compressionQuality: 0.8) ?? Data()
    }
}

class ClassificationHistoryManager: ObservableObject {
    @Published var historyItems: [ClassificationHistoryItem] = []
    
    private let userDefaults = UserDefaults.standard
    private let historyKey = "ClassificationHistory"
    private let maxHistoryItems = 50
    
    init() {
        loadHistory()
    }
    
    @MainActor
    func addHistoryItem(_ item: ClassificationHistoryItem) {
        historyItems.insert(item, at: 0) // Add to beginning
        
        // Keep only the most recent items
        if historyItems.count > maxHistoryItems {
            historyItems = Array(historyItems.prefix(maxHistoryItems))
        }
        
        saveHistory()
    }
    
    @MainActor
    func clearHistory() {
        historyItems.removeAll()
        saveHistory()
    }
    
    @MainActor
    func deleteItem(at index: Int) {
        guard index < historyItems.count else { return }
        historyItems.remove(at: index)
        saveHistory()
    }
    
    private func saveHistory() {
        do {
            let data = try JSONEncoder().encode(historyItems)
            userDefaults.set(data, forKey: historyKey)
        } catch {
            print("Failed to save classification history: \(error)")
        }
    }
    
    private func loadHistory() {
        guard let data = userDefaults.data(forKey: historyKey) else { return }
        
        do {
            historyItems = try JSONDecoder().decode([ClassificationHistoryItem].self, from: data)
        } catch {
            print("Failed to load classification history: \(error)")
            historyItems = []
        }
    }
}

// Make ClassificationResult Codable
extension ClassificationResult: Codable {
    enum CodingKeys: String, CodingKey {
        case identifier
        case confidence
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        confidence = try container.decode(Float.self, forKey: .confidence)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(confidence, forKey: .confidence)
    }
}