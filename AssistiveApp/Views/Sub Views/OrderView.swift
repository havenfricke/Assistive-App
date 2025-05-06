//
//  OrderView.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//


import SwiftUI

struct OrderView: View {
    // In a real scenario, selected items might be populated from user selections in the menu.
    @EnvironmentObject var orderManager:OrderManager
    @State private var userAllergens: [String] = []  // e.g., populated via Settings or user input
    @State private var filteredItems: [OrderItem] = []
    
    // Controller that applies a default allergen filter.
    let orderController = OrderController(filter: DefaultAllergenFilter())
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Selected Items")) {
                        ForEach(orderManager.selectedItems) { item in
                            Text(item.menuItem.name)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Your Order")
                
                Button("Process Order") {
                    filteredItems = orderController.processOrder(orderItems: orderManager.selectedItems, withAllergens: userAllergens)
                }
                .padding()
                
                if !filteredItems.isEmpty {
                    Text("Filtered Items (Allergen-safe):")
                        .font(.headline)
                    List(filteredItems) { item in
                        Text(item.menuItem.name)
                    }
                }
            }
        }
    }
}
