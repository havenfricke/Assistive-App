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
    var cartTotal: Double {
        displayedItems.reduce(0) { $0 + (Double($1.quantity) * $1.menuItem.price) }
    }
    var displayedItems: [OrderItem] {
        filterAllergens
        ? orderController.processOrder(orderItems: orderManager.selectedItems, withAllergens: profile.allergens)
        : orderManager.selectedItems
    }
    
    var body: some View {
        VStack {
            Toggle("Toggle Allergen Filtering", isOn: $filterAllergens)
                .padding(.horizontal)
            if displayedItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "cart.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("Your order is empty.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Go to the menu to add items to your order.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    Section(header: Text("Selected Items")) {
                        ForEach(displayedItems) { item in
                            OrderItemRow(item:item)
                        }
                        .environmentObject(orderManager)
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Your Order")
            }
            
            Spacer()
            HStack{
                Text("Total:")
                    .font(.headline)
                Spacer()
                Text(String(format: "$%.2f", cartTotal))
                    .font(.headline)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            Button(action: {
                checkOut()
            }){
                Text("Checkout")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom,10)
            }
            .disabled(displayedItems.isEmpty)
            
            if !filteredItems.isEmpty {
                Text("Filtered Items (Allergen-safe):")
                    .font(.headline)
                List(filteredItems) { item in
                    Text(item.menuItem.name)
                }
            }
        }
    }
    func checkOut(){
        let order = Order(items:orderManager.selectedItems)
        
        do{
            let payload = try Payload(type: .order, model:order)
            PeerConnectionManager.shared.send(payload: payload)
        } catch {
            print("failed to encode and send order: \(error)")
        }
    }
    
    struct OrderItemRow: View {
        let item: OrderItem
        @EnvironmentObject var orderManager: OrderManager
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(item.menuItem.name) x\(item.quantity)")
                        .font(.headline)
                    Spacer()
                    Text(itemTotalPriceFormatted)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
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
                }
                
                Text("Original: \(item.menuItem.ingredients.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if !item.menuItem.allergens.isEmpty {
                    Text("Allergens: \(item.menuItem.allergens.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.vertical, 4)
            .swipeActions {
                Button(role: .destructive) {
                    if let index = orderManager.selectedItems.firstIndex(of: item) {
                        orderManager.selectedItems.remove(at: index)
                    }
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            }
        }
        
        var itemTotalPriceFormatted: String {
            let total = Double(item.quantity) * item.menuItem.price
            return String(format: "$%.2f", total)
        }
    }
}
