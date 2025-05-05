//
//  OrderController.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//

import Foundation

class OrderController {
    var allergenFilter: AllergenFilterStrategy
    
    init(filter: AllergenFilterStrategy) {
        self.allergenFilter = filter
    }
    
    /// Processes the order by filtering menu items based on user allergens.
    func processOrder(menuItems: [FoodItem], withAllergens allergens: [String]) -> [FoodItem] {
        let filteredItems = allergenFilter.filter(foodItems: menuItems, allergens: allergens)
        // Additional processing (e.g., integration with a POS system, network calls) can be added here.
        return filteredItems
    }
}
