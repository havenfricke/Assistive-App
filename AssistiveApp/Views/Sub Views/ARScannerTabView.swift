//
//  ARScannerTabView.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//

 
import SwiftUI
import ARKit
import SceneKit

struct ARScannerTabView: View {
    var body: some View {
        NavigationStack {
            ARScannerViewWrapper()
                .ignoresSafeArea()
                .navigationTitle("AR Scanner")
        }
    }
}

struct ARScannerViewWrapper: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        sceneView.delegate = context.coordinator

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]

        sceneView.session.run(configuration)
        sceneView.autoenablesDefaultLighting = true

        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}

    static func dismantleUIView(_ uiView: ARSCNView, coordinator: Coordinator) {
        uiView.session.pause() // This prevents crashes when navigating away
    }

    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        // Optionally handle AR events here
    }
}

