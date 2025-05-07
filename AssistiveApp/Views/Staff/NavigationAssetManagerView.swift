import SwiftUI
import SwiftData
import PhotosUI

struct NavigationAssetManagerView: View {
    @Query(sort: \NavModel.name) var samples: [NavModel]
    @Environment(\.modelContext) private var modelContext
    @State private var formType: NavigationImageFormType?

    @State private var floorPlanImageItem: PhotosPickerItem?
    @State private var floorPlanImageData: Data?

    var body: some View {
        NavigationStack {
            Form {
                if samples.isEmpty {
                    ContentUnavailableView("No navigation images yet.", systemImage: "photo")
                } else {
                    ForEach(LocationCategory.allCases) { category in
                        let items = samples.filter { $0.category == category }
                        if !items.isEmpty {
                            Section(header: Text(category.displayName)) {
                                ForEach(items) { sample in
                                    NavigationLink(value: sample) {
                                        NavigationImageRow(sample: sample)
                                    }
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            modelContext.delete(sample)
                                            try? modelContext.save()
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ✅ Floor Plan Image Section
                Section("Floor Plan") {
                    PhotosPicker("Select Floor Plan Image", selection: $floorPlanImageItem, matching: .images)
                        .onChange(of: floorPlanImageItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    floorPlanImageData = data
                                    print("✅ Loaded floor plan image (\(data.count) bytes)")
                                } else {
                                    print("⚠️ Failed to load floor plan image")
                                }
                            }
                        }

                    if let data = floorPlanImageData, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                            .padding(.vertical, 4)
                    }
                }

                // ✅ Send Payload Section
                Section {
                    Button("Send Navigation Data") {
                        do {
                            let dtoList = samples.map { $0.toDTO() }
                            let payload = NavigationDataPayload(assets: dtoList, floorPlanData: floorPlanImageData)
                            let wrappedPayload = try Payload(type: .navigationData, model: payload)
                            PeerConnectionManager.shared.send(payload: wrappedPayload)
                            print("📦 Sent navigation data with \(dtoList.count) assets and floor plan")
                        } catch {
                            print("❌ Failed to send navigation data payload: \(error)")
                        }
                    }
                }
            }
            .navigationDestination(for: NavModel.self) { sample in
                SampleView(sample: sample)
            }
            .navigationTitle("Navigation Config")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        formType = .new
                    } label: {
                        Label("Add Image", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(item: $formType) { $0 }
        }
    }
}

// MARK: - Row Renderer

struct NavigationImageRow: View {
    let sample: NavModel

    var body: some View {
        HStack {
            Image(uiImage: sample.image ?? Constants.placeholder)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.trailing, 8)
            Text(sample.name)
                .font(.body)
        }
    }
}

#Preview {
    NavigationAssetManagerView()
        .modelContainer(NavModel.preview)
}
