import SwiftUI
import SwiftData

struct CustomerInfoView: View {
    let selectedCustomer: Customer?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                if let customer = selectedCustomer {
                    // Photo
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    
                    // Name
                    Text(customer.name)
                        .font(.title2)
                        .bold()
                    
                    // Mobility Preferences
                    Section(header: Text("Mobility Preferences").font(.headline)) {
                        Text("Avoid Stairs: \(customer.avoidStairs ? "Yes" : "No")")
                        Text("Max Distance: \(customer.maxDistance) meters")
                    }
                    
                    // Allergens
                    Section(header: Text("Allergen Flags").font(.headline)) {
                        if let allergens = customer.allergens, !allergens.isEmpty {
                            ForEach(allergens, id: \.self) { allergen in
                                Text("- \(allergen)")
                                    .foregroundColor(.red)
                            }
                        } else {
                            Text("No allergens specified.")
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    Text("No customer selected.")
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Customer Info")
        }
    }
}

@Model
class Customer: Identifiable {
    var id: UUID = UUID()
    var name: String
    var photoURL: String?
    var allergens: [String]?
    var avoidStairs: Bool
    var maxDistance: Int
    
    init(name: String, photoURL: String? = nil, allergens: [String]? = nil, avoidStairs: Bool = false, maxDistance: Int = 0) {
        self.name = name
        self.photoURL = photoURL
        self.allergens = allergens
        self.avoidStairs = avoidStairs
        self.maxDistance = maxDistance
    }
}

#Preview {
    do {
        let container = try ModelContainer(
            for: Customer.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let customer = Customer(
            name: "John Doe",
            allergens: ["Gluten"],
            avoidStairs: true,
            maxDistance: 10
        )
        container.mainContext.insert(customer)
        return CustomerInfoView(selectedCustomer: customer)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
