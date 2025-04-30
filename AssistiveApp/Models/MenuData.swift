//
//  MenuData.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 4/22/25.
//

import Foundation

struct MenuData: Codable {
    let locationID: String
    let locationName: String
    let categories: [MenuCategory]
}

struct MenuCategory: Codable {
    let name: String
    let items: [FoodItem]
}

struct FoodItem: Codable, Identifiable, Equatable, Hashable {
    var id: String {name}
    let name: String
    let description: String?
    let price: Double
    let allergens: [String]
    let imageURL: String?
}
