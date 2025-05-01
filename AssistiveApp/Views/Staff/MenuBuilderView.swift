import SwiftUI

struct MenuBuilderView: View {
    @StateObject private var viewModel: MenuBuilderViewModel

    // Allow injection for previews/testing
    init(viewModel: MenuBuilderViewModel = MenuBuilderViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                LocationSection(viewModel: viewModel)
                CategoriesTabView(viewModel: viewModel)

                Section {
                    Button("Generate & Send Menu") {
                        if let menu = viewModel.buildMenuData() {
                            do {
                                let payload = try Payload(type: .menuData, model: menu)
                                PeerConnectionManager.shared.send(payload: payload)
                                print("✅ Sent menu")
                            } catch {
                                print("❌ Failed to send: \(error)")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Menu Builder")
        }
    }
}

#Preview {
    MenuBuilderView(viewModel: MenuBuilderViewModel(previewData: true))
}


struct LocationSection: View{
    @ObservedObject var viewModel: MenuBuilderViewModel
    
    var body: some View {
        Section(header: Text("Location Info")){
            TextField("Location Name", text: $viewModel.locationName)
            Text("Location ID: \(viewModel.locationID)")
        }
    }
}

struct CategoriesTabView: View {
    @ObservedObject var viewModel: MenuBuilderViewModel
    @State private var selectedIndex: Int = 0
    @State private var selectedItem: EditableFoodItem?  // 🔼 LIFTED UP

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Custom Tab Bar (unchanged)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.categories.indices, id: \.self) { index in
                        let isSelected = index == selectedIndex
                        Button(action: {
                            selectedIndex = index
                        }) {
                            Text(viewModel.categories[index].name.isEmpty ? "Untitled" : viewModel.categories[index].name)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isSelected ? Color.red : Color(.systemGray5))
                                .foregroundColor(isSelected ? .white : .primary)
                                .cornerRadius(16)
                        }
                    }

                    Button(action: {
                        viewModel.addCategory()
                        selectedIndex = viewModel.categories.count - 1
                    }) {
                        Text("Add Category")
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
            }

            // Category Editor
            if viewModel.categories.indices.contains(selectedIndex) {
                CategoryEditor(
                    categoryBinding: $viewModel.categories[selectedIndex],
                    selectedItem: $selectedItem   // 🔽 PASSED DOWN
                )
                .padding(.horizontal)
            } else {
                Text("No categories yet.")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        // ✅ FIX: Apply navigationDestination here (outside Lazy container)
        .navigationDestination(item: $selectedItem) { item in
            ItemEditorView(item: item, categoryBinding: $viewModel.categories[selectedIndex])
        }
    }
}


struct CategoryEditor: View {
    @Binding var categoryBinding: EditableCategory
    @Binding var selectedItem: EditableFoodItem?  // 🔼 Comes from parent

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Category Name", text: $categoryBinding.name)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom, 8)

            ForEach(categoryBinding.items) { item in
                Button {
                    selectedItem = item
                } label: {
                    Label(item.name.isEmpty ? "Untitled" : item.name, systemImage: "pencil")
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }

            Button(action: {
                let newItem = EditableFoodItem(
                    name: "",
                    description: nil,
                    price: 0.0,
                    allergens: [],
                    imageURL: nil
                )
                categoryBinding.items.append(newItem)
                selectedItem = newItem
            }) {
                Label("Add Item", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .padding(.top)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}


struct ItemEditorView: View{
    var item: EditableFoodItem
    @Binding var categoryBinding:EditableCategory
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var description: String
    @State private var price: Double = 0.0
    @State private var allergens: [String]
    
    init(item: EditableFoodItem, categoryBinding: Binding<EditableCategory>){
        self.item = item
        self._categoryBinding = categoryBinding
        _name = State(initialValue: item.name)
        _description = State(initialValue: item.description ?? "")
        _price = State(initialValue: item.price)
        _allergens = State(initialValue: item.allergens)
    }
    
    var body: some View {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    TextField("Price", value: $price, format: .number)
                }

                Section(header: Text("Allergens")) {
                    NavigationLink("Edit Allergens") {
                        AllergenPickerView(selectedAllergens: $allergens)
                    }
                    if !allergens.isEmpty {
                        Text("Selected: \(allergens.joined(separator: ", "))")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    Button("Save") {
                        if let index = categoryBinding.items.firstIndex(where: { $0.id == item.id }) {
                            categoryBinding.items[index].name = name
                            categoryBinding.items[index].description = description.isEmpty ? nil : description
                            categoryBinding.items[index].price = price
                            categoryBinding.items[index].allergens = allergens
                        }
                        dismiss()
                    }

                    Button("Delete", role: .destructive) {
                        categoryBinding.items.removeAll { $0.id == item.id }
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Item")
        }
    }

extension MenuBuilderView {
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}
extension Binding where Value == String? {
    init(_ source: Binding<String?>, replacingNilWith nilReplacement: String) {
        self.init(
            get: { source.wrappedValue ?? nilReplacement },
            set: { newValue in source.wrappedValue = newValue!.isEmpty ? nil : newValue }
        )
    }
}
