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
}

struct ContentView: View {
    @State private var currentPage: NavigationPage = .home
    
    var body: some View {
        NavigationView {
            VStack {
                // Main content based on current page
                switch currentPage {
                case .home:
                    HomeView()
                case .settings:
                    SettingsView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Home") {
                            currentPage = .home
                        }
                        Button("Settings") {
                            currentPage = .settings
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3")
                    }
                }
            }
            .navigationTitle(currentPage == .home ? "Home" : "Settings")
        }
    }
}

struct HomeView: View {
    var body: some View {
        CameraView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
