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
            NavView()
                .tabItem { Label("Nav", systemImage: "arrowshape.turn.up.right") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [MenuItem.self, Order.self, Location.self], inMemory: true)
}
