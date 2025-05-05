//
//  Item.swift
//  AssistiveApp
//
//  Created by Haven F on 5/2/25.
//


import Foundation
import SwiftData

@Model
class AccessPoint: Identifiable {
    var id: UUID
    var timestamp: Date
    var scannedValue: String?

    init(id: UUID = UUID(), timestamp: Date, scannedValue: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.scannedValue = scannedValue
    }
}
