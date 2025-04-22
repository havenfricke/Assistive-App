import SwiftUI

struct AlertInboxView: View {
    @ObservedObject var communicator: PeerCommunicator
    
    var body: some View {
        NavigationView {
            List {
                if communicator.receivedMessages.isEmpty {
                    Text("No alerts yet.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(communicator.receivedMessages) { message in
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
            }
            .navigationTitle("Alerts")
        }
    }
}

struct AlertMessage: Identifiable, Hashable {
    let id = UUID()
    let content: String
    let customerName: String?
    let timestamp: Date
}

class PeerCommunicator: ObservableObject {
    @Published var receivedMessages: [AlertMessage] = [
        AlertMessage(content: "Need help at Table 5", customerName: "John Doe", timestamp: Date())
    ]
    
    func sendMessage(_ message: AlertMessage) {
        receivedMessages.append(message)
    }
}

#Preview {
    AlertInboxView(communicator: PeerCommunicator())
}
