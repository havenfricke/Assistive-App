//
//  Order.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//

import Foundation
import SwiftData

@Model
class Order: Identifiable {
    var id: UUID = UUID()
    var items: [MenuItem]
    var timestamp: Date
    
    init(items: [MenuItem], timestamp: Date = Date()) {
        self.items = items
        self.timestamp = timestamp
    }
}
