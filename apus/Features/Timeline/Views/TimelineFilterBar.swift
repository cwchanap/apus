//
//  TimelineFilterBar.swift
//  apus
//
//  Created by Claude Code on 5/1/2026.
//

import SwiftUI

// MARK: - Timeline Filter Bar

/// Filter bar with search, category chips, and date presets
struct TimelineFilterBar: View {
    @ObservedObject var viewModel: TimelineViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Search bar
            TimelineSearchBar(searchQuery: $viewModel.searchQuery)

            // Category filter chips
            TimelineCategoryFilters(viewModel: viewModel)

            // Date range presets
            TimelineDatePresets(selectedPreset: $viewModel.dateFilter)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

// MARK: - Search Bar

struct TimelineSearchBar: View {
    @Binding var searchQuery: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search text and objects...", text: $searchQuery)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()

            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Category Filters

struct TimelineCategoryFilters: View {
    @ObservedObject var viewModel: TimelineViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DetectionCategory.allCases, id: \.rawValue) { category in
                    CategoryFilterChip(
                        category: category,
                        isSelected: viewModel.selectedCategories.contains(category),
                        count: viewModel.countForCategory(category)
                    ) {
                        viewModel.toggleCategory(category)
                    }
                }
            }
        }
    }
}

// MARK: - Category Filter Chip

struct CategoryFilterChip: View {
    let category: DetectionCategory
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)

                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)

                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            isSelected
                                ? Color.white.opacity(0.3)
                                : Color.gray.opacity(0.3)
                        )
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? category.color : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Date Presets

struct TimelineDatePresets: View {
    @Binding var selectedPreset: DateFilterPreset

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DateFilterPreset.allCases, id: \.rawValue) { preset in
                    DatePresetChip(
                        preset: preset,
                        isSelected: selectedPreset == preset
                    ) {
                        selectedPreset = preset
                    }
                }
            }
        }
    }
}

// MARK: - Date Preset Chip

struct DatePresetChip: View {
    let preset: DateFilterPreset
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(preset.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#if DEBUG
struct TimelineFilterBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TimelineFilterBar(viewModel: TimelineViewModel())
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }
}
#endif
