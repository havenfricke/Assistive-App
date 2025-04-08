//
//  HomeView.swift
//  AssistiveApp
//
//  Created by Haven F on 4/7/25.
//


import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to Assistive")
                    .font(.largeTitle)
                    .bold()
                Text("Navigate, scan & order with ease.")
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}
