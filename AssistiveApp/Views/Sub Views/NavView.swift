//
//  NavigationView.swift
//  AssistiveApp
//
//  Created by Lukas Morawietz on 4/23/25.
//
import SwiftUI
import SwiftData

struct NavView: View {
    @State private var isZoomed: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("General Floor Plan")
                    .font(.title)
                Image("FloorPlan")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .onTapGesture {
                        isZoomed = true
                    }
                    .sheet(isPresented: $isZoomed) {
                        ZoomedImageView(imageName: "FloorPlan")
                    }
                Text("Tap the image to zoom in.")
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                NavigationLink(destination: HelpNavigationView()) {
                    Text("Need Help Navigating")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 60) // Größere Höhe
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(color: .gray, radius: 5, x: 0, y: 5) 
                }
                .padding(.horizontal)
                .navigationTitle("Navigation")
            }
        }
        }
    }
    
    struct HelpNavigationView: View {
        var body: some View {
            VStack(spacing: 20) {
                Text("How can we help?")
                    .font(.title2)
                    .padding(.bottom, 20)
                
                Button(action: {
                    // Action for Table
                }) {
                    Label("Show Me Table", systemImage: "chair")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 60) // Größere Höhe
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                        .shadow(color: .gray, radius: 5, x: 0, y: 5)
                }
                
                Button(action: {
                    // Action for Restroom
                }) {
                    Label("Restroom Direction", systemImage: "figure.walk")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 60) // Größere Höhe
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(color: .gray, radius: 5, x: 0, y: 5)
                }
                
                Button(action: {
                    // Action for Condiments
                }) {
                    Label("Help with Condiments", systemImage: "leaf")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 60) // Größere Höhe
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                        .shadow(color: .gray, radius: 5, x: 0, y: 5)
                }
                
                Button(action: {
                    // Action for Fridge
                }) {
                    Label("Help with Fridge", systemImage: "snowflake")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 60) // Größere Höhe
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(color: .gray, radius: 5, x: 0, y: 5)
                }
            }
            .padding()
            .navigationTitle("Help Navigation")
        }
    }
    
    struct ZoomedImageView: View {
        let imageName: String
        
        var body: some View {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
        }
    }
    
    struct NavView_Previews: PreviewProvider {
        static var previews: some View {
            NavView()
        }
    }

    struct NavView_Previews2: PreviewProvider {
        static var previews: some View {
            HelpNavigationView()
        }
    }
        


