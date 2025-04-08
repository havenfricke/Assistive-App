//
//  Location.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//

import Foundation
import SwiftData

@Model
class Location: Identifiable {
    var id: UUID = UUID()
    var name: String
    var timestamp: Date
    
    init(name: String, timestamp: Date = Date()) {
        self.name = name
        self.timestamp = timestamp
    }
}
