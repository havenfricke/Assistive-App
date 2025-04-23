//
//  MenuItem 2.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//


import Foundation
import SwiftData

@Model
class MenuItem: Identifiable {
    var id: UUID = UUID()
    var name: String
    var descriptor: String?
    var price: Double
    var imageName: String?   // Name of the image asset
    var allergens: [String]? // List of allergens contained in the menu item
    var accessibilityInfo: String?
    
    init(name: String, descriptor: String? = nil, price: Double, imageName: String? = nil, allergens: [String]? = nil, accessibilityInfo: String? = nil) {
        self.name = name
        self.descriptor = descriptor
        self.price = price
        self.imageName = imageName
        self.allergens = allergens
        self.accessibilityInfo = accessibilityInfo
    }
}
