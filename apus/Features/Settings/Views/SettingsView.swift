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
                // Camera Settings Section
                Section("Camera") {
                    HStack {
                        Image(systemName: "viewfinder")
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Object Detection")
                                .font(.body)
                            Text("Detect and highlight objects in camera view")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.isObjectDetectionEnabled)
                            .labelsHidden()
                    }
                    .padding(.vertical, 4)
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
