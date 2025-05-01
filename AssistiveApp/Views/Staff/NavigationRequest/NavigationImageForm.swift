import SwiftUI
import SwiftData
import PhotosUI

struct NavigationImageForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State var vm: NavigationImageFormModel
    @State private var imagePicker = ImagePicker()
    @State private var showCamera = false
    @State private var cameraError: CameraPermission.CameraError?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $vm.name)

                    Picker("Category", selection: $vm.category) {
                        ForEach(LocationCategory.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                Section(header: Text("Photo")) {
                    if vm.data != nil {
                        Button("Clear Image") {
                            vm.clearImage()
                        }
                        .buttonStyle(.bordered)
                    }

                    HStack {
                        Button("Camera", systemImage: "camera") {
                            if let error = CameraPermission.checkPermissions() {
                                cameraError = error
                            } else {
                                showCamera.toggle()
                            }
                        }
                        .alert(isPresented: .constant(cameraError != nil), error: cameraError) { _ in
                            Button("OK") { cameraError = nil }
                        } message: { error in
                            Text(error.recoverySuggestion ?? "Try again later")
                        }
                        .sheet(isPresented: $showCamera) {
                            UIKitCamera(selectedImage: $vm.cameraImage)
                                .ignoresSafeArea()
                        }

                        PhotosPicker(selection: $imagePicker.imageSelection) {
                            Label("Photos", systemImage: "photo")
                        }
                    }
                    .foregroundStyle(.white)
                    .buttonStyle(.borderedProminent)

                    Image(uiImage: vm.image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                }
            }

            .onAppear {
                imagePicker.setup(vm)
            }

            .onChange(of: vm.cameraImage) {
                if let image = vm.cameraImage {
                    vm.data = image.jpegData(compressionQuality: 0.8)
                }
            }

            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(vm.isUpDating ? "Update" : "Add") {
                        if vm.isUpDating {
                            if let sample = vm.sample {
                                sample.name = vm.name
                                sample.category = vm.category
                                sample.data = vm.image == Constants.placeholder ? nil : vm.image.jpegData(compressionQuality: 0.8)
                            }
                        } else {
                            let newSample = NavModel(name: vm.name, category: vm.category)
                            newSample.data = vm.image == Constants.placeholder ? nil : vm.image.jpegData(compressionQuality: 0.8)
                            modelContext.insert(newSample)
                        }
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(vm.isDisabled)
                }
            }
        }
    }
}
