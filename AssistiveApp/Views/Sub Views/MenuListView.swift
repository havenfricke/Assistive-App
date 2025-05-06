import SwiftUI
import SwiftData

// MARK: - MenuListView

struct MenuListView: View {
    // MARK: State
    @EnvironmentObject var orderManager: OrderManager
    @State private var selectedMenuItem: FoodItem?
    @State private var selectedAllergens: [String] = []
    @State private var filterStrategy: AllergenFilterStrategy = DefaultAllergenFilter()
    
    @State private var menuItems: [FoodItem] = [
        FoodItem(name: "Burger", description: "Beef with cheese", price: 9.99,
                 allergens: ["Dairy", "Gluten"], imageURL: "burger", accessibilityInfo: "Cut into quarters",
                 ingredients: ["Bun", "Beef Patty", "Cheese", "Lettuce", "Tomato"]),
        FoodItem(name: "Salad", description: "Fresh garden salad", price: 6.49,
                 allergens: ["Soy"], imageURL: "salad", accessibilityInfo: "Dressing on side",
                 ingredients: ["Lettuce", "Tomato", "Cucumber", "Soy Dressing"]),
        FoodItem(name: "Fries", description: "Crispy fries", price: 3.99,
                 allergens: [], imageURL: "fries", accessibilityInfo: nil,
                 ingredients: ["Salt"])
    ]
    
    @State private var showAddToOrderPopup = false
    @State private var quantity = 1
    @State private var itemToAdd: FoodItem? = nil
    @State private var selectedIngredients: [String] = []
    
    // MARK: - Filtering
    var filteredItems: [FoodItem] {
        filterStrategy.filter(menuItems: menuItems, allergens: selectedAllergens)
    }
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Spacer().frame(height: 20)
                
                allergenFilterHeader
                
                allergenChips
                
                menuList
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Menu")
        }
        .sheet(item: $itemToAdd) { item in
            FoodItemDetailSheet(
                item: item,
                quantity: $quantity,
                selectedIngredients: $selectedIngredients,
                onAdd: { customItem in
                    orderManager.addOrStack(customItem, quantity:quantity)
                    itemToAdd = nil
                },
                onCancel: {
                    itemToAdd = nil
                }
            )
        }
    }

    // MARK: - Subviews

    private var allergenFilterHeader: some View {
        Text("Filter by Allergens")
            .font(.headline)
            .padding(.horizontal)
    }

    private var allergenChips: some View {
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
    }

    private var menuList: some View {
        List {
            ForEach(filteredItems, id: \.name) { item in
                Button {
                    itemToAdd = item
                    quantity = 1
                    selectedIngredients = item.ingredients
                } label: {
                    FoodItemRow(item: item)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct FoodItemRow: View {
    let item: FoodItem

    private var imageView: some View {
        if let imageURL = item.imageURL {
            return AnyView(
                Image(imageURL)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            )
        } else {
            return AnyView(
                Image(systemName: "photo")
                    .frame(width: 60, height: 60)
            )
        }
    }

    var body: some View {
        HStack {
            imageView
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
            .padding(.vertical, 6)
        }
    }
}

struct FoodItemDetailSheet: View {
    let item: FoodItem
    @Binding var quantity: Int
    @Binding var selectedIngredients: [String]
    var onAdd: (FoodItem) -> Void
    var onCancel: () -> Void    
    var body: some View {
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
                onAdd(customItem)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("Cancel") {
                onCancel()
            }
            .padding(.top, 10)
        }
        .padding()
    }
}
