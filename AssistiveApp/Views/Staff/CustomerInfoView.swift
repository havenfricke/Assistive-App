import SwiftUI
import SwiftData

struct CustomerInfoView: View {
    let receivedProfile: MobilityProfile?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                if let profile = receivedProfile {
                    // Photo
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    
                    // Name
                    Text(profile.name)
                        .font(.title2)
                        .bold()
                    
                    // Mobility Preferences
                    Section(header: Text("Mobility Preferences").font(.headline)){
                        Text("Wheelchair User: \(profile.wheelchairUser ? "Yes" : "No")")
                        Text("Max Distance: \(profile.maxTravelDistanceMeters) meters")
                    }
                    
                    // Allergens
                    Section(header: Text("Allergen Flags").font(.headline)) {
                        if !profile.allergens.isEmpty {
                            ForEach(profile.allergens, id: \.self) { allergen in
                                Text("- \(allergen)")
                                    .foregroundColor(.red)
                            }
                        } else {
                            Text("No allergens specified.")
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    Text("No customer selected.")
                        .foregroundColor(.gray)
                }
                Spacer()
                // MARK: - Simulate Profile Button
                Button("Simulate Incoming Profile") {
                    simulateIncomingProfile()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .navigationTitle("Customer Info")
        }
    }
     func simulateIncomingProfile() {
        let simulatedProfile = MobilityProfile(
                    name: "Simulated User",
                    wheelchairUser: true,
                    maxTravelDistanceMeters: 25.0,
                    reachLevel: .moderate,
                    requiresAssistance: false,
                    allergens: ["Gluten", "Peanuts"],
                    notes: "Testing profile",
                    lastUpdated: Date()
                )
                do {
                    let payload = try Payload(type: .mobilityProfile, model: simulatedProfile)
                    PayloadRouter.shared.handle(payload: payload)
                } catch {
                    print("Failed to simulate incoming profile payload: \(error)")
                }
    }
}

@Model
final class Customer {
    var id: UUID
    var name: String
    var profileImage: Data?
    var wheelchairUser: Bool
    var maxTravelDistanceMeters: Double
    var reachLevel: ReachLevel
    var requiresAssistance: Bool
    var allergens: [String]
    var notes: String?
    var lastUpdated: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        profileImage: Data? = nil,
        wheelchairUser: Bool = false,
        maxTravelDistanceMeters: Double = 15.0,
        reachLevel: ReachLevel = .moderate,
        requiresAssistance: Bool = false,
        allergens: [String] = [],
        notes: String? = nil,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.profileImage = profileImage
        self.wheelchairUser = wheelchairUser
        self.maxTravelDistanceMeters = maxTravelDistanceMeters
        self.reachLevel = reachLevel
        self.requiresAssistance = requiresAssistance
        self.allergens = allergens
        self.notes = notes
        self.lastUpdated = lastUpdated
    }
}
extension Customer{
    static func fromMobilityProfile(_ profile: MobilityProfile) -> Customer {
        return Customer(
            id: profile.id,
            name: profile.name,
            profileImage: profile.profileImage,
            wheelchairUser: profile.wheelchairUser,
            maxTravelDistanceMeters: profile.maxTravelDistanceMeters,
            reachLevel: profile.reachLevel,
            requiresAssistance: profile.requiresAssistance,
            allergens: profile.allergens,
            notes: profile.notes,
            lastUpdated: profile.lastUpdated
        )
    }
}
