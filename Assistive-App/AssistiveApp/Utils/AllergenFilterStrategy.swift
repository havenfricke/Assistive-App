//
//  AllergenFilterStrategy.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//


import Foundation

protocol AllergenFilterStrategy {
    func filter(foodItems: [FoodItem], allergens: [String]) -> [FoodItem]
}

// Default allergen filter: Excludes items that contain any allergen in the user's list.
class DefaultAllergenFilter: AllergenFilterStrategy {
    func filter(foodItems: [FoodItem], allergens: [String]) -> [FoodItem] {
        guard !allergens.isEmpty else { return foodItems }
        
        return foodItems.filter { item in
            item.allergens.allSatisfy { !allergens.contains($0)}
        }
    }
}

// A pass-through filter option that does not exclude any items. Useful for toggling the filter off.
class NoFilter: AllergenFilterStrategy {
    func filter(foodItems: [FoodItem], allergens: [String]) -> [FoodItem] {
        return foodItems
    }
}
