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
    func processOrder(orderItems: [OrderItem], withAllergens allergens: [String]) -> [OrderItem] {
        let filteredItems = orderItems.filter { orderItem in
            Set(orderItem.menuItem.allergens).isDisjoint(with: Set(allergens))
        }
        print(allergens)
        // Additional processing (e.g., integration with a POS system, network calls) can be added here.
        print(filteredItems)
        return filteredItems
    }
}
