// MenuItem.swift
// AssistiveApp

import Foundation

struct MenuItem: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let description: String?
    let price: Double
    let allergens: [String]
    let imageURL: String?

    let accessibilityInfo: String?
    var ingredients: [String] = []
}
