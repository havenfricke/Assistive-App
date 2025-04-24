import SwiftUI
import ARKit
import SceneKit
import Vision
import CoreML

struct ARScannerTabView: View {
    let profile: MobilityProfile

    var body: some View {
        NavigationStack {
            ARScannerViewWrapper(profile: profile)
                .ignoresSafeArea()
                .navigationTitle("AR Scanner")
        }
    }

    struct ARScannerViewWrapper: UIViewRepresentable {
        let profile: MobilityProfile

        func makeCoordinator() -> Coordinator {
            Coordinator(
                peerConnectionManager: PeerConnectionManager.shared,
                payloadRouter: PayloadRouter.shared,
                mobilityProfile: profile
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

        class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
            let peerConnectionManager: PeerConnectionManager
            let payloadRouter: PayloadRouter
            var mobilityProfile: MobilityProfile

            let visionModel: VNCoreMLModel
            var request: VNCoreMLRequest?
            let requestHandlerQueue = DispatchQueue(label: "com.model.inference")

            var confidenceAboveThresholdFrames = 0
            let confidenceThreshold: Float = 0.95
            let requiredFrameCount = 5
            var hasTriggeredAction = false

            init(peerConnectionManager: PeerConnectionManager,
                 payloadRouter: PayloadRouter,
                 mobilityProfile: MobilityProfile) {
                self.peerConnectionManager = peerConnectionManager
                self.payloadRouter = payloadRouter
                self.mobilityProfile = mobilityProfile

                guard let mlModel = try? AccessibilityRecognitionModel(configuration: MLModelConfiguration()).model,
                      let vnModel = try? VNCoreMLModel(for: mlModel) else {
                    fatalError("Could not load AccessibilityRecognitionModel")
                }

                self.visionModel = vnModel
                super.init()
                self.setupRequest()
            }

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

            private func performHighConfidenceAction(identifier: String) {
                print("ACTION TRIGGERED: \(identifier)")
                // Future logic to initiate peer connection or trigger UI changes
            }

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
        }
    }
}
