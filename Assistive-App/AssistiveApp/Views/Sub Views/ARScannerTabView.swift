import SwiftUI
import SwiftData

struct ARScannerTabView: View {
    let profile: MobilityProfile

    @Environment(\.modelContext) private var modelContext
    @Query private var accessPoints: [AccessPoint]

    @State private var showRetryPrompt = false
    @State private var showScanner = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(accessPoints) { point in
                    NavigationLink {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(point.desc)
                                .font(.title3)
                                .bold()
                            Text("Scanned at: \(point.netID)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding()
                    } label: {
                        VStack(alignment: .leading) {
                            Text(point.desc)
                                .font(.headline)
                            Text(point.netID)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showScanner.toggle()
                    }) {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                }
            }
            .sheet(isPresented: $showScanner) {
                ScannerViewControllerWrapper { scannedValue in
                    handleScan(value: scannedValue)
                    showScanner = false
                }
                .ignoresSafeArea()
            }
        } detail: {
            ZStack {
                Text("Select an item")
                    .font(.title3)
                    .foregroundColor(.secondary)

                if showRetryPrompt {
                    VStack {
                        Text("No staff device found.")
                            .font(.headline)
                            .padding()
                        Button("Retry") {
                            showRetryPrompt = false
                            PeerConnectionManager.shared.start()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(16)
                    .padding()
                }
            }
        }
    }

    // MARK: - Item Actions

    private func addItem() {
        withAnimation {
            let newItem = AccessPoint(
                netID: Date().formatted(date: .numeric, time: .standard),
                desc: "Manually added item"
            )
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(accessPoints[index])
            }
        }
    }

    // MARK: - Handle Scan + Networking

    private func handleScan(value: String) {
        guard let url = URL(string: value) else {
            print("Invalid URL in scanned QR")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let item = try? JSONDecoder().decode(ServerItem.self, from: data) {
                    DispatchQueue.main.async {
                        withAnimation {
                            let combinedText = "\(item.netID): \(item.desc)"
                            let newItem = AccessPoint(
                                netID: Date().formatted(date: .numeric, time: .standard),
                                desc: combinedText
                            )
                            modelContext.insert(newItem)
                        }
                        performHighConfidenceAction(identifier: item.netID)
                    }
                } else {
                    print("Decoding failed")
                }
            } else if let error = error {
                print("Network error: \(error)")
            }
        }.resume()
    }

    private func performHighConfidenceAction(identifier: String) {
        print("ACTION TRIGGERED FROM QR: \(identifier)")
        let peerConnectionManager = PeerConnectionManager.shared
        peerConnectionManager.isStaffMode = false

        peerConnectionManager.onPeerConnected = { peerID in
            print("Peer Connected: \(peerID.displayName)")
            sendMobilityProfile()
        }

        PayloadRouter.shared.onReceivedNavigationData = { payload in
            Task { @MainActor in
                NavigationAssetStore.shared.updatedAssets(payload.assets)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if !peerConnectionManager.hasConnectedPeers {
                showRetryPrompt = true
            }
        }
    }

    private func sendMobilityProfile() {
        do {
            let payload = try Payload(type: .mobilityProfile, model: profile)
            PeerConnectionManager.shared.send(payload: payload)
        } catch {
            print("Failed to send mobility profile: \(error)")
        }
    }
}
