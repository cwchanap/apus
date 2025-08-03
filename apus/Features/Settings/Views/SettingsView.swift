//
//  SettingsView.swift
//  apus
//
//  Created by Chan Wai Chan on 29/6/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                // Object Detection Settings Section
                Section("Object Detection") {
                    // Enable/Disable Toggle
                    HStack {
                        Image(systemName: "viewfinder")
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Enable Object Detection")
                                .font(.body)
                            Text("Detect and highlight objects in images")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.isObjectDetectionEnabled)
                            .labelsHidden()
                    }
                    .padding(.vertical, 4)
                    
                    // Framework Selection (only shown when enabled)
                    if viewModel.isObjectDetectionEnabled {
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
                        .transition(.opacity.combined(with: .slide))
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
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsView()
}
