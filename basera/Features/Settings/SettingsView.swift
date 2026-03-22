import SwiftUI
import VroxalDesign

struct SettingsView: View {
    @EnvironmentObject private var environment: AppEnvironment

    let user: AppUser
    let profileRepository: ProfileRepositoryProtocol
    let onSignOut: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        BaseraAvatar(initials: initials)
                        VStack(alignment: .leading, spacing: VdSpacing.xs) {
                            Text(user.displayName)
                                .vdFont(VdFont.titleMedium)
                                .foregroundStyle(Color.vdContentDefaultBase)
                            if user.email.isEmpty == false {
                                Text(user.email)
                                    .vdFont(VdFont.bodySmall)
                                    .foregroundStyle(Color.vdContentDefaultSecondary)
                            }
                            Text(user.phoneNumber)
                                .vdFont(VdFont.bodySmall)
                                .foregroundStyle(Color.vdContentDefaultSecondary)
                        }
                    }
                    .listRowBackground(Color.vdBackgroundDefaultSecondary)

                    NavigationLink {
                        ProfileHubView(
                            user: user,
                            repository: profileRepository
                        )
                    } label: {
                        HStack {
                            Text("Profile and Verification")
                                .vdFont(VdFont.bodyLarge)
                                .foregroundStyle(Color.vdContentDefaultBase)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.vdBackgroundDefaultSecondary)
                } header: {
                    Text("Account")
                        .vdFont(VdFont.labelLarge)
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                }

                Section {
                    ForEach(quickActionItems, id: \.title) { item in
                        NavigationLink {
                            item.destination
                        } label: {
                            HStack {
                                Label(item.title, systemImage: item.systemImage)
                                    .vdFont(VdFont.bodyLarge)
                                    .foregroundStyle(Color.vdContentDefaultBase)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.vdBackgroundDefaultSecondary)
                    }
                } header: {
                    Text("Quick Actions")
                        .vdFont(VdFont.labelLarge)
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                }

                Section {
                    NavigationLink {
                        VdPreviewGallery()
                    } label: {
                        HStack {
                            Label("Vroxal Preview Gallery", systemImage: "square.grid.3x2")
                                .vdFont(VdFont.bodyLarge)
                                .foregroundStyle(Color.vdContentDefaultBase)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.vdBackgroundDefaultSecondary)
                } header: {
                    Text("Design System")
                        .vdFont(VdFont.labelLarge)
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                }

                Section {
                    Button(action: onSignOut) {
                        Text("Sign Out")
                            .vdFont(VdFont.bodyLarge)
                            .foregroundStyle(Color.vdContentErrorBase)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .listRowBackground(Color.vdBackgroundDefaultSecondary)
                }
            }
            .listStyle(.insetGrouped)
            .baseraListBackground()
            .navigationTitle("Settings")
        }
    }

    private var initials: String {
        user.displayName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
    }

    private var quickActionItems: [QuickActionItem] {
        switch user.role {
        case .renter:
            [
                QuickActionItem(
                    title: "My Interest Requests",
                    systemImage: "paperplane",
                    destination: AnyView(RenterInterestsView(renterID: user.id))
                ),
                QuickActionItem(
                    title: "My Agreement",
                    systemImage: "doc.richtext",
                    destination: AnyView(
                        AgreementHubView(currentUserID: user.id, party: .renter)
                    )
                ),
                QuickActionItem(
                    title: "Reviews & Ratings",
                    systemImage: "star.bubble",
                    destination: AnyView(
                        ReviewHubView(userID: user.id, role: .renter)
                            .environmentObject(environment)
                    )
                )
            ]
        case .owner:
            [
                QuickActionItem(
                    title: "Manage My Listings",
                    systemImage: "building.2",
                    destination: AnyView(MyListingsView(ownerID: user.id))
                ),
                QuickActionItem(
                    title: "Agreement Hub",
                    systemImage: "doc.richtext",
                    destination: AnyView(
                        AgreementHubView(currentUserID: user.id, party: .owner)
                    )
                ),
                QuickActionItem(
                    title: "Reviews & Ratings",
                    systemImage: "star.bubble",
                    destination: AnyView(
                        ReviewHubView(userID: user.id, role: .owner)
                            .environmentObject(environment)
                    )
                )
            ]
        }
    }
}

private struct QuickActionItem {
    let title: String
    let systemImage: String
    let destination: AnyView
}

#Preview {
    SettingsView(
        user: PreviewData.user(role: .owner),
        profileRepository: MockProfileRepository(),
        onSignOut: {}
    )
}
