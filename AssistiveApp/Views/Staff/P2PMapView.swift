import SwiftUI
import MapKit

struct P2PMapView: View {
    @ObservedObject var communicator: PeerCommunicator
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var annotations: [MapAnnotationItem] = []
    
    struct MapAnnotationItem: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
        let sender: String
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Map(coordinateRegion: $region, annotationItems: annotations) { item in
                    MapMarker(coordinate: item.coordinate, tint: item.sender == "Staff" ? .blue : .red)
                }
                .gesture(
                    TapGesture()
                        .onEnded { _ in
                            let newCoordinate = CLLocationCoordinate2D(
                                latitude: region.center.latitude + Double.random(in: -0.001...0.001),
                                longitude: region.center.longitude + Double.random(in: -0.001...0.001)
                            )
                            let newAnnotation = MapAnnotationItem(coordinate: newCoordinate, sender: "Staff")
                            annotations.append(newAnnotation)
                            communicator.sendMessage(
                                AlertMessage(
                                    content: "Marker at (\(newCoordinate.latitude), \(newCoordinate.longitude))",
                                    customerName: nil,
                                    timestamp: Date()
                                )
                            )
                        }
                )
                .frame(height: 400)
                
                Button("Clear Markers") {
                    annotations.removeAll()
                    communicator.sendMessage(
                        AlertMessage(content: "Map cleared", customerName: nil, timestamp: Date())
                    )
                }
                .padding()
            }
            .navigationTitle("P2P Map")
            .onAppear {
                annotations.append(MapAnnotationItem(
                    coordinate: CLLocationCoordinate2D(latitude: 37.775, longitude: -122.42),
                    sender: "Customer"
                ))
            }
        }
    }
}

#Preview {
    P2PMapView(communicator: PeerCommunicator())
}
