import SwiftUI
import SwiftData

// MARK: - MenuListView

struct MenuListView: View {
    // MARK: State
    @EnvironmentObject var locationDataManager: LocationDataManager
    @EnvironmentObject var orderManager: OrderManager

    @State private var selectedMenuItem: FoodItem?
    @State private var selectedAllergens: [String] = []
    @State private var filterStrategy: AllergenFilterStrategy = DefaultAllergenFilter()
    @State private var originalIngredients: [String] = []
    let profile: MobilityProfile
    @State private var menuCategories: [MenuCategory] = []
    
    @State private var showAddToOrderPopup = false
    @State private var quantity = 1
    @State private var itemToAdd: FoodItem? = nil
    @State private var selectedIngredients: [String] = []
    
    // MARK: - Filtering
    var filteredCategories: [MenuCategory] {
        menuCategories.map { category in
            let filtered = filterStrategy.filter(menuItems: category.items, allergens: selectedAllergens)
            return MenuCategory(name: category.name, items: filtered)
        }
        .filter { !$0.items.isEmpty }
    }
    private let commonAllergens = [
        "Milk", "Eggs", "Peanuts", "Tree Nuts",
        "Wheat", "Soy", "Fish", "Shellfish", "Sesame"
    ]
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
            .onReceive(locationDataManager.$menuData.compactMap { $0 }) {newMenu in
                menuCategories = newMenu.categories
            }
        }
        .sheet(item: $itemToAdd) { item in
            FoodItemDetailSheet(
                item: item,
                quantity: $quantity,
                selectedIngredients: $selectedIngredients,
                originalIngredients: originalIngredients,
                onAdd: { customItem in
                    let orderItem = OrderItem(
                        menuItem:customItem,
                        quantity: quantity,
                        selectedIngredients: selectedIngredients
                    )
                    orderManager.addOrStack(orderItem, quantity: quantity)
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
                ForEach(commonAllergens, id: \.self) { allergen in
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
            ForEach(filteredCategories, id: \.name) { category in
                Section(header: Text(category.name)) {
                    ForEach(category.items, id: \.name) { item in
                        Button {
                            itemToAdd = item
                            quantity = 1
                            originalIngredients = item.ingredients
                            selectedIngredients = item.ingredients
                        } label: {
                            FoodItemRow(item: item)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
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
        let originalIngredients: [String]
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
    
}


