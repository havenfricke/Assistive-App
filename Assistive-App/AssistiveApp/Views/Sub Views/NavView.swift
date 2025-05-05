//
//  NavigationView.swift
//  AssistiveApp
//
//  Created by Lukas Morawietz on 4/23/25.
//
import SwiftUI
import SwiftData

struct NavView: View {
    @State private var isZoomed: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("General Floor Plan")
                    .font(.title)
                Image("FloorPlan")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .onTapGesture {
                        isZoomed = true
                    }
                    .sheet(isPresented: $isZoomed) {
                        ZoomedImageView(imageName: "FloorPlan")
                    }
                Text("Tap the image to zoom in.")
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                NavigationLink(destination: HelpNavigationView()) {
                    Text("Need Help Navigating")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 60) // Größere Höhe
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(color: .gray, radius: 5, x: 0, y: 5) 
                }
                .padding(.horizontal)
                .navigationTitle("Navigation")
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

