//
//  DemoMenuData.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 5/7/25.
//

import Foundation
struct DemoMenuData {
    static func chickFilA() -> MenuData {
        MenuData(
            locationID: "aaCFA",
            locationName: "Chick-fil-A",
            categories: [
                MenuCategory(name: "Entrées", items: [
                    FoodItem(
                        name: "Chicken Sandwich",
                        description: "Classic CFA sandwich with pickles.",
                        price: 4.99,
                        allergens: ["Wheat"],
                        imageURL: "cfa_chicken_sandwich",
                        accessibilityInfo: "Contains wheat. Served hot.",
                        ingredients: ["chicken breast", "bun", "pickles"]
                    ),
                    FoodItem(
                        name: "Spicy Deluxe Sandwich",
                        description: "Spicy chicken with lettuce, tomato, and cheese.",
                        price: 5.49,
                        allergens: ["Wheat", "Milk"],
                        imageURL: "cfa_spicy_deluxe",
                        accessibilityInfo: "Contains milk and wheat. May be spicy.",
                        ingredients: ["spicy chicken", "bun", "lettuce", "tomato", "cheese"]
                    )
                ]),
                MenuCategory(name: "Sides", items: [
                    FoodItem(
                        name: "Waffle Fries",
                        description: "Crispy waffle-cut potatoes.",
                        price: 2.19,
                        allergens: [],
                        imageURL: "cfa_waffle_fries",
                        accessibilityInfo: "No common allergens.",
                        ingredients: ["potatoes", "canola oil", "salt"]
                    ),
                    FoodItem(
                        name: "Fruit Cup",
                        description: "Seasonal fresh fruit.",
                        price: 2.89,
                        allergens: [],
                        imageURL: "cfa_fruit_cup",
                        accessibilityInfo: "Gluten-free, dairy-free.",
                        ingredients: ["apples", "grapes", "mandarin oranges"]
                    )
                ])
            ]
        )
    }
    static func cafe32() -> MenuData {
        MenuData(
            locationID: "aaC32",
            locationName: "Café 32",
            categories: [
                MenuCategory(name: "Breakfast", items: [
                    FoodItem(
                        name: "Avocado Toast",
                        description: "Sourdough with avocado and chili flakes.",
                        price: 6.50,
                        allergens: ["Wheat"],
                        imageURL: "cafe_avocado_toast",
                        accessibilityInfo: "Vegetarian. Contains wheat.",
                        ingredients: ["bread", "avocado", "chili flakes"]
                    ),
                    FoodItem(
                        name: "Greek Yogurt Parfait",
                        description: "Yogurt with granola and berries.",
                        price: 4.75,
                        allergens: ["Milk", "Wheat"],
                        imageURL: "cafe_yogurt_parfait",
                        accessibilityInfo: "Contains milk. Granola may contain wheat.",
                        ingredients: ["yogurt", "berries", "granola"]
                    )
                ]),
                MenuCategory(name: "Coffee & Tea", items: [
                    FoodItem(
                        name: "Latte",
                        description: "Espresso with steamed milk.",
                        price: 3.95,
                        allergens: ["Milk"],
                        imageURL: "cafe_latte",
                        accessibilityInfo: "Contains milk.",
                        ingredients: ["espresso", "milk"]
                    ),
                    FoodItem(
                        name: "Iced Green Tea",
                        description: "Light, unsweetened green tea.",
                        price: 2.95,
                        allergens: [],
                        imageURL: "cafe_iced_tea",
                        accessibilityInfo: "No common allergens.",
                        ingredients: ["green tea", "ice"]
                    )
                ])
            ]
        )
        
    }
}
