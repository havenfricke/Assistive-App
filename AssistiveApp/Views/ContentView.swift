//
//  ContentView.swift
//  AssistiveApp
//

import SwiftUI

struct ContentView: View {
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
            NavView(profile:profile).tabItem { Label("Navigation", systemImage: "map") }
        }
    }
}




    
#Preview {
    ContentView(profile:MobilityProfile())
}
