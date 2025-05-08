//
//  AssistiveApp.swift
//  AssistiveApp

import SwiftUI
import SwiftData

@main
struct AssistiveApp: App {
    @StateObject private var navAssetStore = NavigationAssetStore()
    @StateObject private var orderManager = OrderManager()
    @StateObject private var locationDataManager = LocationDataManager()
    var sharedContainer: ModelContainer = {
        let schema = Schema([
            Order.self,
            Location.self,
            NavModel.self,
            MobilityProfile.self,
            AccessPoint.self
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
                .environmentObject(NavigationAssetStore.shared)
                .environmentObject(orderManager)
                .environmentObject(locationDataManager)
        }
        .modelContainer(sharedContainer)
    }
}
