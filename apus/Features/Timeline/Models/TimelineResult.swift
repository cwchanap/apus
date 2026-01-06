//
//  TimelineResult.swift
//  apus
//
//  Created by Claude Code on 5/1/2026.
//

import Foundation
import UIKit

// MARK: - Timeline Result Wrapper

/// Type-erased wrapper for all detection result types, enabling unified timeline display
enum TimelineResult: Identifiable {
    case ocr(StoredOCRResult)
    case objectDetection(StoredObjectDetectionResult)
    case classification(StoredClassificationResult)
    case contour(StoredContourDetectionResult)
    case barcode(StoredBarcodeDetectionResult)

    // MARK: - Identifiable

    var id: UUID {
        switch self {
        case .ocr(let result): return result.id
        case .objectDetection(let result): return result.id
        case .classification(let result): return result.id
        case .contour(let result): return result.id
        case .barcode(let result): return result.id
        }
    }

    // MARK: - Common Properties

    var timestamp: Date {
        switch self {
        case .ocr(let result): return result.timestamp
        case .objectDetection(let result): return result.timestamp
        case .classification(let result): return result.timestamp
        case .contour(let result): return result.timestamp
        case .barcode(let result): return result.timestamp
        }
    }

    var category: DetectionCategory {
        switch self {
        case .ocr: return .ocr
        case .objectDetection: return .objectDetection
        case .classification: return .classification
        case .contour: return .contourDetection
        case .barcode: return .barcode
        }
    }

    var thumbnailImage: UIImage? {
        switch self {
        case .ocr(let result): return result.thumbnailImage
        case .objectDetection(let result): return result.thumbnailImage
        case .classification(let result): return result.thumbnailImage
        case .contour(let result): return result.thumbnailImage
        case .barcode(let result): return result.thumbnailImage
        }
    }

    /// Preview text for display in timeline row
    var previewText: String {
        switch self {
        case .ocr(let result):
            let text = result.allText
            if text.isEmpty { return "No text detected" }
            return String(text.prefix(50)) + (text.count > 50 ? "..." : "")

        case .objectDetection(let result):
            let classes = result.uniqueClasses
            if classes.isEmpty { return "No objects detected" }
            return classes.prefix(3).joined(separator: ", ")

        case .classification(let result):
            guard let top = result.topResult else { return "No classification" }
            return top.identifier.capitalized

        case .contour(let result):
            let count = result.totalContourCount
            if count == 0 { return "No contours detected" }
            let types = result.typeBreakdown.keys.prefix(2).joined(separator: ", ")
            return types.isEmpty ? "\(count) contours" : types

        case .barcode(let result):
            guard let first = result.detectedBarcodes.first else { return "No barcodes detected" }
            let payload = first.payload
            return payload.isEmpty ? first.symbology : String(payload.prefix(30))
        }
    }

    /// Statistics text for display in timeline row
    var statsText: String {
        switch self {
        case .ocr(let result):
            return "\(result.totalTextCount) texts \u{2022} \(Int(result.averageConfidence * 100))%"

        case .objectDetection(let result):
            return "\(result.totalObjectCount) objects \u{2022} \(result.framework)"

        case .classification(let result):
            if let top = result.topResult {
                return "\(Int(top.confidence * 100))% confidence"
            }
            return "No results"

        case .contour(let result):
            return "\(result.totalContourCount) contours \u{2022} \(Int(result.averageConfidence * 100))%"

        case .barcode(let result):
            let count = result.totalBarcodeCount
            if count == 1, let first = result.detectedBarcodes.first {
                return first.symbology
            }
            return "\(count) barcodes"
        }
    }

    // MARK: - Search Support

    /// Returns true if this result matches the search query
    /// Searches OCR text content and object class names
    func matchesSearch(_ query: String) -> Bool {
        guard !query.isEmpty else { return true }

        let lowercasedQuery = query.lowercased()

        switch self {
        case .ocr(let result):
            return result.allText.lowercased().contains(lowercasedQuery)

        case .objectDetection(let result):
            return result.uniqueClasses.contains { $0.lowercased().contains(lowercasedQuery) }

        case .classification(let result):
            return result.classificationResults.contains {
                $0.identifier.lowercased().contains(lowercasedQuery)
            }

        case .contour(let result):
            return result.typeBreakdown.keys.contains {
                $0.lowercased().contains(lowercasedQuery)
            }

        case .barcode(let result):
            return result.detectedBarcodes.contains {
                $0.payload.lowercased().contains(lowercasedQuery) ||
                $0.symbology.lowercased().contains(lowercasedQuery)
            }
        }
    }

    // MARK: - Grouping Support

    /// Returns the timeline group for this result based on its timestamp
    func group(relativeTo referenceDate: Date = Date()) -> TimelineGroup {
        let calendar = Calendar.current

        if calendar.isDateInToday(timestamp) {
            return .today
        }

        if calendar.isDateInYesterday(timestamp) {
            return .yesterday
        }

        // This week (within last 7 days)
        if let weekAgo = calendar.date(byAdding: .day, value: -7, to: referenceDate),
           timestamp > weekAgo {
            return .thisWeek
        }

        // Last week (8-14 days ago)
        if let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: referenceDate),
           timestamp > twoWeeksAgo {
            return .lastWeek
        }

        return .older
    }
}

// MARK: - Timeline Group

/// Groups for organizing timeline results by relative time period
enum TimelineGroup: String, CaseIterable {
    case today = "Today"
    case yesterday = "Yesterday"
    case thisWeek = "This Week"
    case lastWeek = "Last Week"
    case older = "Older"

    /// Sort order for displaying groups (most recent first)
    var sortOrder: Int {
        switch self {
        case .today: return 0
        case .yesterday: return 1
        case .thisWeek: return 2
        case .lastWeek: return 3
        case .older: return 4
        }
    }
}

// MARK: - Date Filter Presets

/// Preset date ranges for filtering timeline results
enum DateFilterPreset: String, CaseIterable {
    case all = "All Time"
    case today = "Today"
    case last7Days = "Last 7 Days"
    case last30Days = "Last 30 Days"

    /// Returns true if the given date falls within this preset's range
    func includes(_ date: Date, relativeTo referenceDate: Date = Date()) -> Bool {
        let calendar = Calendar.current

        switch self {
        case .all:
            return true

        case .today:
            return calendar.isDateInToday(date)

        case .last7Days:
            guard let cutoff = calendar.date(byAdding: .day, value: -7, to: referenceDate) else {
                return false
            }
            return date > cutoff

        case .last30Days:
            guard let cutoff = calendar.date(byAdding: .day, value: -30, to: referenceDate) else {
                return false
            }
            return date > cutoff
        }
    }
}
