//
//  MenuListView.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//


import SwiftUI
import SwiftData

struct MenuListView: View {
    // SwiftData query to fetch MenuItem models.
    @Query private var menuItems: [MenuItem]
    @State private var selectedMenuItem: MenuItem?
    // Added states for allergen filtering
    @State private var selectedAllergens: [String] = []
    @State private var filterStrategy: AllergenFilterStrategy = DefaultAllergenFilter()
    // Hard coded test data
    @State private var localMenuItems: [MenuItem] = [
        MenuItem(name: "Burger", descriptor: "Beef with cheese", price: 9.99, imageName: "burger", allergens: ["Dairy", "Gluten"], accessibilityInfo: "Cut into quarters"),
        MenuItem(name: "Salad", descriptor: "Fresh garden salad", price: 6.49, imageName: "salad", allergens: ["Soy"], accessibilityInfo: "Dressing on side"),
        MenuItem(name: "Fries", descriptor: "Crispy fries", price: 3.99, imageName: "fries", allergens: nil, accessibilityInfo: nil)
    ]

    // Calls localMenuItems instead of menuItems for testing
    var filteredItems: [MenuItem] {
        filterStrategy.filter(menuItems: localMenuItems, allergens: selectedAllergens)
    }


    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Spacer().frame(height: 20)
                Text("Filter by Allergens")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(["Peanuts", "Dairy", "Gluten", "Soy"], id: \.self) { allergen in
                            Button(action: {
                                if selectedAllergens.contains(allergen) {
                                    selectedAllergens.removeAll { $0 == allergen }
                                } else {
                                    selectedAllergens.append(allergen)
                                }
                            }) {
                                Text(allergen)
                                    .padding(8)
                                    .background(selectedAllergens.contains(allergen) ? Color.red : Color.gray.opacity(0.3))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                

                List(selection: $selectedMenuItem) {
                    ForEach(filteredItems) { item in
                        NavigationLink(value: item) {
                            MenuItemRow(item: item)
                        }
                    }
                }
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { WebServiceManager.fetchMenuData() }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

struct MenuItemRow: View {
    let item: MenuItem

    var body: some View {
        HStack {
            if let imageName = item.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .frame(width: 60, height: 60)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)

                if let descriptor = item.descriptor {
                    Text(descriptor)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text(String(format: "$%.2f", item.price))
                    .font(.subheadline)

                if let allergens = item.allergens, !allergens.isEmpty {
                    Text("Contains: \(allergens.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.red)
                }

                if let accessibility = item.accessibilityInfo {
                    Text("Accessibility: \(accessibility)")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

