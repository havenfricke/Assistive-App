import SwiftUI

struct SettingsView: View {
    @State private var allergensInput: String = ""
    @State private var showStaffView = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Allergens")) {
                    TextField("Enter allergens (comma separated)", text: $allergensInput)
                }
                Section(header: Text("Staff Access")) {
                    Button("Open Staff Dashboard") {
                        showStaffView = true
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showStaffView) {
                StaffView()
            }
        }
    }
}

#Preview {
    SettingsView()
}
