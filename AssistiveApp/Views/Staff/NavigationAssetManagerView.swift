import SwiftUI
import SwiftData

struct NavigationAssetManagerView: View {
    @Query(sort: \NavModel.name) var samples: [NavModel]
    @Environment(\.modelContext) private var modelContext
    @State private var formType: NavigationImageFormType?

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

                Section {
                    Button("Generate & Send Navigation Assets") {
                        // Placeholder for future Multipeer payload trigger
                        print("🚧 Sending navigation assets not yet implemented")
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
