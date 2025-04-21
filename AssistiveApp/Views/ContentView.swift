//
//  ContentView.swift
//  AssistiveApp
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
            ARScannerTabView()
                .tabItem { Label("Scan", systemImage: "qrcode.viewfinder") }
            MenuListView()
                .tabItem { Label("Menu", systemImage: "menucard") }
            OrderView()
                .tabItem { Label("Order", systemImage: "cart") }
            ProfileView(profile:MobilityProfile())
                .tabItem { Label("Profile View", systemImage: "gearshape") }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [MenuItem.self, Order.self, Location.self], inMemory: true)
}
