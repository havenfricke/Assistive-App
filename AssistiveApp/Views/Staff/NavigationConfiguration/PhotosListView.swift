//
// Created for Camera Photos SwiftData
// by  Stewart Lynch on 2024-03-18
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import SwiftUI
import SwiftData

struct PhotosListView: View {
    @Query(sort: \SampleModel.name) var samples: [SampleModel]
    @Environment(\.modelContext) private var modelContext
    @State private var formType: ModelFormType?
    var body: some View {
        NavigationStack {
            Group {
                if samples.isEmpty {
                    ContentUnavailableView("Add your Table Navigation pictures", systemImage: "photo")
                } else {
                    List(samples) { sample in
                        NavigationLink(value: sample) {
                            HStack {
                                Image(uiImage: sample.image == nil ? Constants.placeholder : sample.image!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding(.trailing)
                                Text(sample.name)
                                    .font(.title)
                            }
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
                    .listStyle(.plain)
                }
            }
            .navigationDestination(for: SampleModel.self) { sample in
                SampleView(sample: sample)
            }
            .navigationTitle("Navigation Photos")
            .toolbar {
                Button {
                    formType = .new
                }label: {
                    Image(systemName: "plus.circle.fill")
                }
                .sheet(item: $formType) { $0 }
            }
            .onAppear {
                // Check if the samples list is empty and add initial samples if it is
                if samples.isEmpty {
                    addInitialSamples()
                }
            }
        }
    }
    
    //manually add initial samples from cafe if the list is empty
    private func addInitialSamples() {
            let initialSamples = [
                SampleModel(name: "General Floor Plan", data: UIImage(named: "FloorPlan")?.pngData()),
                SampleModel(name: "Restroooms", data: UIImage(named: "Restrooms")?.pngData()),
                SampleModel(name: "Table1", data: UIImage(named: "Table1")?.pngData()),
                SampleModel(name: "Table2", data: UIImage(named: "Table2")?.pngData()),
                SampleModel(name: "Table3", data: UIImage(named: "Table3")?.pngData()),
                SampleModel(name: "Table4", data: UIImage(named: "Table4")?.pngData()),
                SampleModel(name: "Table5", data: UIImage(named: "Table5")?.pngData()),
                SampleModel(name: "Table6", data: UIImage(named: "Table6")?.pngData()),
                SampleModel(name: "Table7", data: UIImage(named: "Table7")?.pngData()),
                SampleModel(name: "Table8", data: UIImage(named: "Table8")?.pngData()),
                SampleModel(name: "Table9", data: UIImage(named: "Table9")?.pngData()),
                SampleModel(name: "Table10", data: UIImage(named: "Table10")?.pngData())
            ]
            for sample in initialSamples {
                modelContext.insert(sample)
            }
            try? modelContext.save()
        }
}

#Preview {
    PhotosListView()
        .modelContainer(SampleModel.preview)
}
