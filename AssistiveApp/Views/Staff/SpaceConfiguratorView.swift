import SwiftUI
import SwiftData
import MapKit

struct SpaceConfiguratorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var locationTags: [LocationTag]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        NavigationView {
            VStack {
                // Map view extracted for clarity
                mapView
                    .frame(height: 300)
                
                // List of tagged locations
                taggedLocationsList
                
                // Button to add new location
                Button("Add Sample Location") {
                    let newTag = LocationTag(
                        name: "Table \(locationTags.count + 1)",
                        tag: "Standard",
                        latitude: region.center.latitude,
                        longitude: region.center.longitude
                    )
                    modelContext.insert(newTag)
                    WebServiceManager.saveTag(newTag.name, tag: newTag.tag)
                }
                .padding()
            }
            .navigationTitle("Configure Space")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    // Extracted Map view to simplify type checking
    private var mapView: some View {
        Map(coordinateRegion: $region, annotationItems: locationTags) { tag in
            MapAnnotation(coordinate: (tag.latitude != nil && tag.longitude != nil) ? CLLocationCoordinate2D(latitude: tag.latitude!, longitude: tag.longitude!) : region.center) {
                annotationButton(for: tag)
            }
        }
    }
    
    // Extracted List view to simplify type checking
    private var taggedLocationsList: some View {
        List {
            Section(header: Text("Tagged Locations")) {
                ForEach(locationTags) { tag in
                    HStack {
                        Text(tag.name)
                        Spacer()
                        Text(tag.tag)
                            .foregroundColor(tag.tag == "Accessible" ? .green : .gray)
                    }
                }
                .onDelete { indices in
                    indices.forEach { modelContext.delete(locationTags[$0]) }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    // Extracted Button for MapAnnotation to reduce closure complexity
    @ViewBuilder
    private func annotationButton(for tag: LocationTag) -> some View {
        Button(action: {
            if let index = locationTags.firstIndex(where: { $0.id == tag.id }) {
                locationTags[index].tag = locationTags[index].tag == "Accessible" ? "Standard" : "Accessible"
                WebServiceManager.saveTag(locationTags[index].name, tag: locationTags[index].tag)
            }
        }) {
            Image(systemName: tag.tag == "Accessible" ? "star.fill" : "star")
                .foregroundColor(.yellow)
        }
    }
}

@Model
class LocationTag: Identifiable {
    var id: UUID = UUID()
    var name: String
    var tag: String
    var latitude: Double?
    var longitude: Double?
    
    init(name: String, tag: String, latitude: Double? = nil, longitude: Double? = nil) {
        self.name = name
        self.tag = tag
        self.latitude = latitude
        self.longitude = longitude
    }
}

#Preview {
    do {
        let container = try ModelContainer(
            for: LocationTag.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let tag = LocationTag(name: "Table 1", tag: "Accessible", latitude: 37.7749, longitude: -122.4194)
        container.mainContext.insert(tag)
        return SpaceConfiguratorView()
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
