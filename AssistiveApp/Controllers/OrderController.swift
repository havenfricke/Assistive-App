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
    func processOrder(menuItems: [MenuItem], withAllergens allergens: [String]) -> [MenuItem] {
        let filteredItems = allergenFilter.filter(menuItems: menuItems, allergens: allergens)
        // Additional processing (e.g., integration with a POS system, network calls) can be added here.
        return filteredItems
    }
}
