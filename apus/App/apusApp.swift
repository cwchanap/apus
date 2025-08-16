//
//  apusApp.swift
//  apus
//
//  Created by Chan Wai Chan on 27/6/2025.
//

import SwiftUI
import SwiftData

@main
struct ApusApp: App {
    @StateObject private var appDependencies = AppDependencies.shared
    @StateObject private var resultsManager: DetectionResultsManager

    init() {
        // Ensure dependencies are configured at app startup
        // Initialize DI and kick off background preloading
        _ = AppDependencies.shared.diContainer
        print("✅ App dependencies initialized at startup")

        // Resolve singleton DetectionResultsManager for EnvironmentObject
        _resultsManager = StateObject(wrappedValue: DIContainer.shared.resolve(DetectionResultsManager.self))
    }
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark) // Force dark mode for camera app
                .statusBarHidden(true) // Hide status bar
                .environmentObject(resultsManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
