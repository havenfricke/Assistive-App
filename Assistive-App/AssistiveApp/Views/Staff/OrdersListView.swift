//
//  OrdersListView.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 4/29/25.
//
import SwiftUI

class OrderManager: ObservableObject {
    @Published var receivedOrders: [Order] = []
    
    init(){
        PayloadRouter.shared.onReceivedOrder = { [weak self] order in
            DispatchQueue.main.async{
                self?.receivedOrders.append(order)
                print("Order received: \(order.items.count) items")
            }
        }
    }
    
    func add(order: Order){
        receivedOrders.append(order)
    }
    
    func remove(order: Order){
        receivedOrders.removeAll{ $0.id == order.id }
    }
}

struct OrdersListView: View {
    @ObservedObject var orderManager: OrderManager
    @State private var selectedOrder: Order?
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(orderManager.receivedOrders){ order in
                    Button{
                        selectedOrder = order
                    } label:{
                        VStack(alignment: .leading){
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
                    for index in indices{
                        let order = orderManager.receivedOrders[index]
                        orderManager.remove(order:order)
                    }
                }
            }
            .navigationTitle("Orders")
            .navigationDestination(item: $selectedOrder){ order in
                OrderDetailView(order:order)
            }
        }.onAppear {
            let testItem = OrderItem(
                menuItem: FoodItem(name: "Test Coffee", description: nil, price: 2.99, allergens: [], imageURL: nil),
                quantity: 1
            )
            let testOrder = Order(items: [testItem])
            
            do {
                let payload = try Payload(type: .order, model: testOrder)
                PayloadRouter.shared.handle(payload: payload)
            } catch {
                print("❌ Error creating test order payload: \(error)")
            }
        }

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
