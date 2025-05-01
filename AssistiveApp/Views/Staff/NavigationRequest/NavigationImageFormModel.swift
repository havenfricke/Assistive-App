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

@Observable
class NavigationImageFormModel {
    var name: String = ""
    var data: Data?
    var category: LocationCategory
    var sample: NavModel?
    var cameraImage: UIImage?
    
    var image: UIImage {
        if let data, let uiImage = UIImage(data: data) {
            return uiImage
        } else {
            return Constants.placeholder
        }
    }
    
    init(){
        self.name = ""
        self.category = .other
        self.data = nil
        self.sample = nil
        self.cameraImage = nil
    }
    
    init(sample: NavModel) {
        self.sample = sample
        self.name = sample.name
        self.data = sample.data
        self.category = sample.category
    }
    
    @MainActor
    func clearImage() {
        data = nil
    }
    
    var isUpDating: Bool { sample != nil }
    var isDisabled: Bool { name.isEmpty }
}
