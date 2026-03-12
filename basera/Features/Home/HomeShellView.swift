import SwiftUI

struct HomeShellView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: HomeShellViewModel

    let onSwitchRole: (UserRole) -> Void
    let onSignOut: () -> Void

    init(user: AppUser, onSwitchRole: @escaping (UserRole) -> Void, onSignOut: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: HomeShellViewModel(user: user))
        self.onSwitchRole = onSwitchRole
        self.onSignOut = onSignOut
    }

    var body: some View {
        TabView {
            rolePrimaryTab

            SettingsView(
                user: viewModel.user,
                profileRepository: environment.profileRepository,
                onSwitchRole: handleRoleSwitch,
                onSignOut: onSignOut
            )
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
    }

    @ViewBuilder
    private var rolePrimaryTab: some View {
        switch viewModel.user.activeRole {
        case .renter:
            RenterDashboardView()
                .tabItem {
                    Label("Renter", systemImage: "house")
                }
        case .owner:
            OwnerDashboardView(ownerID: viewModel.user.id)
                .tabItem {
                    Label("Owner", systemImage: "building.2")
                }
        }
    }

    private func handleRoleSwitch(_ role: UserRole) {
        viewModel.switchRole(role)
        onSwitchRole(role)
    }
}

#Preview {
    HomeShellView(
        user: PreviewData.user(activeRole: .renter),
        onSwitchRole: { _ in },
        onSignOut: {}
    )
    .environmentObject(AppEnvironment.bootstrap())
}
