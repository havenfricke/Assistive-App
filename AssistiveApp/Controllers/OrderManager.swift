import Foundation
import SwiftUI

class OrderManager: ObservableObject {
    @Published var selectedItems: [OrderItem] = []
}
