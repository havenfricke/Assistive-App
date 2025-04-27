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
                
                Button("Configure Peer Connection"){
                    configurePeerConnection()
                }
                Button("Simulate Send Profile"){
                    simulateSendingProfile()
                }
            }
            .padding()
            .navigationTitle("Home")
        }
    }
    
    private func configurePeerConnection(){
        let peerManager = PeerConnectionManager.shared
        peerManager.isStaffMode = false
        peerManager.start()
        
    }
    private func simulateSendingProfile(){
        let dummyProfile = MobilityProfile(
                    name: "Simulated User",
                    wheelchairUser: false,
                    maxTravelDistanceMeters: 20.0,
                    reachLevel: .moderate,
                    requiresAssistance: false,
                    allergens: ["Peanuts"],
                    notes: "Testing auto-connection",
                    lastUpdated: Date()
                )

                do {
                    _ = try Payload(type: .mobilityProfile, model: dummyProfile)
                    print("✅ Simulated MobilityProfile sent.")
                } catch {
                    print("❌ Failed to simulate sending profile: \(error)")
                }
    }
}
#Preview {
    HomeView()
}
