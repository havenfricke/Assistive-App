import SwiftUI

struct CustomerInfoView: View {
    @ObservedObject var profileManager: MobilityProfileManager
    
    var body: some View {
        Group {
            if profileManager.connectedCustomers.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No connected customers.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(profileManager.connectedCustomers) { customer in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(customer.profile.name)
                            .font(.headline)

                        if let notes = customer.profile.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            Text("No additional notes.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Text("Connected at \(formattedDate(customer.connectedAt))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Connected Customers")
    }
}

private func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter.string(from: date)
}
