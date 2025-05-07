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
    @State private var filteredItems: [OrderItem] = []
    @State private var filterAllergens = false
    
    let profile: MobilityProfile
    // Controller that applies a default allergen filter.
    let orderController = OrderController(filter: DefaultAllergenFilter())
    
    var displayedItems: [OrderItem] {
        filterAllergens
        ? orderController.processOrder(orderItems: orderManager.selectedItems, withAllergens: profile.allergens)
        : orderManager.selectedItems
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Toggle("Toggle Allergen Filtering", isOn: $filterAllergens)
                    .padding(.horizontal)
                List {
                    Section(header: Text("Selected Items")) {
                        ForEach(displayedItems) { item in
                            OrderItemRow(item:item)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Your Order")
            
                
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
    
    struct OrderItemRow: View {
        let item: OrderItem
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                // Item name and quantity
                Text("\(item.menuItem.name) x\(item.quantity)")
                    .font(.headline)
                
                let removed = item.menuItem.ingredients.filter { !item.selectedIngredients.contains($0) }
                if !removed.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(removed, id: \.self) { ingredient in
                            HStack(spacing: 4) {
                                Text("❌")
                                Text(ingredient)
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                        }
                    }
                    // Show original ingredients if different
                    Text("Original: \(item.menuItem.ingredients.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // Show allergens if any
                    if !item.menuItem.allergens.isEmpty {
                        Text("Allergens: \(item.menuItem.allergens.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}
