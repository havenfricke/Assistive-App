import SwiftUI
import Foundation

struct AlertInboxView: View {
    @ObservedObject var alertManager: AlertManager
    
    var body: some View {
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
                            Text("At: \(message.location.name)")
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
        }
        .navigationTitle("Alerts")
    }
}

struct AlertMessage: Identifiable , Hashable, Codable, Equatable{
    let id = UUID()
    let content: String
    let location: NavigationAssetDTO
    let customerName: String?
    let timestamp: Date
}

