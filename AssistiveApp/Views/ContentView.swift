//
//  ContentView.swift
//  AssistiveApp
//

import SwiftUI

struct ContentView: View {
    @StateObject private var connectionManager = UserConnectionManager()
    @StateObject private var navStore = NavigationAssetStore()
    let profile: MobilityProfile
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
            ARScannerTabView(profile:profile)
                .tabItem { Label("Scan", systemImage: "qrcode.viewfinder") }
            MenuListView()
                .tabItem { Label("Menu", systemImage: "menucard") }
            OrderView()
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
    }
}

#Preview {
    ContentView(profile:MobilityProfile())
}
