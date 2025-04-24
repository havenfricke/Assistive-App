//
//  OrderView.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//


import SwiftUI

struct OrderView: View {
    // In a real scenario, selected items might be populated from user selections in the menu.
    @State private var selectedItems: [FoodItem] = []
    @State private var userAllergens: [String] = []  // e.g., populated via Settings or user input
    @State private var filteredItems: [FoodItem] = []
    
    // Controller that applies a default allergen filter.
    let orderController = OrderController(filter: DefaultAllergenFilter())
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Selected Items")) {
                        ForEach(filteredItems) { item in
                            Text(item.name)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Your Order")
                
                Button("Process Order") {
                    filteredItems = orderController.processOrder(menuItems: selectedItems, withAllergens: userAllergens)
                }
                .padding()
                
                if !filteredItems.isEmpty {
                    Text("Filtered Items (Allergen-safe):")
                        .font(.headline)
                    List(filteredItems) { item in
                        Text(item.name)
                    }
                }
            }
        }
    }
}
