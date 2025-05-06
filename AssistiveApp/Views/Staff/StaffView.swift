import SwiftUI
import SwiftData
import MultipeerConnectivity

struct StaffView: View {
    @StateObject private var mobilityProfileManager = MobilityProfileManager()
    @StateObject private var alertManager = AlertManager()
//    @StateObject private var navManager = NavigationHelpRequestManager()
    
    var body: some View {
        NavigationView {
            TabView {
                AlertInboxView(alertManager: alertManager)
                    .tabItem { Label("Alerts", systemImage: "exclamationmark.bubble") }
                CustomerInfoView(profileManager: mobilityProfileManager)
                    .tabItem { Label("Customer Info", systemImage: "person.circle") }
                MenuBuilderView()
                    .tabItem{Label("Menu Builder", systemImage: "list.bullet.rectangle")}
                OrdersListView(orderManager: OrderManager())
                    .tabItem{Label("Orders", systemImage: "cart.fill")}
                NavigationAssetManagerView()
                    .tabItem{Label("Navigation Config", systemImage: "map.fill")}
                //LiveNavigationRequestsView(navRequestManager: navManager)
                //    .tabItem { Label("Nav Requests", systemImage: "arrowshape.turn.up.right") }


            }
            .navigationTitle("Staff Dashboard")
            .onAppear {
                configurePeerConnection()
            }
        }
    }
    // MARK: - Setup Peer Connection
    private func configurePeerConnection() {
        let peerManager = PeerConnectionManager.shared
        peerManager.isStaffMode=true
        
        peerManager.onPeerConnected = { peer in
            DispatchQueue.main.async {
                self.sendInitialDataToUser(peerID:peer)
            }
        }
        print("staff device started advertising for user connections.")
    }
    private func sendInitialDataToUser(peerID: MCPeerID) {
        let exampleMenu = MenuData(
            locationID: UUID().uuidString, // Generate a random ID for now
            locationName: "Assistive Test Cafe",
            categories: [
                MenuCategory(name: "Entrees", items: [
                    FoodItem(
                        name: "Classic Burger",
                        description: "A juicy beef burger with lettuce and tomato.",
                        price: 9.99,
                        allergens: ["Gluten", "Dairy"],
                        imageURL: nil, accessibilityInfo: nil
                    ),
                    FoodItem(
                        name: "Grilled Chicken Sandwich",
                        description: "Grilled chicken breast on a toasted bun.",
                        price: 8.49,
                        allergens: ["Gluten"],
                        imageURL: nil, accessibilityInfo: nil
                    )
                ]),
                MenuCategory(name: "Drinks", items: [
                    FoodItem(
                        name: "Iced Coffee",
                        description: "Cold brew coffee served over ice.",
                        price: 3.99,
                        allergens: [],
                        imageURL: nil, accessibilityInfo: nil
                    ),
                    FoodItem(
                        name: "Fresh Orange Juice",
                        description: "Fresh-squeezed orange juice.",
                        price: 4.49,
                        allergens: [],
                        imageURL: nil, accessibilityInfo: nil
                    )
                ])
            ]
        )

        do {
            let payload = try Payload(type: .menuData, model: exampleMenu)
            PeerConnectionManager.shared.send(payload: payload)
            print("✅ Sent initial MenuData payload to connected user: \(peerID.displayName)")
        } catch {
            print("❌ Failed to send initial MenuData payload: \(error)")
        }
        
    }
}


class MobilityProfileManager: ObservableObject{
    @Published var connectedCustomers: [ConnectedCustomer] = []
    
    init(){
        PayloadRouter.shared.onReceiveMobilityProfile = { [weak self] profile in
            DispatchQueue.main.async{
                let connection = ConnectedCustomer(profile: profile, connectedAt: Date())
                self?.connectedCustomers.append(connection)
            }
        }
    }
}

struct ConnectedCustomer: Identifiable{
    let id = UUID()
    let profile: MobilityProfile
    let connectedAt: Date
}


class AlertManager: ObservableObject{
    @Published var receivedAlerts: [AlertMessage] = []
    
    init(){
        PayloadRouter.shared.onReceiveAlertMessage = { [weak self] alert in
            DispatchQueue.main.async{
                self?.receivedAlerts.append(alert)
            }
        }
    }
}

#Preview {
    StaffView()
}
