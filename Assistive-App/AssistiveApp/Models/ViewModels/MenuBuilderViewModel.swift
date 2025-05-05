import Foundation
import SwiftUI

class MenuBuilderViewModel: ObservableObject {
    @Published var locationID: String
    @Published var locationName: String
    @Published var categories: [EditableCategory]

    // MARK: - Initializer
    init(previewData: Bool = false) {
        if previewData {
            self.locationID = "PREVIEW-ID"
            self.locationName = "Preview Cafe"
            self.categories = [
                EditableCategory(name: "Entrees", items: [
                    EditableFoodItem(name: "Sample Burger", description: "Tasty!", price: 9.99, allergens: ["Gluten", "Dairy"], imageURL: nil)
                ]),
                EditableCategory(name: "Drinks", items: [
                    EditableFoodItem(name: "Iced Coffee", description: "Chilled and smooth.", price: 3.5, allergens: [], imageURL: nil)
                ])
            ]
        } else {
            self.locationID = UUID().uuidString
            self.locationName = ""
            self.categories = []
        }
    }

    // MARK: - Public Methods
    func addCategory() {
        categories.append(EditableCategory(name: "", items: []))
    }

    func removeCategory(at index: Int) {
        categories.remove(at: index)
    }

    func buildMenuData() -> MenuData? {
        guard !locationName.isEmpty else { return nil }

        let menuCategories = categories.map { cat in
            MenuCategory(name: cat.name, items: cat.items.map {
                FoodItem(
                    name: $0.name,
                    description: $0.description,
                    price: $0.price,
                    allergens: $0.allergens,
                    imageURL: $0.imageURL
                )
            }
        )
    }
        return MenuData(locationID: locationID, locationName: locationName, categories: menuCategories)
    }
}

struct EditableCategory: Identifiable {
    let id = UUID()
    var name: String
    var items: [EditableFoodItem]
}

struct EditableFoodItem: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var description: String?
    var price: Double
    var allergens: [String]
    var imageURL: String?
}
