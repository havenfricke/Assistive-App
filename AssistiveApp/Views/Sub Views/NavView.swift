//
//  NavigationView.swift
//  AssistiveApp
//
//  Created by Lukas Morawietz on 4/23/25.
//
import SwiftUI
import SwiftData

struct NavView: View {
    @StateObject private var navStore = NavigationAssetStore.shared
    let profile: MobilityProfile
    

    var body: some View {
        NavigationStack {
            List {
                if let image = navStore.floorPlanImage {
                    Section("Floor Plan"){
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .padding(.vertical, 8)
                    }
                }
                ForEach(LocationCategory.allCases) { category in
                    let assets = navStore.assets(for: category)
                    if !assets.isEmpty {
                        NavigationLink(category.displayName) {
                            NavigationAssetListView(category: category)
                        }
                    }
                }
            }
            .navigationBarItems(trailing:
                                    NavigationLink(destination: HelpRequestFormView(profile:profile)){
                Label("Help", systemImage: "questionmark.circle.fill")
            }
            )
            .navigationTitle("Navigation")
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

struct HelpRequestFormView: View{
    @EnvironmentObject var navAssetStore: NavigationAssetStore
    @Environment(\.dismiss) private var dismiss
    let profile: MobilityProfile
    
    @State private var selectedTable: NavigationAssetDTO?
    
    var body: some View{
        NavigationStack{
            Form{
                Section("Select Your Table"){
                    Picker("Table", selection: $selectedTable){
                        ForEach(navAssetStore.assets(for: .table)) { asset in
                            Text(asset.name).tag(Optional(asset))
                        }
                    }
                }
                Section {
                    Button("Send Help Request"){
                        sendAlert()
                    }
                    .disabled(selectedTable == nil)
                }
            }
        }
        .navigationTitle("Request Assistance")
        .toolbar {
            ToolbarItem(placement: .cancellationAction){
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
    func sendAlert(){
        guard let table = selectedTable else {return}
        let alert = AlertMessage(content: "Help Needed", location: table, customerName: profile.name, timestamp: Date())
        
        do {
            let payload = try Payload(type: .alertMessage, model: alert)
            PeerConnectionManager.shared.send(payload:payload)
            print("Sent help alert for \(table.name)")
            dismiss()
        } catch{
            print("Failed to send alert: \(error)")
        }
        
    }

}




    
    struct HelpNavigationView: View {
        @Query var navImages: [NavModel]
        @State private var selectedImage: NavModel?
        @State private var isShowingImagePreview = false
        
        var body: some View {
            VStack(spacing: 20) {
                Text("How can we help?")
                    .font(.title2)
                    .padding(.bottom, 20)
                
                ForEach(NavigationRequestType.allCases) { requestType in
                    Button {
                        handleNavigationRequest(requestType)
                    } label: {
                        Label(requestType.label, systemImage: requestType.systemImage)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .padding()
                            .background(color(for: requestType))
                            .cornerRadius(10)
                            .shadow(color: .gray, radius: 5, x: 0, y: 5)
                    }
                }
            }
            .padding()
            .navigationTitle("Help Navigation")
            .sheet(isPresented: $isShowingImagePreview) {
                if let sample = selectedImage {
                    ImagePreviewView(image: sample.image, name: sample.name)
                }
            }
        }
        
        func handleNavigationRequest(_ type: NavigationRequestType) {
            if let match = navImages.first(where: { $0.category == type.categoryMatch }) {
                let request = NavigationHelpRequest(
                    requestType: type.rawValue,
                    targetName: match.name
                )
                do {
                    let payload = try Payload(type: .navigationRequest, model: request)
                    PeerConnectionManager.shared.send(payload: payload)
                    print("✅ Sent navigation request for \(match.name)")
                    // Optional: show preview or success toast here
                } catch {
                    print("❌ Failed to send navigation request: \(error)")
                }
            } else {
                print("❌ No navigation asset found for \(type.label)")
            }
        }
        
        func color(for type: NavigationRequestType) -> Color {
            switch type {
            case .table: return .orange
            case .restroom: return .green
            case .customerStation: return .purple
            }
        }
        
    }
    struct ZoomedImageView: View {
        let imageName: String
        
        var body: some View {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
        }
    }

struct ImagePreviewView: View{
    let image: UIImage?
    let name: String
    
    var body: some View{
        NavigationStack{
            VStack{
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else{
                    Text("No Image available")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("Close") {
                        
                    }
                }
            }
        }
    }
    
    func sendDummyNavigationRequest() {
        let request = NavigationHelpRequest(
            requestType: "navigationHelp",
            targetName: name
        )
        do {
            let payload = try Payload(type: .navigationRequest, model: request)
            PeerConnectionManager.shared.send(payload: payload)
            print("✅ Sent dummy navigation request for \(name)")
        } catch {
            print("❌ Failed to encode navigation request: \(error)")
        }
    }

}

