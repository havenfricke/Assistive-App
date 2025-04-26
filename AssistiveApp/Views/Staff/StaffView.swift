import SwiftUI
import SwiftData

struct StaffView: View {
    @StateObject private var mobilityProfileManager = MobilityProfileManager()
    @StateObject private var alertManager = AlertManager()
    @Query private var customers: [Customer]
    
    var body: some View {
        NavigationView {
            TabView {
                AlertInboxView(alertManager: alertManager)
                    .tabItem { Label("Alerts", systemImage: "exclamationmark.bubble") }
                CustomerInfoView(receivedProfile: mobilityProfileManager.receivedProfile)
                    .tabItem { Label("Customer Info", systemImage: "person.circle") }

            }
            .navigationTitle("Staff Dashboard")
        }
    }
}

class MobilityProfileManager: ObservableObject{
    @Published var receivedProfile: MobilityProfile?
    
    init(){
        PayloadRouter.shared.onReceiveMobilityProfile = { [weak self] profile in
            DispatchQueue.main.async{
                self?.receivedProfile = profile
            }
        }
    }
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
