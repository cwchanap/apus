//
//  TimelineRowView.swift
//  apus
//
//  Created by Claude Code on 5/1/2026.
//

import SwiftUI

// MARK: - Timeline Row View

/// Rich row view for displaying a timeline result
/// Shows: thumbnail, category badge, preview text, stats, and relative time
struct TimelineRowView: View {
    let result: TimelineResult

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            thumbnailView

            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Category badge
                categoryBadge

                // Preview text
                Text(result.previewText)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundColor(.primary)

                // Stats and time
                HStack {
                    Text(result.statsText)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(result.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Chevron indicator
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Thumbnail View

    @ViewBuilder
    private var thumbnailView: some View {
        if let thumbnail = result.thumbnailImage {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            // Placeholder when no thumbnail
            RoundedRectangle(cornerRadius: 8)
                .fill(result.category.color.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: result.category.icon)
                        .font(.title2)
                        .foregroundColor(result.category.color)
                )
        }
    }

    // MARK: - Category Badge

    private var categoryBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: result.category.icon)
                .font(.caption2)

            Text(result.category.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(result.category.color)
        .clipShape(Capsule())
    }
}

// MARK: - Timeline Section Header

/// Sticky section header for timeline groups
struct TimelineSectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Empty Timeline View

/// Empty state view when no results match filters
struct EmptyTimelineView: View {
    let hasFilters: Bool
    let onClearFilters: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: hasFilters ? "magnifyingglass" : "clock")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            VStack(spacing: 8) {
                Text(hasFilters ? "No Results Found" : "No Detection History")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(hasFilters
                    ? "Try adjusting your filters or search query"
                    : "Start detecting objects, text, or barcodes to build your timeline")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if hasFilters {
                Button {
                    onClearFilters()
                } label: {
                    Text("Clear Filters")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Previews

#if DEBUG
struct TimelineRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            EmptyTimelineView(hasFilters: false) {}
        }
        .background(Color(.systemGroupedBackground))
    }
}
#endif
