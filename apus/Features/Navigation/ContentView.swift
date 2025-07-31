//
//  ContentView.swift
//  apus
//
//  Created by Chan Wai Chan on 27/6/2025.
//

import SwiftUI
import SwiftData

enum NavigationPage {
    case home
    case settings
    case history
}

struct ContentView: View {
    @State private var currentPage: NavigationPage = .home
    
    var body: some View {
        ZStack {
            // Main content based on current page
            switch currentPage {
            case .home:
                HomeView()
                    .ignoresSafeArea(.all) // Allow home view (camera) to go full screen
            case .settings:
                NavigationStack {
                    SettingsView()
                        .navigationTitle("Settings")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Back to Camera") {
                                    currentPage = .home
                                }
                            }
                        }
                }
            case .history:
                NavigationStack {
                    ClassificationHistoryView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Back to Camera") {
                                    currentPage = .home
                                }
                            }
                        }
                }
            }
            
            // Floating menu buttons for camera view
            if currentPage == .home {
                VStack {
                    HStack {
                        VStack(spacing: 12) {
                            Button(action: {
                                currentPage = .settings
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                currentPage = .history
                            }) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.leading, 20)
                        .padding(.top, 50) // Account for status bar
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

struct HomeView: View {
    var body: some View {
        CameraView()
            .ignoresSafeArea(.all) // Ensure camera view goes full screen
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
