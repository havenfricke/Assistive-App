//
//  NavigationAssetDTO.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 5/1/25.
//

import Foundation
import SwiftUI

struct NavigationAssetDTO: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let category: LocationCategory
    let imageData: Data?

    init(id: UUID = UUID(), name: String, category: LocationCategory, imageData: Data?) {
        self.id = id
        self.name = name
        self.category = category
        self.imageData = imageData
    }

    static func == (lhs: NavigationAssetDTO, rhs: NavigationAssetDTO) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.category == rhs.category &&
        lhs.imageData == rhs.imageData
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(category)
        hasher.combine(imageData)
    }
}


extension NavigationAssetDTO {
    func toNavModel() -> NavModel{
        return NavModel(name: name, data: imageData, category: category)
    }
}

struct NavigationDataPayload: Codable{
    let assets: [NavigationAssetDTO]
    let floorPlanData: Data?
}
