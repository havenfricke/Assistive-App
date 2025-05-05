//
//  NavigationAssetStore.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 5/1/25.
//

import Foundation

@MainActor
class NavigationAssetStore: ObservableObject {
    @Published private(set) var assets: [NavigationAssetDTO] = []
    
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
    
    
}
