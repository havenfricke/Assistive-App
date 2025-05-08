import SwiftUI
import Foundation

struct AlertInboxView: View {
    @ObservedObject var alertManager: AlertManager
    
    var body: some View {
        NavigationView {
            List {
                if $alertManager.receivedAlerts.isEmpty {
                    Text("No alerts yet.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(alertManager.receivedAlerts) { message in
                        VStack(alignment: .leading) {
                            Text(message.content)
                                .font(.headline)
                            if let name = message.customerName {
                                Text("From: \(name)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Text(message.timestamp, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                // MARK: - Simulate Alert Button
                Button("Simulate Incoming Alert") {
                    simulateIncomingAlert()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationTitle("Alerts")
        }
    }
}
    private func simulateIncomingAlert() {
        let dummyLocation = NavigationAssetDTO(
            name: "Table 8",
            category: .table,
            imageData: nil)
        let simulatedAlert = AlertMessage(
                    content: "Test Help Request",
                    location: dummyLocation,
                    customerName: "Simulated User",
                    timestamp: Date()
                )
                do {
                    let payload = try Payload(type: .alertMessage, model: simulatedAlert)
                    PayloadRouter.shared.handle(payload: payload)
                } catch {
                    print("Failed to simulate incoming alert payload: \(error)")
                }
        }

struct AlertMessage: Identifiable , Hashable, Codable, Equatable{
    let id = UUID()
    let content: String
    let location: NavigationAssetDTO
    let customerName: String?
    let timestamp: Date
}

#Preview {
    AlertInboxView(alertManager: AlertManager())
}


