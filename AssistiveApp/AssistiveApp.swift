//
//  AssistiveApp.swift
//  AssistiveApp

import SwiftUI
import SwiftData

@main
struct AssistiveApp: App {
    // Create a shared model container with our registered models.
    var sharedContainer: ModelContainer = {
        let schema = Schema([
            MenuItem.self,
            Order.self,
            Location.self
        ])
        let modelConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfig])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            AppRouterView()
        }
        .modelContainer(sharedContainer)
    }
}
