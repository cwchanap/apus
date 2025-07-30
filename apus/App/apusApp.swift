//
//  apusApp.swift
//  apus
//
//  Created by Chan Wai Chan on 27/6/2025.
//

import SwiftUI
import SwiftData

@main
struct apusApp: App {
    @StateObject private var appDependencies = AppDependencies.shared
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
        }
        .modelContainer(sharedModelContainer)
    }
}
