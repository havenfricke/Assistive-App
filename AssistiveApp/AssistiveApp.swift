//
//  AssistiveApp.swift
//  AssistiveApp

import SwiftUI
import SwiftData

@main
struct AssistiveApp: App {
    // ** NEW **
    @StateObject private var orderManager = OrderManager()
    
    var sharedContainer: ModelContainer = {
        let schema = Schema([
            Order.self,
            Location.self,
            Customer.self,
            LocationTag.self
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
            ContentView()
            // ** NEW **
                .environmentObject(orderManager)
        }
        .modelContainer(sharedContainer)
        
    }
}
