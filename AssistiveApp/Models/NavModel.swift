//
// Created for Camera Photos SwiftData
// by  Stewart Lynch on 2024-03-18
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import UIKit
import SwiftData

@Model
class NavModel {
    var name: String
    var category: LocationCategory
    @Attribute(.externalStorage)
    var data: Data?
    @Attribute(.externalStorage)
    var floorPlanData: Data?
    var image: UIImage? {
        if let data {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
    
    init(name: String, data: Data? = nil, category: LocationCategory) {
        self.name = name
        self.data = data
        self.category = category
    }
    
}

extension NavModel {
    
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(
            for: NavModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        

        return container
    }
}

extension NavModel{
    func toDTO() -> NavigationAssetDTO{
        return NavigationAssetDTO(
            name: self.name,
            category: self.category,
            imageData: self.data,
            floorPlanData: self.floorPlanData
        )
    }
}

enum LocationCategory: String, CaseIterable, Identifiable, Codable {
    case restroom
    case table
    case customerStation
    case other
    
    var id: String { rawValue }
    
    var displayName: String{
        switch self {
        case .restroom: return "Restrooms"
        case .table: return "Tables"
        case .customerStation: return "Customer Stations"
        case .other: return "Other"
        }
    }
}

