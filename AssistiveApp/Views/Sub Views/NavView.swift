//
//  NavView.swift
//  AssistiveApp
//
//  Created by Lukas Morawietz on 4/23/25.
//

import SwiftUI
import SwiftData

struct NavView: View {
    @EnvironmentObject var locationDataManager: LocationDataManager
    @StateObject private var navStore = NavigationAssetStore.shared
    let profile: MobilityProfile

    var body: some View {
        NavigationStack {
            List {
                // Floor Plan Display
                if let image = navStore.floorPlanImage {
                    Section("Floor Plan") {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .padding(.vertical, 8)
                    }
                }

                // Navigation Categories or Empty State
                let allAssets = LocationCategory.allCases.flatMap { navStore.assets(for: $0) }

                if allAssets.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "map")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No navigation data received.")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    }
                } else {
                    ForEach(LocationCategory.allCases) { category in
                        let assets = navStore.assets(for: category)
                        if !assets.isEmpty {
                            NavigationLink(category.displayName) {
                                NavigationAssetListView(category: category)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Navigation")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: HelpRequestFormView(profile: profile)) {
                        HStack(spacing: 4) {
                            Image(systemName: "questionmark.circle.fill")
                            Text("Request Assistance")
                        }
                        .accessibilityLabel("Request Help")
                    }
                }
            }
        }
    }
}

struct NavigationAssetListView: View {
    let category: LocationCategory
    @EnvironmentObject var navAssetStore: NavigationAssetStore

    var body: some View {
        List {
            ForEach(navAssetStore.assets(for: category)) { asset in
                NavigationLink(asset.name) {
                    NavigationAssetDetailView(asset: asset)
                }
            }
        }
        .navigationTitle(category.displayName)
    }
}

struct NavigationAssetDetailView: View {
    let asset: NavigationAssetDTO

    var body: some View {
        VStack(spacing: 16) {
            if let data = asset.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .padding()
            } else {
                Text("No image available")
                    .foregroundColor(.secondary)
            }

            Text(asset.name)
                .font(.title2)
                .bold()
        }
        .navigationTitle(asset.name)
    }
}

struct HelpRequestFormView: View {
    @EnvironmentObject var navAssetStore: NavigationAssetStore
    @Environment(\.dismiss) private var dismiss
    let profile: MobilityProfile

    @State private var selectedTable: NavigationAssetDTO?

    var body: some View {
        NavigationStack {
            Form {
                Section("Select Your Location") {
                    Picker("Location", selection: $selectedTable) {
                        ForEach(navAssetStore.assets) { asset in
                            Text(asset.name).tag(Optional(asset))
                        }
                    }
                }
                Section {
                    Button("Send Help Request") {
                        sendAlert()
                    }
                    .disabled(selectedTable == nil)
                }
            }
            .navigationTitle("Request Assistance")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    func sendAlert() {
        guard let table = selectedTable else { return }
        let alert = AlertMessage(content: "Help Needed", location: table, customerName: profile.name, timestamp: Date())

        do {
            let payload = try Payload(type: .alertMessage, model: alert)
            PeerConnectionManager.shared.send(payload: payload)
            print("Sent help alert for \(table.name)")
            dismiss()
        } catch {
            print("Failed to send alert: \(error)")
        }
    }
}
