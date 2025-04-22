import SwiftUI
import SwiftData

struct StaffView: View {
    @StateObject private var communicator = PeerCommunicator()
    @Query private var customers: [Customer]
    
    var body: some View {
        NavigationView {
            TabView {
                AlertInboxView(communicator: communicator)
                    .tabItem { Label("Alerts", systemImage: "exclamationmark.bubble") }
                CustomerInfoView(selectedCustomer: customers.first)
                    .tabItem { Label("Customer Info", systemImage: "person.circle") }
                SpaceConfiguratorView()
                    .tabItem { Label("Configure Space", systemImage: "slider.horizontal.3") }
                P2PMapView(communicator: communicator)
                    .tabItem { Label("Map", systemImage: "map") }
            }
            .navigationTitle("Staff Dashboard")
        }
    }
}

#Preview("StaffView") {
    do {
        let container = try ModelContainer(
            for: Customer.self, LocationTag.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let customer = Customer(
            name: "John Doe",
            photoURL: nil,
            allergens: ["Gluten"],
            avoidStairs: true,
            maxDistance: 10
        )
        container.mainContext.insert(customer)
        let tag = LocationTag(name: "Table 1", tag: "Accessible", latitude: 37.7749, longitude: -122.4194)
        container.mainContext.insert(tag)
        return StaffView()
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
