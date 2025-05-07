//
//  ContentView.swift
//  AssistiveApp
//

import SwiftUI

struct ContentView: View {
    @StateObject private var connectionManager = UserConnectionManager()
    @StateObject private var navStore = NavigationAssetStore.shared
    @EnvironmentObject private var orderManager:OrderManager
    @Bindable var profile : MobilityProfile
    
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
            ARScannerTabView(profile:profile)
                .tabItem { Label("Scan", systemImage: "qrcode.viewfinder") }
            MenuListView(profile:profile)
                .tabItem { Label("Menu", systemImage: "menucard") }
            OrderView(profile:profile)
                .tabItem { Label("Order", systemImage: "cart") }
            ProfileView(profile:profile)
                .tabItem { Label("Profile View", systemImage: "gearshape") }
            NavView().tabItem { Label("Navigation", systemImage: "map") }
        }
    }
}



@MainActor
class UserConnectionManager: ObservableObject {
    init(){
        print("Peer Connection Started in user mode.")
        PeerConnectionManager.shared.isStaffMode = false
        PayloadRouter.shared.onReceivedNavigationData = { payload in
            print("📦 Received NavigationDataPayload with \(payload.assets.count) assets")
            
            if payload.assets.isEmpty {
                print("⚠️ No navigation assets received.")
            } else {
                let grouped = Dictionary(grouping: payload.assets, by: \.category)
                for (category, items) in grouped {
                    print("📁 \(category.displayName): \(items.count) asset(s)")
                }
                let sampleNames = payload.assets.prefix(5).map(\.name)
                print("📝 Sample: \(sampleNames.joined(separator: ", "))")
            }
            
            Task { @MainActor in
                NavigationAssetStore.shared.updatedAssets(payload.assets)
                NavigationAssetStore.shared.setFloorPlan(from: payload.floorPlanData)
                print("✅ NavigationAssetStore updated.")
            }
        }
    }
    
    #Preview {
        ContentView(profile:MobilityProfile())
    }
}
