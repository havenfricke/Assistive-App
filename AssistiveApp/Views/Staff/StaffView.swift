import SwiftUI
import SwiftData
import MultipeerConnectivity

struct StaffView: View {
    @StateObject private var mobilityProfileManager = MobilityProfileManager()
    @StateObject private var alertManager = AlertManager()
    @StateObject private var staffOrderManager = OrderManager()
    
    @Environment(\.modelContext) private var modelContext
    @Query private var navModels: [NavModel]
    
    // Choose location ID: "aacfa" or "aac32"
    private var netID: String = "aacfa"
    
    @StateObject private var menuBuilderVM: MenuBuilderViewModel
    
    init() {
        switch netID {
        case "aacfa":
            _menuBuilderVM = StateObject(wrappedValue: MenuBuilderViewModel(initialData: DemoMenuData.chickFilA()))
        case "aac32":
            _menuBuilderVM = StateObject(wrappedValue: MenuBuilderViewModel(initialData: DemoMenuData.cafe32()))
        default:
            _menuBuilderVM = StateObject(wrappedValue: MenuBuilderViewModel())
        }
    }
    
    var body: some View {
        TabView {
            AlertInboxView(alertManager: alertManager)
                .tabItem { Label("Alerts", systemImage: "exclamationmark.bubble") }
            
            CustomerInfoView(profileManager: mobilityProfileManager)
                .tabItem { Label("Customer Info", systemImage: "person.circle") }
            
            MenuBuilderView(viewModel: menuBuilderVM)
                .tabItem { Label("Menu Builder", systemImage: "list.bullet.rectangle") }
            
            OrdersListView(orderManager: staffOrderManager)
                .tabItem { Label("Orders", systemImage: "cart.fill") }
            
            NavigationAssetManagerView()
                .tabItem { Label("Navigation Config", systemImage: "map.fill") }
        }
        .navigationTitle("Staff Dashboard")
        .onAppear {
            configurePeerConnection()
            seedDemoDataIfNeeded()
        }
    }
    
    // MARK: - Seed NavModel Demo Data for Staff UI
    private func seedDemoDataIfNeeded() {
        guard navModels.isEmpty else {
            print("✅ NavModels already present")
            return
        }
        
        let demoAssets: [NavigationAssetDTO]
        switch netID {
        case "aacfa":
            demoAssets = DemoNavigationData.chickFilA()
        case "aac32":
            demoAssets = DemoNavigationData.cafe32()
        default:
            return
        }
        
        for dto in demoAssets {
            let model = dto.toNavModel()
            modelContext.insert(model)
        }
        
        print("✅ Seeded \(demoAssets.count) NavModels into SwiftData")
    }
    
    // MARK: - Peer Connection
    private func configurePeerConnection() {
        let peerManager = PeerConnectionManager.shared
        peerManager.serviceType = netID
        print(peerManager.serviceType)
        peerManager.isStaffMode = true
        
        peerManager.onPeerConnected = { peer in
            DispatchQueue.main.async {
                self.sendInitialDataToUser(peerID: peer)
            }
        }
        
        print("🔊 Staff device started advertising for user connections.")
    }
    
    private func sendInitialDataToUser(peerID: MCPeerID) {
        let navAssets: [NavigationAssetDTO]
        let menu: MenuData
        
        switch netID {
        case "aacfa":
            navAssets = DemoNavigationData.chickFilA()
            menu = DemoMenuData.chickFilA()
        case "aac32":
            navAssets = DemoNavigationData.cafe32()
            menu = DemoMenuData.cafe32()
        default:
            print("⚠️ Unknown netID")
            return
        }
        
        do {
            let floorplanAsset = navAssets.first(where: { $0.name.lowercased().contains("floorplan")})
            let navPayload = NavigationDataPayload(assets: navAssets, floorPlanData: floorplanAsset?.imageData)
            let navWrapped = try Payload(type: .navigationData, model: navPayload)
            PeerConnectionManager.shared.send(payload: navWrapped)
            
            let menuWrapped = try Payload(type: .menuData, model: menu)
            PeerConnectionManager.shared.send(payload: menuWrapped)
            
            print("📤 Sent initial nav and menu payloads")
        } catch {
            print("❌ Failed to send demo data: \(error)")
        }
    }
}
    // MARK: - Managers
    
class MobilityProfileManager: ObservableObject {
    @Published var connectedCustomers: [ConnectedCustomer] = []
    
    init() {
        PayloadRouter.shared.onReceiveMobilityProfile = { [weak self] profile in
            DispatchQueue.main.async {
                let connection = ConnectedCustomer(profile: profile, connectedAt: Date())
                self?.connectedCustomers.append(connection)
            }
        }
    }
}

struct ConnectedCustomer: Identifiable {
    let id = UUID()
    let profile: MobilityProfile
    let connectedAt: Date
}

class AlertManager: ObservableObject {
    @Published var receivedAlerts: [AlertMessage] = []
    
    init() {
        PayloadRouter.shared.onReceiveAlertMessage = { [weak self] alert in
            DispatchQueue.main.async {
                self?.receivedAlerts.append(alert)
            }
        }
    }
}
