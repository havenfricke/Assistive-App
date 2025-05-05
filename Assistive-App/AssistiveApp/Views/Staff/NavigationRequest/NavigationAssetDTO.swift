//
//  NavigationAssetDTO.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 5/1/25.
//

import Foundation

struct NavigationAssetDTO: Codable, Identifiable{
    let id: UUID
    let name: String
    let category: LocationCategory
    let imageData: Data?
    
    init(id: UUID = UUID(), name: String, category: LocationCategory, imageData: Data?){
        self.id = id
        self.name = name
        self.category = category
        self.imageData = imageData
    }
}

extension NavigationAssetDTO {
    func toNavModel() -> NavModel{
        return NavModel(name: name, data: imageData, category: category)
    }
}

struct NavigationDataPayload: Codable{
    let assets: [NavigationAssetDTO]
}
