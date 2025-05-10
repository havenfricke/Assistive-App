import SwiftUI
import SwiftData

struct MenuListView: View {
    @State private var selectedMenuItem: MenuItem?
    @State private var selectedAllergens: [String] = []
    @State private var filterStrategy: AllergenFilterStrategy = DefaultAllergenFilter()

    @State private var menuItems: [MenuItem] = [
        MenuItem(name: "Burger", description: "Beef with cheese", price: 9.99,
                 allergens: ["Dairy", "Gluten"], imageURL: "burger", accessibilityInfo: "Cut into quarters",
                 ingredients: ["Bun", "Beef Patty", "Cheese", "Lettuce", "Tomato"]),
        MenuItem(name: "Salad", description: "Fresh garden salad", price: 6.49,
                 allergens: ["Soy"], imageURL: "salad", accessibilityInfo: "Dressing on side",
                 ingredients: ["Lettuce", "Tomato", "Cucumber", "Soy Dressing"]),
        MenuItem(name: "Fries", description: "Crispy fries", price: 3.99,
                 allergens: [], imageURL: "fries", accessibilityInfo: nil,
                 ingredients: ["Salt"])
    ]

    @State private var showAddToOrderPopup = false
    @State private var quantity = 1
    @State private var itemToAdd: MenuItem? = nil
    @State private var selectedIngredients: [String] = []

    @EnvironmentObject var orderManager: OrderManager

    var filteredItems: [MenuItem] {
        filterStrategy.filter(menuItems: menuItems, allergens: selectedAllergens)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Spacer().frame(height: 20)

                Text("Filter by Allergens")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(["Peanuts", "Dairy", "Gluten", "Soy"], id: \.self) { allergen in
                            Button(action: {
                                if selectedAllergens.contains(allergen) {
                                    selectedAllergens.removeAll { $0 == allergen }
                                } else {
                                    selectedAllergens.append(allergen)
                                }
                            }) {
                                Text(allergen)
                                    .padding(8)
                                    .background(selectedAllergens.contains(allergen) ? Color.red : Color.gray.opacity(0.3))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                List {
                    ForEach(filteredItems, id: \.name) { item in
                        Button {
                            itemToAdd = item
                            quantity = 1
                            selectedIngredients = item.ingredients
                        } label: {
                            MenuItemRow(item: item)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                Spacer()
            }
            .padding(.top)
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { WebServiceManager.fetchMenuData() }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
        .sheet(item: $itemToAdd) { item in
            VStack(spacing: 20) {
                if let image = item.imageURL {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(12)
                        .padding(.top)
                }

                Text("Add \(item.name)")
                    .font(.title2)

                Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
                    .padding()

                Text("Edit Ingredients")
                    .font(.headline)
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(item.ingredients, id: \.self) { ingredient in
                            Toggle(isOn: Binding(
                                get: { selectedIngredients.contains(ingredient) },
                                set: { isSelected in
                                    if isSelected {
                                        selectedIngredients.append(ingredient)
                                    } else {
                                        selectedIngredients.removeAll { $0 == ingredient }
                                    }
                                }
                            )) {
                                Text(ingredient)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Button("Add to Order") {
                    var customItem = item
                    customItem.ingredients = selectedIngredients

                    // Look for an existing order with the same item name + ingredients
                    if let index = orderManager.selectedItems.firstIndex(where: {
                        $0.menuItem.name == customItem.name &&
                        $0.menuItem.ingredients.sorted() == customItem.ingredients.sorted()
                    }) {
                        // Stack: increase quantity
                        orderManager.selectedItems[index].quantity += quantity
                    } else {
                        // Add new stack
                        let newOrderItem = OrderItem(
                            menuItem: customItem,
                            quantity: quantity,
                            originalIngredients: item.ingredients
                        )
                        orderManager.selectedItems.append(newOrderItem)
                    }

                    itemToAdd = nil
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Cancel") {
                    itemToAdd = nil
                }
                .padding(.top, 10)
            }
            .padding()
        }
    }
}

struct MenuItemRow: View {
    let item: MenuItem

    var body: some View {
        HStack {
            if let imageURL = item.imageURL {
                Image(imageURL)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .frame(width: 60, height: 60)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)

                if let description = item.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text(String(format: "$%.2f", item.price))
                    .font(.subheadline)

                if !item.allergens.isEmpty {
                    Text("Contains: \(item.allergens.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.red)
                }

                if let accessibility = item.accessibilityInfo {
                    Text("Accessibility: \(accessibility)")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
