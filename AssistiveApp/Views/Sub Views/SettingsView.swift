//
//  SettingsView.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var allergensInput: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Allergens")) {
                    TextField("Enter allergens (comma separated)", text: $allergensInput)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
