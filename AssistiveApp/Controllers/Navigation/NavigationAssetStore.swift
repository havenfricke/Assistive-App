//
//  NavigationAssetStore.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 5/1/25.
//

import Foundation
import SwiftUI

@MainActor
class NavigationAssetStore: ObservableObject {
    @Published private(set) var assets: [NavigationAssetDTO] = []
    @Published var floorPlanImage: UIImage? = nil
    
    static let shared = NavigationAssetStore()
    
    init(){}
    func updatedAssets(_ newAssets: [NavigationAssetDTO]){
        self.assets = newAssets
    }
    
    func assets(for category: LocationCategory) -> [NavigationAssetDTO] {
        return assets.filter { $0.category == category}
    }
    func groupedByCategory() -> [LocationCategory: [NavigationAssetDTO]]{
        Dictionary(grouping:assets, by: \.category)
    }
    
    func setFloorPlan(from data: Data?) {
        if let data, let image = UIImage(data: data) {
            self.floorPlanImage = image
            print("✅ Floor plan image updated")
        } else {
            print("⚠️ Invalid floor plan image data")
        }
    }

}
