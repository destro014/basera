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
        TabView(selection: $viewModel.selectedTab) {
            NavigationView {
                ZStack {
                    rolePrimaryTab

                    NavigationLink(
                        destination: routedNotificationDestination,
                        isActive: routedNotificationIsActive
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
            .tabItem {
                Label(viewModel.user.activeRole == .renter ? "Renter" : "Owner", systemImage: viewModel.user.activeRole == .renter ? "house" : "building.2")
            }
            .tag(HomeShellViewModel.Tab.primary)

            NavigationView {
                NotificationCenterView(userID: viewModel.user.id) { route in
                    viewModel.openNotificationRoute(route)
                }
            }
            .tabItem {
                Label("Notifications", systemImage: "bell")
            }
            .badge(viewModel.notificationBadge.unreadCount)
            .tag(HomeShellViewModel.Tab.notifications)

            SettingsView(
                user: viewModel.user,
                profileRepository: environment.profileRepository,
                onSwitchRole: handleRoleSwitch,
                onSignOut: onSignOut
            )
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(HomeShellViewModel.Tab.settings)
        }
        .task {
            await viewModel.refreshNotificationBadge(using: environment.notificationsRepository)
        }
        .task(id: viewModel.selectedTab) {
            await viewModel.refreshNotificationBadge(using: environment.notificationsRepository)
        }
    }

    @ViewBuilder
    private var rolePrimaryTab: some View {
        switch viewModel.user.activeRole {
        case .renter:
            RenterDashboardView()
        case .owner:
            OwnerDashboardView(ownerID: viewModel.user.id)
        }
    }

    @ViewBuilder
    private func notificationDestination(for route: NotificationRoute) -> some View {
        switch route {
        case .interests(let listingID):
            if viewModel.user.activeRole == .owner {
                OwnerInterestedRentersView(listingID: listingID ?? "OL-200", ownerID: viewModel.user.id)
            } else {
                RenterInterestsView(renterID: viewModel.user.id)
            }
        case .agreement:
            AgreementHubView(
                currentUserID: viewModel.user.id,
                party: viewModel.user.activeRole == .owner ? .owner : .renter
            )
        case .billing(let invoiceID):
            ActiveTenancyDetailView(
                tenancyID: invoiceID ?? "TEN-300",
                userID: viewModel.user.id,
                party: viewModel.user.activeRole == .owner ? .owner : .renter
            )
        case .payments(let invoiceID):
            ActiveTenancyDetailView(
                tenancyID: invoiceID ?? "TEN-300",
                userID: viewModel.user.id,
                party: viewModel.user.activeRole == .owner ? .owner : .renter
            )
        case .moveOut(let tenancyID):
            ActiveTenancyDetailView(
                tenancyID: tenancyID ?? "TEN-300",
                userID: viewModel.user.id,
                party: viewModel.user.activeRole == .owner ? .owner : .renter
            )
        case .review:
            ReviewHubView(userID: viewModel.user.id, role: viewModel.user.activeRole)
                .environmentObject(environment)
        }
    }

    @ViewBuilder
    private var routedNotificationDestination: some View {
        if let route = viewModel.routedNotification {
            notificationDestination(for: route)
        } else {
            EmptyView()
        }
    }

    private var routedNotificationIsActive: Binding<Bool> {
        Binding(
            get: { viewModel.routedNotification != nil },
            set: { isActive in
                if isActive == false {
                    viewModel.clearRoutedNotification()
                }
            }
        )
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
