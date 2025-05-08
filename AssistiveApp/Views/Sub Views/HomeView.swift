//
//  HomeView.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//


import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to Assistive")
                    .font(.largeTitle)
                    .bold()
                Text("Navigate, scan & order with ease.")
                    .foregroundColor(.secondary)
                
                Button("Simulate Connection"){
                    //ChickFilA
                    //connectToLocation(_ : "aacfa")
                    
                    //cafe32
                    connectToLocation(_ : "aac32")
                    
                    PayloadRouter.shared.onReceivedNavigationData = { payload in
                        Task { @MainActor in
                            NavigationAssetStore.shared.updatedAssets(payload.assets)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Home")
        }
        
    }
}

func connectToLocation(_ netID: String){
    PeerConnectionManager.shared.serviceType = netID
    print("Establishing connection: \(netID)")
    PeerConnectionManager.shared.isStaffMode = false
    PeerConnectionManager.shared.start()
}
