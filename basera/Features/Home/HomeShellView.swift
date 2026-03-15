import SwiftUI

struct HomeShellView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: HomeShellViewModel

    let onSignOut: () -> Void

    private let defaultOwnerListingID = "OL-200"
    private let defaultTenancyID = "TEN-300"

    init(user: AppUser, onSignOut: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: HomeShellViewModel(user: user))
        self.onSignOut = onSignOut
    }

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            primaryTab
                .tabItem {
                    Label(primaryTabTitle, systemImage: primaryTabSystemImage)
                }
                .tag(HomeShellViewModel.Tab.primary)

            notificationsTab
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
                .badge(viewModel.notificationBadge.unreadCount)
                .tag(HomeShellViewModel.Tab.notifications)

            settingsTab
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(HomeShellViewModel.Tab.settings)
        }
        .task {
            await refreshNotificationBadge()
        }
        .task(id: viewModel.selectedTab) {
            await refreshNotificationBadge()
        }
    }

    private var primaryTab: some View {
        NavigationStack {
            rolePrimaryTab
                .navigationDestination(isPresented: routedNotificationIsActive) {
                    routedNotificationDestination
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .title) {
                        appLogo
                            .padding(.leading, -2)
                    }
                }
        }
    }

    private var notificationsTab: some View {
        NavigationStack {
            NotificationCenterView(userID: viewModel.user.id) { route in
                viewModel.openNotificationRoute(route)
            }
        }
    }

    private var settingsTab: some View {
        SettingsView(
            user: viewModel.user,
            profileRepository: environment.profileRepository,
            onSignOut: onSignOut
        )
    }

    private var appLogo: some View {
        Image("logo-horizontal")
            .resizable()
            .renderingMode(.original)
            .scaledToFit()
            .frame(width: 132, height: 34, alignment: .leading)
            .fixedSize(horizontal: true, vertical: true)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private var primaryTabTitle: String {
        viewModel.user.role == .renter ? "Renter" : "Owner"
    }

    private var primaryTabSystemImage: String {
        viewModel.user.role == .renter ? "house" : "building.2"
    }

    @ViewBuilder
    private var rolePrimaryTab: some View {
        switch viewModel.user.role {
        case .renter:
            RenterDashboardView(
                renterID: viewModel.user.id,
                renterSnapshot: renterSnapshot
            )
        case .owner:
            OwnerDashboardView(ownerID: viewModel.user.id)
        }
    }

    @ViewBuilder
    private func notificationDestination(for route: NotificationRoute) -> some View {
        switch route {
        case .interests(let listingID):
            interestsDestination(listingID: listingID)
        case .agreement:
            AgreementHubView(
                currentUserID: viewModel.user.id,
                party: currentAgreementParty
            )
        case .billing:
            tenancyDetailDestination(tenancyID: nil)
        case .payments:
            tenancyDetailDestination(tenancyID: nil)
        case .moveOut(let tenancyID):
            tenancyDetailDestination(tenancyID: tenancyID)
        case .review:
            ReviewHubView(userID: viewModel.user.id, role: viewModel.user.role)
                .environmentObject(environment)
        }
    }

    @ViewBuilder
    private func interestsDestination(listingID: String?) -> some View {
        if viewModel.user.role == .owner {
            OwnerInterestedRentersView(
                listingID: listingID ?? defaultOwnerListingID,
                ownerID: viewModel.user.id
            )
        } else {
            RenterInterestsView(renterID: viewModel.user.id)
        }
    }

    private func tenancyDetailDestination(tenancyID: String?) -> some View {
        ActiveTenancyDetailView(
            tenancyID: tenancyID ?? defaultTenancyID,
            userID: viewModel.user.id,
            party: currentAgreementParty
        )
    }

    private var currentAgreementParty: AgreementRecord.Party {
        viewModel.user.role == .owner ? .owner : .renter
    }

    private var renterSnapshot: RenterProfileSnapshot {
        RenterProfileSnapshot(
            renterID: viewModel.user.id,
            fullName: viewModel.user.displayName,
            occupation: "Not specified",
            familySize: 1,
            hasPets: false,
            smokingStatus: "Not specified"
        )
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

    private func refreshNotificationBadge() async {
        await viewModel.refreshNotificationBadge(using: environment.notificationsRepository)
    }
}

#Preview {
    HomeShellView(
        user: PreviewData.user(role: .renter),
        onSignOut: {}
    )
    .environmentObject(AppEnvironment.bootstrap())
}
