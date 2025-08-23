//
//  StorageLimitsSettingsView.swift
//  apus
//
//  Created by Claude Code on 21/8/2025.
//

import SwiftUI

struct StorageLimitsSettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("Configure how many detection results to keep for each category. Results are automatically cleaned up when the limit is exceeded.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                }

                Section("Detection Categories") {
                    ForEach(DetectionCategory.allCases, id: \.self) { category in
                        StorageLimitRowView(category: category, viewModel: viewModel)
                    }
                }

                Section("Actions") {
                    Button("Reset All to Default (10)") {
                        resetAllToDefault()
                    }
                    .foregroundColor(.orange)
                }

            }
            .navigationTitle("Storage Limits")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func resetAllToDefault() {
        for category in DetectionCategory.allCases {
            viewModel.setStorageLimit(for: category, limit: 10)
        }
    }
}

/// Enhanced row view for configuring storage limits per detection category
struct StorageLimitRowView: View {
    let category: DetectionCategory
    @ObservedObject var viewModel: SettingsViewModel
    @State private var inputValue: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Category Icon and Info
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .foregroundColor(category.color)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(category.color.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.rawValue)
                        .font(.body)
                        .fontWeight(.medium)
                    Text("Max results to store")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Controls
            HStack(spacing: 8) {
                // Decrease button
                Button(action: {
                    let currentValue = viewModel.getStorageLimit(for: category)
                    let newValue = max(1, currentValue - 1)
                    viewModel.setStorageLimit(for: category, limit: newValue)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(viewModel.getStorageLimit(for: category) <= 1 ? .gray : .red)
                        .font(.system(size: 20))
                }
                .disabled(viewModel.getStorageLimit(for: category) <= 1)
                .buttonStyle(PlainButtonStyle())

                // Value display/input
                TextField("", text: $inputValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 60)
                    .multilineTextAlignment(.center)
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        if let value = Int(inputValue), value >= 1, value <= 100 {
                            viewModel.setStorageLimit(for: category, limit: value)
                        }
                        updateInputValue()
                        isTextFieldFocused = false
                    }
                    .onChange(of: viewModel.getStorageLimit(for: category)) { _, _ in
                        if !isTextFieldFocused {
                            updateInputValue()
                        }
                    }

                // Increase button
                Button(action: {
                    let currentValue = viewModel.getStorageLimit(for: category)
                    let newValue = min(100, currentValue + 1)
                    viewModel.setStorageLimit(for: category, limit: newValue)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(viewModel.getStorageLimit(for: category) >= 100 ? .gray : .green)
                        .font(.system(size: 20))
                }
                .disabled(viewModel.getStorageLimit(for: category) >= 100)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 6)
        .onAppear {
            updateInputValue()
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside text field
            if isTextFieldFocused {
                isTextFieldFocused = false
            }
        }
    }

    private func updateInputValue() {
        inputValue = String(viewModel.getStorageLimit(for: category))
    }
}

#Preview {
    StorageLimitsSettingsView()
}
