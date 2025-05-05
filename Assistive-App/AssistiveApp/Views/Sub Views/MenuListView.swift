//
//  MenuListView.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//


import SwiftUI
import SwiftData

struct MenuListView: View {
    @ObservedObject var viewModel: MenuViewModel

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Spacer().frame(height: 20)
                
                // Allergen Filter UI
                Text("Filter by Allergens")
                    .font(.headline)
                    .padding(.horizontal)
                
                if let menuData = viewModel.menuData {
                    Picker("Category", selection: $viewModel.selectedCategoryIndex){
                        ForEach(menuData.categories.indices, id: \.self){index in
                            Text(menuData.categories[index].name).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // Item List
                    List {
                        ForEach(viewModel.currentItems, id: \.name){ item in
                            FoodItemRow(item:item)
                        }
                    }
                } else{
                    Spacer()
                    Text("Waiting for Menu Data ...")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                }
            }
            .padding(.top)
            .navigationTitle("Menu")
        }
    }
}

// MARK: - FoodItemRow for display
struct FoodItemRow: View {
    let item: FoodItem

    var body: some View {
        HStack {
            if let imageName = item.imageURL, let url = URL(string: imageName) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .frame(width: 60, height: 60)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)

                if let description = item.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text(String(format: "$%.2f", item.price))
                    .font(.subheadline)

                if !item.allergens.isEmpty {
                    Text("Contains: \(item.allergens.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    let viewModel = MenuViewModel()

    // Create test menu data
    let testMenuData = MenuData(
        locationID: "test-location-001",
        locationName: "Prototype Cafe",
        categories: [
            MenuCategory(
                name: "Food",
                items: [
                    FoodItem(
                        name: "Avocado Toast",
                        description: "Sourdough with smashed avocado and lemon",
                        price: 6.50,
                        allergens: ["Gluten"],
                        imageURL: nil
                    ),
                    FoodItem(
                        name: "Vegan Wrap",
                        description: "Chickpeas, spinach, and tahini",
                        price: 7.75,
                        allergens: ["Sesame"],
                        imageURL: nil
                    )
                ]
            ),
            MenuCategory(
                name: "Coffee",
                items: [
                    FoodItem(
                        name: "Espresso",
                        description: "Strong and small",
                        price: 2.50,
                        allergens: [],
                        imageURL: nil
                    ),
                    FoodItem(
                        name: "Latte",
                        description: "Espresso with steamed milk",
                        price: 3.75,
                        allergens: ["Dairy"],
                        imageURL: nil
                    )
                ]
            ),
            MenuCategory(
                name: "Tea",
                items: [
                    FoodItem(
                        name: "Chamomile",
                        description: "Caffeine-free herbal tea",
                        price: 2.25,
                        allergens: [],
                        imageURL: nil
                    ),
                    FoodItem(
                        name: "Matcha",
                        description: "Green tea powder with water or milk",
                        price: 4.00,
                        allergens: ["Dairy"],
                        imageURL: nil
                    )
                ]
            )
        ]
    )

    // Simulate PayloadRouter receiving a payload
    let testPayload = try! Payload(type: .menuData, model: testMenuData)
    PayloadRouter.shared.handle(payload: testPayload)

    return MenuListView(viewModel: viewModel)
}

