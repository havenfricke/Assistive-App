import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var selectedItem: PhotosPickerItem? = nil
    @Bindable var profile:MobilityProfile
    var body: some View {
        Form {
            // MARK: - Identity
            Section(header: Text("Profile")) {
                TextField("Name", text: $profile.name)

                if let imageData = profile.profileImage,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Text("No profile image selected")
                        .foregroundColor(.gray)
                }

                PhotosPicker("Select Profile Image", selection: $selectedItem, matching: .images)
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                profile.profileImage = data
                            }
                        }
                    }
            }

            // MARK: - Mobility Settings
            Section(header: Text("Mobility Settings")) {
                Toggle("Wheelchair User", isOn: $profile.wheelchairUser)

                VStack(alignment: .leading) {
                    Text("Max Travel Distance: \(Int(profile.maxTravelDistanceMeters)) meters")
                    Slider(value: $profile.maxTravelDistanceMeters, in: 5...50, step: 5)
                }

                Picker("Reach Level", selection: $profile.reachLevel) {
                    ForEach(ReachLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }

                Toggle("Requires Assistance", isOn: $profile.requiresAssistance)
            }

            // MARK: - Allergens
            Section(header: Text("Allergens")) {
                NavigationLink("Edit Allergen List") {
                    AllergenPickerView(selectedAllergens: $profile.allergens)
                }
            }

            // MARK: - Notes
            Section(header: Text("Additional Notes")) {
                TextEditor(text: Binding(
                    get: { profile.notes ?? "" },
                    set: { profile.notes = $0 }
                ))
                .frame(height: 100)
            }

            // MARK: - Save + Reset
            Section {
                Button("Save and Return") {
                    profile.lastUpdated = Date()
                    do{
                        try context.save()
                    } catch {
                        print("Failed to save Mobilit Profile: \(error)")
                    }
                    dismiss()
                }

                Button("Reset to Defaults", role: .destructive) {
                    resetProfile()
                }
            }
        }
        .onAppear{
            print("editing profile:" , profile.name)
        }
        .navigationTitle("Edit Profile")
    }
        

    // MARK: - Helper
    func resetProfile() {
        profile.wheelchairUser = false
        profile.maxTravelDistanceMeters = 15.0
        profile.reachLevel = .moderate
        profile.requiresAssistance = false
        profile.allergens = []
        profile.notes = nil
        profile.lastUpdated = Date()
    }
}
