//
//  ContentView.swift
//  AssistiveApp
//

import SwiftUI

struct ContentView: View {
    @StateObject private var connectionManager = UserConnectionManager()
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
            NavView().tabItem { Label("Navigation", systemImage: "map") }
        }
    }
}

#Preview {
    ContentView(profile: MobilityProfile())
}

@MainActor
class UserConnectionManager: ObservableObject {
    init(){
        print("Peer Connection Started in user mode.")
        PeerConnectionManager.shared.isStaffMode = false
    }
}
