import SwiftUI
import ARKit
import SceneKit
import Vision
import CoreML

// MARK: - ARScannerTabView (Main Entry View)

struct ARScannerTabView: View {
    let profile: MobilityProfile
    @State private var showRetryPrompt = false

    var body: some View {
        NavigationStack {
            ZStack {
                ARScannerViewWrapper(profile: profile, showRetryPrompt: $showRetryPrompt)
                    .ignoresSafeArea()

                if showRetryPrompt {
                    // MARK: - Retry UI Overlay
                    VStack {
                        Text("No staff device found.")
                            .font(.headline)
                            .padding()
                        Button("Retry") {
                            showRetryPrompt = false
                            PeerConnectionManager.shared.start() // Retry browsing
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
            .navigationTitle("AR Scanner")
        }
    }

    // MARK: - ARScannerViewWrapper (UIViewRepresentable)

    struct ARScannerViewWrapper: UIViewRepresentable {
        let profile: MobilityProfile
        @Binding var showRetryPrompt: Bool

        func makeCoordinator() -> Coordinator {
            Coordinator(
                peerConnectionManager: PeerConnectionManager.shared,
                payloadRouter: PayloadRouter.shared,
                mobilityProfile: profile,
                showRetryPrompt: $showRetryPrompt
            )
        }

        func makeUIView(context: Context) -> ARSCNView {
            let sceneView = ARSCNView()
            sceneView.delegate = context.coordinator
            sceneView.session.delegate = context.coordinator

            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal]
            sceneView.session.run(configuration)
            sceneView.autoenablesDefaultLighting = true

            return sceneView
        }

        func updateUIView(_ uiView: ARSCNView, context: Context) {}

        static func dismantleUIView(_ uiView: ARSCNView, coordinator: Coordinator) {
            uiView.session.pause()
        }

        // MARK: - Coordinator

        class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
            // MARK: - Properties

            let peerConnectionManager: PeerConnectionManager
            let payloadRouter: PayloadRouter
            var mobilityProfile: MobilityProfile
            private var showRetryPrompt: Binding<Bool>

            let visionModel: VNCoreMLModel
            var request: VNCoreMLRequest?
            let requestHandlerQueue = DispatchQueue(label: "com.model.inference")

            var confidenceAboveThresholdFrames = 0
            let confidenceThreshold: Float = 0.95
            let requiredFrameCount = 5
            var hasTriggeredAction = false

            // MARK: - Init

            init(peerConnectionManager: PeerConnectionManager,
                 payloadRouter: PayloadRouter,
                 mobilityProfile: MobilityProfile,
                 showRetryPrompt: Binding<Bool>) {
                self.peerConnectionManager = peerConnectionManager
                self.payloadRouter = payloadRouter
                self.mobilityProfile = mobilityProfile
                self.showRetryPrompt = showRetryPrompt

                guard let mlModel = try? AccessibilityRecognitionModel(configuration: MLModelConfiguration()).model,
                      let vnModel = try? VNCoreMLModel(for: mlModel) else {
                    fatalError("Could not load AccessibilityRecognitionModel")
                }

                self.visionModel = vnModel
                super.init()
                self.setupRequest()
            }

            // MARK: - Vision Setup

            private func setupRequest() {
                self.request = VNCoreMLRequest(model: visionModel) { request, error in
                    guard let results = request.results as? [VNClassificationObservation],
                          let topResult = results.first else {
                        print("No results from Vision")
                        self.confidenceAboveThresholdFrames = 0
                        self.hasTriggeredAction = false
                        return
                    }

                    DispatchQueue.main.async {
                        print("Recognized Symbol: \(topResult.identifier) – Confidence: \(topResult.confidence)")

                        if topResult.confidence > self.confidenceThreshold {
                            self.confidenceAboveThresholdFrames += 1
                        } else {
                            self.confidenceAboveThresholdFrames = 0
                            self.hasTriggeredAction = false
                        }

                        if self.confidenceAboveThresholdFrames >= self.requiredFrameCount && !self.hasTriggeredAction {
                            self.hasTriggeredAction = true
                            self.performHighConfidenceAction(identifier: topResult.identifier)
                        }
                    }
                }

                self.request?.imageCropAndScaleOption = .centerCrop
            }

            // MARK: - ARSession Frame Update

            func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
                guard let sceneView = renderer as? ARSCNView,
                      let frame = sceneView.session.currentFrame else { return }

                let pixelBuffer = frame.capturedImage
                self.performVisionRequest(pixelBuffer: pixelBuffer)
            }

            private func performVisionRequest(pixelBuffer: CVPixelBuffer) {
                guard let request = self.request else { return }

                requestHandlerQueue.async {
                    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
                    do {
                        try handler.perform([request])
                    } catch {
                        print("Vision error: \(error)")
                    }
                }
            }

            // MARK: - High Confidence Action

            private func performHighConfidenceAction(identifier: String) {
                print("ACTION TRIGGERED: \(identifier)")
                peerConnectionManager.isStaffMode = false

                peerConnectionManager.onPeerConnected = { [weak self] peerID in
                    guard let self = self else { return }
                    print("Peer Connected: \(peerID.displayName)")
                    self.sendMobilityProfile()
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                    guard let self = self else { return }
                    if !self.peerConnectionManager.hasConnectedPeers {
                        self.showRetryPromptIfNeeded()
                    }
                }
            }
            
            // MARK: - Send Mobility Profile
            private func sendMobilityProfile() {
                do {
                    let payload = try Payload(type: .mobilityProfile, model: mobilityProfile)
                    peerConnectionManager.send(payload: payload)
                } catch {
                    print("Failed to send mobility Profile: \(error)")
                }
            }

            // MARK: - UI Prompt

            private func showRetryPromptIfNeeded() {
                DispatchQueue.main.async {
                    self.showRetryPrompt.wrappedValue = true
                }
            }
        }
    }
}
