//
//  NavigationStaffView.swift
//  AssistiveApp
//
//  Created by Lukas Morawietz on 4/24/25.
//

import SwiftUI

struct TableImage: Identifiable {
    let id = UUID()
    let tableID: String
    let imageName: String
}

struct ImageUploadView: View {
    @State private var tableImages: [TableImage] = [TableImage(tableID: "T0", imageName: "exampleImage")]
    @State private var isAddingImage = false
    @State private var newTableID: String = ""
    @State private var selectedImage: UIImage?

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(tableImages) { tableImage in
                        VStack(alignment: .leading) {
                            if let uiImage = UIImage(named: tableImage.imageName) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .padding()
                            } else {
                                Text("Image not found")
                                    .foregroundColor(.secondary)
                                    .padding()
                            }
                            Text("Table ID: \(tableImage.tableID)")
                                .font(.headline)
                        }
                        .padding(.bottom)
                    }
                }

                Spacer()
            }
            .navigationTitle("Table Images")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isAddingImage = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingImage) {
                AddImageView(isPresented: $isAddingImage, tableImages: $tableImages)
            }
        }
    }
}

struct AddImageView: View {
    @Binding var isPresented: Bool
    @Binding var tableImages: [TableImage]
    @State private var tableID: String = ""
    @State private var selectedImage: UIImage?
    @State private var isFileImporterPresented = false

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter Table ID", text: $tableID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding()
                } else {
                    Text("No image selected")
                        .foregroundColor(.secondary)
                        .padding()
                }

                Button("Select Image") {
                    isFileImporterPresented = true
                }
                .padding()
                .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.image]) { result in
                    do {
                        let fileURL = try result.get()
                        if let imageData = try? Data(contentsOf: fileURL),
                           let uiImage = UIImage(data: imageData) {
                            selectedImage = uiImage
                        }
                    } catch {
                        print("Error selecting image: \(error)")
                    }
                }

                Spacer()

                Button("Accept") {
                    guard !tableID.isEmpty, let selectedImage = selectedImage else { return }
                    let imageName = "\(UUID().uuidString).png"
                    saveImageToDisk(image: selectedImage, name: imageName)
                    let newTableImage = TableImage(tableID: tableID, imageName: imageName)
                    tableImages.append(newTableImage)
                    isPresented = false
                }
                .padding()
                .disabled(tableID.isEmpty || selectedImage == nil)
            }
            .navigationTitle("Add Image")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }

    private func saveImageToDisk(image: UIImage, name: String) {
        if let data = image.pngData() {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
            try? data.write(to: url)
        }
    }
}

struct ImageUploadView_Previews: PreviewProvider {
    static var previews: some View {
        ImageUploadView()
    }
}
