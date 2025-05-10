import SwiftUI

struct OrderView: View {
    @EnvironmentObject var orderManager: OrderManager
    @State private var isEditing = false
    @State private var itemBeingEdited: OrderItem? = nil
    @State private var editedIngredients: [String] = []

    var totalPrice: Double {
        orderManager.selectedItems.reduce(0) { $0 + $1.menuItem.price * Double($1.quantity) }
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Selected Items")) {
                        ForEach(orderManager.selectedItems, id: \.id) { orderItem in
                            OrderItemRow(
                                orderItem: orderItem,
                                isEditing: isEditing,
                                updateQuantity: updateQuantity,
                                onEditIngredients: {
                                    editedIngredients = orderItem.menuItem.ingredients
                                    itemBeingEdited = orderItem
                                }
                            )
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Your Order")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(isEditing ? "Done" : "Edit") {
                            isEditing.toggle()
                        }
                    }
                }

                HStack {
                    Text("Total:")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "$%.2f", totalPrice))
                        .font(.title3)
                        .bold()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                Button("Process Order") {
                    // Submit order logic
                }
                .padding(.bottom)
            }
        }
        .sheet(item: $itemBeingEdited) { item in
            let allIngredients = item.originalIngredients

            VStack {
                Text("Edit Ingredients: \(item.menuItem.name)")
                    .font(.headline)
                    .padding()

                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(allIngredients, id: \.self) { ingredient in
                            Toggle(isOn: Binding(
                                get: { editedIngredients.contains(ingredient) },
                                set: { isSelected in
                                    if isSelected {
                                        editedIngredients.append(ingredient)
                                    } else {
                                        editedIngredients.removeAll { $0 == ingredient }
                                    }
                                }
                            )) {
                                Text(ingredient)
                            }
                        }
                    }
                    .padding()
                }

                Button("Save") {
                    guard let currentIndex = orderManager.selectedItems.firstIndex(where: { $0.id == item.id }) else {
                        itemBeingEdited = nil
                        return
                    }

                    var updatedItem = orderManager.selectedItems[currentIndex]
                    updatedItem.menuItem.ingredients = editedIngredients

                    // Check for an existing stack with same name + ingredients
                    if let stackIndex = orderManager.selectedItems.firstIndex(where: {
                        $0.id != updatedItem.id &&
                        $0.menuItem.name == updatedItem.menuItem.name &&
                        $0.menuItem.ingredients.sorted() == editedIngredients.sorted()
                    }) {
                        // Stack into existing item
                        orderManager.selectedItems[stackIndex].quantity += updatedItem.quantity
                        orderManager.selectedItems.remove(at: currentIndex)
                    } else {
                        // Replace current with updated if ingredients changed
                        orderManager.selectedItems[currentIndex] = updatedItem
                    }

                    itemBeingEdited = nil
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Cancel") {
                    itemBeingEdited = nil
                }
                .padding(.top, 10)
            }
            .padding()
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        orderManager.selectedItems.remove(atOffsets: offsets)
    }

    private func updateQuantity(for item: OrderItem, to newValue: Int) {
        if newValue == 0 {
            orderManager.selectedItems.removeAll { $0.id == item.id }
        } else if let index = orderManager.selectedItems.firstIndex(where: { $0.id == item.id }) {
            orderManager.selectedItems[index].quantity = newValue
        }
    }
}

struct OrderItemRow: View {
    let orderItem: OrderItem
    let isEditing: Bool
    let updateQuantity: (OrderItem, Int) -> Void
    let onEditIngredients: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            if let imageName = orderItem.menuItem.imageURL {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .cornerRadius(6)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(orderItem.menuItem.name)
                    .font(.headline)

                if !orderItem.menuItem.allergens.isEmpty {
                    Text("Allergens: \(orderItem.menuItem.allergens.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.red)
                }

                Text(String(format: "$%.2f", orderItem.menuItem.price * Double(orderItem.quantity)))
                    .font(.caption)
                    .foregroundColor(.secondary)

                let removed = orderItem.originalIngredients.filter { !orderItem.menuItem.ingredients.contains($0) }
                if !removed.isEmpty {
                    Text("Removed: \(removed.joined(separator: ", "))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                if isEditing {
                    Button("Edit Ingredients") {
                        onEditIngredients()
                    }
                    .font(.caption)
                }
            }

            Spacer()

            if isEditing {
                HStack(spacing: 8) {
                    Stepper("", value: Binding<Int>(
                        get: { orderItem.quantity },
                        set: { newValue in updateQuantity(orderItem, newValue) }
                    ), in: 0...999)
                    Text("x\(orderItem.quantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("x\(orderItem.quantity)")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
