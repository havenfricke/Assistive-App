//
//  DemoNavData.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 5/7/25.
//

import Foundation
import UIKit

struct DemoNavigationData {
    
    static func chickFilA() -> [NavigationAssetDTO] {
        [
            NavigationAssetDTO(name: "Booth 1", category: .table, imageData: imageData(named: "Table1")),
            NavigationAssetDTO(name: "Booth 2", category: .table, imageData: imageData(named: "Table2")),
            NavigationAssetDTO(name: "Main Restroom", category: .restroom, imageData: imageData(named: "Table3")),
            NavigationAssetDTO(name: "Side Restroom", category: .restroom, imageData: imageData(named: "Table4")),
            NavigationAssetDTO(name: "Condiment Bar", category: .customerStation, imageData: imageData(named: "CondimentBar")),
            NavigationAssetDTO(name: "Drink Refill", category: .customerStation, imageData: imageData(named: "Fridge")),
            NavigationAssetDTO(name: "cfa_floorplan", category: .other, imageData: imageData(named: "cfa_floorplan"))
        ]
    }

    static func cafe32() -> [NavigationAssetDTO] {
        [
            NavigationAssetDTO(name: "Corner Table", category: .table, imageData: imageData(named: "Table5")),
            NavigationAssetDTO(name: "Window Table", category: .table, imageData: imageData(named: "Table6")),
            NavigationAssetDTO(name: "Restroom A", category: .restroom, imageData: imageData(named: "Table7")),
            NavigationAssetDTO(name: "Restroom B", category: .restroom, imageData: imageData(named: "Table8")),
            NavigationAssetDTO(name: "Sugar Station", category: .customerStation, imageData: imageData(named: "Table9")),
            NavigationAssetDTO(name: "Fridge Grab-N-Go", category: .customerStation, imageData: imageData(named: "Table10")),
            NavigationAssetDTO(name: "c32_floorplan", category: .other, imageData: imageData(named: "c32_floorplan"))

        ]
    }

    private static func imageData(named name: String) -> Data? {
        guard let image = UIImage(named: name) else {
            print("⚠️ Missing image asset: \(name)")
            return nil
        }
        return image.jpegData(compressionQuality: 0.85)
    }
}
