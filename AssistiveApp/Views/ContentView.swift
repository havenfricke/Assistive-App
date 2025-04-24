//
//  ContentView.swift
//  AssistiveApp
//

import SwiftUI

struct ContentView: View {
    let profile: MobilityProfile
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
            ARScannerTabView(profile:profile)
                .tabItem { Label("Scan", systemImage: "qrcode.viewfinder") }
            MenuListView(viewModel: MenuViewModel())
                .tabItem { Label("Menu", systemImage: "menucard") }
            OrderView()
                .tabItem { Label("Order", systemImage: "cart") }
            ProfileView(profile:profile)
                .tabItem { Label("Profile View", systemImage: "gearshape") }
        }
    }
}

