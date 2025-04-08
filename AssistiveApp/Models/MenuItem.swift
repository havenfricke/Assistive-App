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
    var imageName: String?   // Name of the image asset
    var allergens: [String]? // List of allergens contained in the menu item
    
    init(name: String, descriptor: String? = nil, imageName: String? = nil, allergens: [String]? = nil) {
        self.name = name
        self.descriptor = descriptor
        self.imageName = imageName
        self.allergens = allergens
    }
}
