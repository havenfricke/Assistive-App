//
//  Order.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//

import Foundation
import SwiftData

struct OrderItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var menuItem: MenuItem
    var quantity: Int
    
    var originalIngredients: [String]
}

@Model
class Order: Identifiable {
    var id: UUID = UUID()
    var items: [OrderItem]
    var timestamp: Date
    
    init(items: [OrderItem], timestamp: Date = Date()) {
        self.items = items
        self.timestamp = timestamp
    }
}
