//
//  AllergenPickerView.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 4/21/25.
//

import SwiftUI

struct AllergenPickerView: View{
    @Binding var selectedAllergens: [String]
    @Environment(\.dismiss) private var dismiss
    
    private let commonAllergens = [
        "Milk", "Eggs", "Peanuts", "Tree Nuts",
        "Wheat", "Soy", "Fish", "Shellfish", "Sesame"
    ]
    
    @State private var commonToggles: [String:Bool] = [:]
    @State private var customAllergens: [String] = []
    @State private var newAllergen: String = ""
    
    var body: some View {
        Form{
            //MARK: - Common Allergens
            Section(header: Text("Custom Allergens")){
                ForEach(commonAllergens, id: \.self){ allergen in
                    Toggle(allergen, isOn: Binding(
                        get: { commonToggles[allergen] ?? false},
                        set: { commonToggles[allergen] = $0 }
                    ))
                }
            }
            
            //MARK: - Custom Allergens
            Section(header: Text("Other Allergens")){
                ForEach(customAllergens, id: \.self) {allergen in
                    HStack{
                        Text(allergen)
                        Spacer()
                        Button(role: .destructive){
                            customAllergens.removeAll{ $0 == allergen }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                HStack{
                    TextField("Add custom allergen", text: $newAllergen)
                    Button("Add"){
                        let trimmed = newAllergen.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty && !customAllergens.contains(trimmed) else { return }
                        customAllergens.append(trimmed)
                        newAllergen = ""
                    }
                }
                //MARK: - Disclaimer
                Section{
                    Text("⚠️ Custom allergens are human validated. Please double-check spelling and accuracy")
                        .font(.footnote)
                        .foregroundColor(.orange)
                }
                //MARK: - Save
                Section {
                    Button("Save Allergens"){
                        selectedAllergens = selectedCommonAllergens() + customAllergens
                        dismiss()
                    }
                }
            }
            .navigationTitle("Select Allergens")
            .onAppear(perform: syncInitialState)
        }
    }
    //MARK: -   HELPERS
    private func selectedCommonAllergens() -> [String] {
        commonToggles.filter {$0.value}.map {$0.key}
    }
    private func syncInitialState() {
        // Initialize toggle states from the binding
        for allergen in commonAllergens {
            commonToggles[allergen] = selectedAllergens.contains(allergen)
        }
        // Filter out any initial values that aren't in standard list
        customAllergens = selectedAllergens.filter { !commonAllergens.contains($0) }
    }
}



