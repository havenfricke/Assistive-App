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
class SampleModel {
    var name: String
    @Attribute(.externalStorage)
    var data: Data?
    var image: UIImage? {
        if let data {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
    
    init(name: String, data: Data? = nil) {
        self.name = name
        self.data = data
    }
}

extension SampleModel {
    
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(
            for: SampleModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        var samples: [SampleModel] {
            [
                    .init(name: "General Floorplan", data: UIImage(named: "FloorPlan")?.pngData()),
                    .init(name: "Restrooms", data: UIImage(named: "Restrooms")?.pngData()),
                    .init(name: "Table1", data: UIImage(named: "Table1")?.pngData()),
                    .init(name: "Table2", data: UIImage(named: "Table2")?.pngData()),
                    .init(name: "Table3", data: UIImage(named: "Table3")?.pngData()),
                    .init(name: "Table4", data: UIImage(named: "Table4")?.pngData()),
                    .init(name: "Table5", data: UIImage(named: "Table5")?.pngData()),
                    .init(name: "Table6", data: UIImage(named: "Table6")?.pngData()),
                    .init(name: "Table7", data: UIImage(named: "Table7")?.pngData()),
                    .init(name: "Table8", data: UIImage(named: "Table8")?.pngData()),
                    .init(name: "Table9", data: UIImage(named: "Table9")?.pngData()),
                    .init(name: "Table10", data: UIImage(named: "Table10")?.pngData()),
                        
            ]
        }
        samples.forEach {
            container.mainContext.insert($0)
        }
        return container
    }
}
