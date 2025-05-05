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
    var netID: String
    var desc: String

    init(id: UUID = UUID(), netID: String, desc: String) {
        self.id = id
        self.netID = netID
        self.desc = desc
    }
}

