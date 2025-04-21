//
//  SettingsView.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//

import SwiftUI
import PhotosUI

struct UserSettingsView: View {
    @Bindable var profile: MobilityProfile
    @State private var showAllergenPicker = false
    @State private var showPreview = false
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        NavigationStack{
            Form{
                // MARK: - Profile Preview
                Section {
                    NavigationLink("Preview Shared Profile"){
                        //MobiltyProfilePreviewView(profile : profile)
                    }
                }
                //MARK: - Profile Identity
                Section(header: Text("Profile")){
                    TextField("Name", text: $profile.name)
                    
                    if let imageData = profile.profileImage,
                       let uiImage=UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height:100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else{
                        Text("No Profile Image selected")
                            .foregroundColor(.gray)
                    }
                    
                    PhotosPicker("Select Profile Image", selection: $selectedItem, matching: .images)
                        .onChange(of:selectedItem){ newItem in
                            Task{
                                if let data = try? await newItem?.loadTransferable(type: Data.self){
                                    profile.profileImage = data
                                }
                            }}
                    
                }
                // MARK: - Mobility Settings
                Section(header: Text("Mobility Settings")){
                    Toggle("Wheelchair User", isOn: $profile.wheelchairUser)
                    
                    VStack(alignment: .leading){
                        Text("Max Travel Distance: \(Int(profile.maxTravelDistanceMeters)) meters")
                        Slider(value: $profile.maxTravelDistanceMeters, in: 5...50, step:5)
                    }
                    Picker("Reach Level", selection: $profile.reachLevel){
                        ForEach(ReachLevel.allCases, id: \.self){ level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    Toggle("Requires Assistance", isOn: $profile.requiresAssistance)
                }
                
                // MARK: - Allergen Settings
                Section(header:Text("Allergens")){
                    NavigationLink("Edit Allergen List"){
                        //AllergenPickerVIew(selectedAllergens: $profile.allergens)
                    }
                }
                
                // MARK: - Notes
                Section(header: Text("Additional Notes")){
                    TextEditor(text:Binding(
                        get: { profile.notes ?? "" },
                        set: {profile.notes = $0}
                    ))
                    .frame(height:100)
                }
                
                // MARK: - Last Updated
                Section{
                    Text("Last Updated: \(formattedDate(profile.lastUpdated))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
                // MARK: - Actions
                Section{
                    Button("Save Update and Share"){
                        profile.lastUpdated = Date()
                        // trigger sharing logic
                    }
                    
                    Button("Reset to Defaults", role: .destructive){
                        resetProfile()
                    }
                }
            }
            .navigationTitle(Text("User Settings"))
        }
    }
        // MARK: - Helpers
        func resetProfile(){
            profile.wheelchairUser = false
            profile.maxTravelDistanceMeters = 10.0
            profile.reachLevel = .moderate
            profile.requiresAssistance = false
            profile.allergens = []
            profile.notes = nil
            profile.lastUpdated = Date()
        }
        
        func formattedDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
