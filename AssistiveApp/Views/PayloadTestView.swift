import SwiftUI

struct PayloadTestView: View {
    @State private var logMessages: [String] = []

    var body: some View {
        VStack(spacing: 12) {
            Text("Payload Test")
                .font(.title)
                .bold()

            Group {
                Button("Send Test MobilityProfile", action: simulateMobilityProfile)
                Button("Send Test MenuData", action: simulateMenuData)
                Button("Send Help Request", action: simulateHelpRequest)
                Button("Send DrawPath", action: simulateDrawPath)
            }

            Divider().padding(.vertical)

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(logMessages, id: \.self) { msg in
                        Text(msg)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .padding()
        .onAppear(perform: setupRouterHandlers)
    }

    // MARK: - Payload Simulations

    private func simulateMobilityProfile() {
        let profile = MobilityProfile(name: "Demo User", wheelchairUser: true, maxTravelDistanceMeters: 5.5, reachLevel: .limited, requiresAssistance: false, allergens: ["Shellfish"], notes: "Prefers booth seating", lastUpdated: .now)
        sendPayload(.mobilityProfile, model: profile)
    }

    private func simulateMenuData() {
        let items = [
            FoodItem(name: "Veggie Burger", description: "With avocado", price: 9.99, allergens: ["Gluten"], imageURL: nil, accessibilityInfo: nil),
            FoodItem(name: "Salad", description: "Mixed greens", price: 5.50, allergens: [], imageURL: nil, accessibilityInfo: nil)
        ]
        let menu = MenuData(locationID: "test123", locationName: "Demo Café", categories: [MenuCategory(name: "Main", items: items)])
        sendPayload(.menuData, model: menu)
    }

    private func simulateHelpRequest() {
        let payload = try? Payload(type: .alertMessage, model: "ping") // Dummy model
        if let payload = payload {
            PayloadRouter.shared.handle(payload: payload)
        }
    }

    private func simulateDrawPath() {
        let path = [CGPoint(x: 5, y: 5), CGPoint(x: 50, y: 100)]
        sendPayload(.drawPath, model: path)
    }

    // MARK: - Payload Send Helper

    private func sendPayload<T: Codable>(_ type: PayloadType, model: T) {
        do {
            // Step 1: Wrap model in Payload
            let payload = try Payload(type: type, model: model)

            // Step 2: Encode Payload as JSON
            let encodedPayload = try JSONEncoder().encode(payload)

            // Optional: log raw JSON
            if let jsonString = String(data: encodedPayload, encoding: .utf8) {
                logMessages.append("📤 Encoded JSON: \(jsonString)")
            }

            // Step 3: Decode back from JSON
            let decodedPayload = try JSONDecoder().decode(Payload.self, from: encodedPayload)

            // Step 4: Pass to router
            PayloadRouter.shared.handle(payload: decodedPayload)

        } catch {
            logMessages.append("❌ JSON roundtrip failed (\(type)): \(error.localizedDescription)")
        }
    }

    // MARK: - PayloadRouter Setup

    private func setupRouterHandlers() {
        PayloadRouter.shared.onReceiveMobilityProfile = { profile in
            logMessages.append("✅ Profile: \(profile.name), Allergens: \(profile.allergens.joined(separator: ", "))")
        }

        PayloadRouter.shared.onReceiveMenuData = { menu in
            logMessages.append("✅ Menu for \(menu.locationName) with \(menu.categories.count) categories")
        }

        PayloadRouter.shared.onReceiveAlertMessage = { alert in
            logMessages.append("🆘 Help requested")
        }

        PayloadRouter.shared.onReceiveDrawPath = { path in
            logMessages.append("✏️ Received draw path with \(path.count) points")
        }
    }
}
#Preview{
    PayloadTestView()
}
