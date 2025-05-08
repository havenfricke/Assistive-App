//
//  OrdersListView.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 4/29/25.
//
import SwiftUI

class OrderManager: ObservableObject {
    @Published var selectedItems: [OrderItem] = []
    @Published var receivedOrders: [Order] = []
    
    init(){
        PayloadRouter.shared.onReceivedOrder = { [weak self] order in
            DispatchQueue.main.async {
                self?.receivedOrders.append(order)
                print("Order received with \(order.items.count) items")
            }
        }
    }

    func addOrStack(_ customItem: OrderItem, quantity: Int) {
        if let index = selectedItems.firstIndex(where: {
            $0.menuItem.name == customItem.menuItem.name &&
            $0.selectedIngredients.sorted() == customItem.menuItem.ingredients.sorted()
        }) {
            selectedItems[index].quantity += quantity
        } else {
            let newOrderItem = OrderItem(
                menuItem: customItem.menuItem,
                quantity: quantity,
                selectedIngredients: customItem.selectedIngredients
            )
            selectedItems.append(newOrderItem)
        }
    }
}


struct OrdersListView: View {
    @ObservedObject var orderManager: OrderManager
    @State private var selectedOrder: Order?
    
    var body: some View {
        Group {
            if orderManager.receivedOrders.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "cart")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No orders received.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(orderManager.receivedOrders) { order in
                        Button {
                            selectedOrder = order
                        } label: {
                            VStack(alignment: .leading) {
                                Text("Order at \(order.timestamp.formatted(date: .omitted, time: .shortened))")
                                    .font(.headline)
                                Text("\(order.items.count) items")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .onDelete { indices in
                        for index in indices {
                            orderManager.receivedOrders.remove(at: index)
                        }
                    }
                }
                .navigationDestination(item: $selectedOrder) { order in
                    OrderDetailView(order: order)
                }
            }
        }
        .navigationTitle("Orders")
    }

}

struct OrderDetailView: View{
    let order: Order
    
    var body: some View{
        List{
            ForEach(order.items){ item in
                VStack(alignment: .leading){
                    Text(item.menuItem.name)
                        .font(.headline)
                    Text("Quantity: \(item.quantity)")
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Order Details")
    }
}

    
#Preview {
    OrdersListView(orderManager: OrderManager())
}
