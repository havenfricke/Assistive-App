//
//
//  ProfileView.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 4/19/25.
//

import SwiftUI

struct ProfileView: View {
    @Bindable var profile: MobilityProfile
    @State private var isEditingProfile = false
    
    var body: some View {
        NavigationStack{
            Form{
                // MARK: - Identity
                
                Section(header: Text("Profile")){
                    Text("Name: \(profile.name)")
                    
                    if let imageData = profile.profileImage,
                       let image = UIImage(data: imageData)
                    {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height:100)
                            .clipShape(Circle())
                    } else {
                        Text("No profile image available")
                            .foregroundColor(.gray)
                    }
                }
                // MARK: - Edit Action
                Section {
                    Button("Edit Profile") {
                        isEditingProfile = true
                    }
                    .sheet(isPresented: $isEditingProfile) {
                        NavigationStack {
                            EditProfileView(profile: profile)
                        }
                    }
                }

                
                // MARK: - Mobility Info
                Section(header: Text ("Mobility Info")){
                    HStack{
                        Text("Wheelchair User:")
                        Text(profile.wheelchairUser ? "Yes" : "No")

                    }
                    HStack {
                        Text("Max Travel Distance:")
                        Text("\(Int(profile.maxTravelDistanceMeters)) meters")
                    }
                    
                    HStack {
                        Text("Reach Distance:")
                        Text(profile.reachLevel.rawValue)
                    }
                    
                    HStack {
                        Text("Requires Assistance:")
                        Text(profile.requiresAssistance ? "Yes" : "No")
                    }
                }
                // MARK: - Allergens
                Section(header: Text("Allergens")) {
                    if profile.allergens.isEmpty {
                        Text("None")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(profile.allergens, id: \.self) { allergen in
                            Text(allergen)
                        }
                    }
                }
                
                // MARK: - Notes
                if let notes = profile.notes, !notes.isEmpty {
                    Section(header: Text("Notes")) {
                        Text(notes)
                    }
                }
                
                // MARK: - Last Updated
                Section {
                    Text("Last Updated: \(formattedDate(profile.lastUpdated))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                // MARK: = Send User Profile
                Button ("Send Profile to Staff"){
                    sendProfileToStaff()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8.0)
                
            }
            .navigationTitle("Your Profile")
        }
    }
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    private func sendProfileToStaff() {
        do{
            let payload = try Payload(type:.mobilityProfile,model: profile)
            PeerConnectionManager.shared.send(payload: payload)
            print("Sent User Mobility Profile")
        } catch{
            print("failed to send Mobility Profile: \(error)")
        }
    }
    
}
