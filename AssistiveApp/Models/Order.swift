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
    var menuItem: FoodItem
    var quantity: Int
}

@Model
class Order: Identifiable,Codable {
    var id: UUID = UUID()
    var items: [OrderItem]
    var timestamp: Date

    init(items: [OrderItem], timestamp: Date = Date()) {
        self.items = items
        self.timestamp = timestamp
    }
    enum CodingKeys: String, CodingKey {
            case id, items, timestamp
        }

        required convenience init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let id = try container.decode(UUID.self, forKey: .id)
            let items = try container.decode([OrderItem].self, forKey: .items)
            let timestamp = try container.decode(Date.self, forKey: .timestamp)

            self.init(items: items, timestamp: timestamp)
            self.id = id
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(items, forKey: .items)
            try container.encode(timestamp, forKey: .timestamp)
        }
}
