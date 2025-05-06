import Foundation
import Combine

class MenuViewModel: ObservableObject {
    @Published var menuData: MenuData?
    @Published var selectedCategoryIndex: Int = 0
    @Published var selectedAllergens: [String] = []

    let filterStrategy: AllergenFilterStrategy = DefaultAllergenFilter()

    init() {
        PayloadRouter.shared.onReceiveMenuData = { [weak self] data in
            DispatchQueue.main.async {
                self?.menuData = data
                self?.selectedCategoryIndex = 0 // Reset tab on new menu
            }
        }
    }

    var currentItems: [FoodItem] {
        guard let data = menuData,
              selectedCategoryIndex < data.categories.count else { return [] }

        let items = data.categories[selectedCategoryIndex].items
        return filterStrategy.filter(menuItems: items, allergens: selectedAllergens)
    }
}

let testMenuData = MenuData(
    locationID: "test-location-001",
    locationName: "Prototype Cafe",
    categories: [
        MenuCategory(
            name: "Food",
            items: [
                FoodItem(
                    name: "Avocado Toast",
                    description: "Sourdough with smashed avocado and lemon",
                    price: 6.50,
                    allergens: ["Gluten"],
                    imageURL: nil,
                    accessibilityInfo: nil

                ),
                FoodItem(
                    name: "Vegan Wrap",
                    description: "Chickpeas, spinach, and tahini",
                    price: 7.75,
                    allergens: ["Sesame"],
                    imageURL: nil,
                    accessibilityInfo: nil
                )
            ]
        ),
        MenuCategory(
            name: "Coffee",
            items: [
                FoodItem(
                    name: "Espresso",
                    description: "Strong and small",
                    price: 2.50,
                    allergens: [],
                    imageURL: nil,
                    accessibilityInfo: nil

                ),
                FoodItem(
                    name: "Latte",
                    description: "Espresso with steamed milk",
                    price: 3.75,
                    allergens: ["Dairy"],
                    imageURL: nil,
                    accessibilityInfo: nil

                )
            ]
        ),
        MenuCategory(
            name: "Tea",
            items: [
                FoodItem(
                    name: "Chamomile",
                    description: "Caffeine-free herbal tea",
                    price: 2.25,
                    allergens: [],
                    imageURL: nil,
                    accessibilityInfo: nil

                ),
                FoodItem(
                    name: "Matcha",
                    description: "Green tea powder with water or milk",
                    price: 4.00,
                    allergens: ["Dairy"],
                    imageURL: nil,
                    accessibilityInfo: nil

                )
            ]
        )
    ]
)
