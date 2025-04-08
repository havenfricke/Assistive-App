//
//  ARScannerTabView.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//


//
//  ARScannerTabView.swift
//  AssistiveApp
//
//  Created by Developer on [Date].
//  A wrapper view that embeds an AR experience (using ARKit) to simulate scanning.
//  Future development can add QR code/image recognition.
 
import SwiftUI
import ARKit

struct ARScannerTabView: View {
    var body: some View {
        NavigationView {
            ARScannerViewWrapper()
                .edgesIgnoringSafeArea(.all)
                .navigationTitle("AR Scanner")
        }
    }
}

struct ARScannerViewWrapper: UIViewRepresentable {
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
        return sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Update your AR scene here as needed.
    }
}
