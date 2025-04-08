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

    var body: some View {
        NavigationView {
            List(selection: $selectedMenuItem) {
                ForEach(menuItems) { item in
                    NavigationLink(value: item) {
                        MenuItemRow(item: item)
                    }
                }
            }
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
            Image(systemName: "photo")  // Replace with actual image asset via `item.imageName` if available.
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                if let allergens = item.allergens, !allergens.isEmpty {
                    Text("Contains: \(allergens.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(4)
    }
}
