//
//  SettingsView.swift
//  apus
//
//  Created by Chan Wai Chan on 29/6/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var isViewLoaded = false

    var body: some View {
        NavigationView {
            Group {
                if isViewLoaded {
                    settingsContent
                } else {
                    loadingView
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if !isViewLoaded {
                    // Small delay to show loading state, then show content
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isViewLoaded = true
                    }
                }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading Settings...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var settingsContent: some View {
        List {
            // Object Detection Settings Section
            Section("Object Detection") {
                // Enable/Disable Toggle
                HStack {
                    Image(systemName: "viewfinder")
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Real-Time Detection")
                            .font(.body)
                        Text("Enable live object detection in camera view")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Toggle("", isOn: $viewModel.isRealTimeObjectDetectionEnabled)
                        .labelsHidden()
                }
                .padding(.vertical, 4)

                // Barcode Detection Toggle
                HStack {
                    Image(systemName: "barcode.viewfinder")
                        .foregroundColor(.red)
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Real-Time Barcode Detection")
                            .font(.body)
                        Text("Enable live barcode and QR code detection")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Toggle("", isOn: $viewModel.isRealTimeBarcodeDetectionEnabled)
                        .labelsHidden()
                }
                .padding(.vertical, 4)

                // Framework Selection (always visible)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "gearshape.2")
                            .foregroundColor(.purple)
                            .frame(width: 24, height: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Detection Framework")
                                .font(.body)
                            Text("Choose the ML framework for object detection")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }

                    // Framework Options
                    VStack(spacing: 8) {
                        ForEach(ObjectDetectionFramework.allCases, id: \.self) { framework in
                            Button(action: {
                                viewModel.objectDetectionFramework = framework
                            }) {
                                HStack {
                                    Image(systemName: framework.icon)
                                        .foregroundColor(viewModel.objectDetectionFramework == framework ? .white : .primary)
                                        .frame(width: 20, height: 20)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(framework.displayName)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(viewModel.objectDetectionFramework == framework ? .white : .primary)

                                        Text(framework.description)
                                            .font(.caption)
                                            .foregroundColor(viewModel.objectDetectionFramework == framework ? .white.opacity(0.8) : .secondary)
                                    }

                                    Spacer()

                                    if viewModel.objectDetectionFramework == framework {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(viewModel.objectDetectionFramework == framework ?
                                                Color.accentColor : Color.clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(viewModel.objectDetectionFramework == framework ?
                                                    Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.vertical, 4)

                // Model Selection (Core ML only)
                if viewModel.objectDetectionFramework == .coreML {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "square.stack.3d.up")
                                .foregroundColor(.teal)
                                .frame(width: 24, height: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Detection Model")
                                    .font(.body)
                                Text("Choose the Core ML model for detection")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }

                        VStack(spacing: 8) {
                            ForEach(ObjectDetectionModel.allCases, id: \.self) { model in
                                Button(action: {
                                    viewModel.objectDetectionModel = model
                                }) {
                                    HStack {
                                        Image(systemName: model.icon)
                                            .foregroundColor(viewModel.objectDetectionModel == model ? .white : .primary)
                                            .frame(width: 20, height: 20)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(model.displayName)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(viewModel.objectDetectionModel == model ? .white : .primary)
                                            Text(model.description)
                                                .font(.caption)
                                                .foregroundColor(viewModel.objectDetectionModel == model ? .white.opacity(0.8) : .secondary)
                                        }

                                        Spacer()

                                        if viewModel.objectDetectionModel == model {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(viewModel.objectDetectionModel == model ? Color.accentColor : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(viewModel.objectDetectionModel == model ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            // Storage Limits Section
            Section("Result Storage") {
                NavigationLink(destination: StorageLimitsSettingsView()) {
                    HStack {
                        Image(systemName: "externaldrive")
                            .foregroundColor(.purple)
                            .frame(width: 24, height: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Storage Limits")
                                .font(.body)
                            Text("Configure result storage limits per category")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }

            // App Information Section
            Section("About") {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                        .frame(width: 24, height: 24)

                    Text("Version")

                    Spacer()

                    Text(viewModel.getAppVersion())
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)

                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.orange)
                        .frame(width: 24, height: 24)

                    Button("Reset to Defaults") {
                        viewModel.resetToDefaults()
                    }

                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }
}

#Preview {
    SettingsView()
}
