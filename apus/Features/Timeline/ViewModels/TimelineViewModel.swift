//
//  TimelineViewModel.swift
//  apus
//
//  Created by Claude Code on 5/1/2026.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Timeline Section

/// Represents a grouped section in the timeline
struct TimelineSection: Identifiable {
    let id = UUID()
    let group: TimelineGroup
    let results: [TimelineResult]

    var title: String {
        group.rawValue
    }
}

// MARK: - Timeline ViewModel

@MainActor
class TimelineViewModel: ObservableObject {

    // MARK: - Published State

    /// Currently selected category filters (multi-select)
    @Published var selectedCategories: Set<DetectionCategory> = Set(DetectionCategory.allCases)

    /// Search query for filtering results
    @Published var searchQuery: String = ""

    /// Selected date filter preset
    @Published var dateFilter: DateFilterPreset = .all

    /// Grouped and filtered timeline sections
    @Published private(set) var sections: [TimelineSection] = []

    /// Total count of filtered results
    @Published private(set) var filteredCount: Int = 0

    /// Whether the timeline is empty (no results at all)
    @Published private(set) var isEmpty: Bool = true

    /// Whether filters are active (not showing all results)
    var hasActiveFilters: Bool {
        selectedCategories.count < DetectionCategory.allCases.count ||
        !searchQuery.isEmpty ||
        dateFilter != .all
    }

    // MARK: - Dependencies

    private let resultsManager: DetectionResultsManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Caching

    private var cachedMergedResults: [TimelineResult] = []
    private var lastResultsHash: Int = 0

    // MARK: - Initialization

    init(resultsManager: DetectionResultsManager? = nil) {
        // Use provided manager or resolve from DI container
        if let manager = resultsManager {
            self.resultsManager = manager
        } else {
            self.resultsManager = DIContainer.shared.resolve(DetectionResultsManager.self)
        }

        setupBindings()
    }

    // MARK: - Setup

    private func setupBindings() {
        // Observe changes to results manager arrays using Merge
        // (we don't need the values, just notification of changes)
        Publishers.Merge5(
            resultsManager.$ocrResults.map { _ in () },
            resultsManager.$objectDetectionResults.map { _ in () },
            resultsManager.$classificationResults.map { _ in () },
            resultsManager.$contourResults.map { _ in () },
            resultsManager.$barcodeResults.map { _ in () }
        )
        .sink { [weak self] _ in
            self?.invalidateCache()
            self?.updateSections()
        }
        .store(in: &cancellables)

        // Observe filter changes with debounce for search
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateSections()
            }
            .store(in: &cancellables)

        // Immediate update for category and date filter changes
        $selectedCategories
            .dropFirst() // Skip initial value
            .sink { [weak self] _ in
                self?.updateSections()
            }
            .store(in: &cancellables)

        $dateFilter
            .dropFirst() // Skip initial value
            .sink { [weak self] _ in
                self?.updateSections()
            }
            .store(in: &cancellables)

        // Initial load
        updateSections()
    }

    // MARK: - Public Actions

    /// Toggle a category filter on/off
    func toggleCategory(_ category: DetectionCategory) {
        if selectedCategories.contains(category) {
            // Don't allow deselecting all categories
            if selectedCategories.count > 1 {
                selectedCategories.remove(category)
            }
        } else {
            selectedCategories.insert(category)
        }
    }

    /// Select all categories
    func selectAllCategories() {
        selectedCategories = Set(DetectionCategory.allCases)
    }

    /// Clear all filters and reset to defaults
    func clearFilters() {
        selectedCategories = Set(DetectionCategory.allCases)
        searchQuery = ""
        dateFilter = .all
    }

    /// Get the count of results for a specific category
    func countForCategory(_ category: DetectionCategory) -> Int {
        cachedMergedResults.filter { $0.category == category }.count
    }

    // MARK: - Private Methods

    private func invalidateCache() {
        lastResultsHash = 0
    }

    private func mergeAllResults() -> [TimelineResult] {
        // Check if cache is still valid
        let currentHash = computeResultsHash()
        if currentHash == lastResultsHash && !cachedMergedResults.isEmpty {
            return cachedMergedResults
        }

        // Merge all result arrays into TimelineResult wrappers
        var results: [TimelineResult] = []

        results.append(contentsOf: resultsManager.ocrResults.map { .ocr($0) })
        results.append(contentsOf: resultsManager.objectDetectionResults.map { .objectDetection($0) })
        results.append(contentsOf: resultsManager.classificationResults.map { .classification($0) })
        results.append(contentsOf: resultsManager.contourResults.map { .contour($0) })
        results.append(contentsOf: resultsManager.barcodeResults.map { .barcode($0) })

        // Sort by timestamp (newest first)
        results.sort { $0.timestamp > $1.timestamp }

        // Update cache
        cachedMergedResults = results
        lastResultsHash = currentHash

        return results
    }

    private func computeResultsHash() -> Int {
        var hasher = Hasher()
        // Hash actual result IDs, not just counts, to detect content changes
        for id in resultsManager.ocrResults.map({ $0.id }) {
            hasher.combine(id)
        }
        for id in resultsManager.objectDetectionResults.map({ $0.id }) {
            hasher.combine(id)
        }
        for id in resultsManager.classificationResults.map({ $0.id }) {
            hasher.combine(id)
        }
        for id in resultsManager.contourResults.map({ $0.id }) {
            hasher.combine(id)
        }
        for id in resultsManager.barcodeResults.map({ $0.id }) {
            hasher.combine(id)
        }
        return hasher.finalize()
    }

    private func updateSections() {
        let allResults = mergeAllResults()

        // Update empty state
        isEmpty = allResults.isEmpty

        // Apply filters
        let filtered = allResults
            .filter { selectedCategories.contains($0.category) }
            .filter { $0.matchesSearch(searchQuery) }
            .filter { dateFilter.includes($0.timestamp) }

        // Update filtered count
        filteredCount = filtered.count

        // Group by timeline group
        let grouped = Dictionary(grouping: filtered) { $0.group() }

        // Convert to sections, sorted by group order
        sections = TimelineGroup.allCases
            .compactMap { group -> TimelineSection? in
                guard let results = grouped[group], !results.isEmpty else {
                    return nil
                }
                return TimelineSection(group: group, results: results)
            }
    }
}
