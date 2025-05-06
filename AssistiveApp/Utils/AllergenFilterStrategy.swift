//
//  AllergenFilterStrategy.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//


import Foundation

protocol AllergenFilterStrategy {
    func filter(menuItems: [FoodItem], allergens: [String]) -> [FoodItem]
}

// Default allergen filter: Excludes items that contain any allergen in the user's list.
class DefaultAllergenFilter: AllergenFilterStrategy {
    func filter(menuItems: [FoodItem], allergens: [String]) -> [FoodItem] {
        menuItems.filter { item in
            // If the item has allergens that intersect with the user's allergens, it will be excluded.
            Set(item.allergens).isDisjoint(with: Set(allergens))
        }
    }
}

// A pass-through filter option that does not exclude any items. Useful for toggling the filter off.
class NoFilter: AllergenFilterStrategy {
    func filter(menuItems: [FoodItem], allergens: [String]) -> [FoodItem] {
        return menuItems
    }
}
