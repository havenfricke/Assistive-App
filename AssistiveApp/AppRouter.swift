import SwiftUI
import SwiftData

struct AppRouterView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [MobilityProfile]
    @State private var selectedMode: UserMode? = nil
    @State private var profile: MobilityProfile? = nil

    var body: some View {
        contentView
            .onAppear {
                // Ensure only one profile exists
                if profile == nil {
                    if let existing = profiles.first {
                        profile = existing
                    } else {
                        let newProfile = MobilityProfile()
                        context.insert(newProfile)
                        profile = newProfile
                    }
                }
            }
    }

    @ViewBuilder
    private var contentView: some View {
        if let mode = selectedMode {
            switch mode {
            case .staff:
                StaffView()

            case .user:
                if let profile = profile {
                    ContentView(profile: profile)
                } else {
                    // Fallback UI (shouldn’t happen)
                    Text("Loading profile...")
                }
            }
        } else {
            modeSelectionView
        }
    }

    private var modeSelectionView: some View {
        VStack(spacing: 24) {
            Text("Welcome to AssistiveApp")
                .font(.title)
                .padding(.top)

            Text("Please choose your mode to continue.")
                .font(.subheadline)
                .foregroundColor(.gray)

            Button("Continue as Staff") {
                selectedMode = .staff
            }
            .buttonStyle(.borderedProminent)

            Button("Continue as User") {
                selectedMode = .user
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    enum UserMode {
        case staff
        case user
    }
}
