import SwiftUI

struct SettingsView: View {
    let user: AppUser
    let profileRepository: ProfileRepositoryProtocol
    let onSwitchRole: (UserRole) -> Void
    let onSignOut: () -> Void

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        BaseraAvatar(initials: initials)
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                            Text(user.displayName)
                                .baseraTextStyle(AppTheme.Typography.titleMedium)
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                            Text(user.phoneNumber)
                                .baseraTextStyle(AppTheme.Typography.bodySmall)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                    }
                    .listRowBackground(AppTheme.Colors.surfacePrimary)

                    NavigationLink {
                        ProfileHubView(
                            user: user,
                            repository: profileRepository,
                            onSwitchRole: onSwitchRole
                        )
                    } label: {
                        HStack {
                            Text("Profile and Verification")
                                .baseraTextStyle(AppTheme.Typography.bodyLarge)
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                            Spacer()
                        }
                    }
                    .listRowBackground(AppTheme.Colors.surfacePrimary)
                } header: {
                    Text("Account")
                        .baseraTextStyle(AppTheme.Typography.labelLarge)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }

                if user.canSwitchRoles {
                    Section {
                        ForEach(Array(user.availableRoles), id: \.self) { role in
                            Button {
                                onSwitchRole(role)
                            } label: {
                                Text(role.title)
                                    .baseraTextStyle(AppTheme.Typography.bodyLarge)
                                    .foregroundStyle(user.activeRole == role ? AppTheme.Colors.brandPrimary : AppTheme.Colors.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .listRowBackground(AppTheme.Colors.surfacePrimary)
                        }
                    } header: {
                        Text("Switch Role")
                            .baseraTextStyle(AppTheme.Typography.labelLarge)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }

                Section {
                    Button(action: onSignOut) {
                        Text("Sign Out")
                            .baseraTextStyle(AppTheme.Typography.bodyLarge)
                            .foregroundStyle(AppTheme.Colors.errorPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .listRowBackground(AppTheme.Colors.surfacePrimary)
                }
            }
            .listStyle(.insetGrouped)
            .baseraListBackground()
            .navigationTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var initials: String {
        user.displayName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
    }
}

#Preview {
    SettingsView(
        user: PreviewData.user(activeRole: .owner),
        profileRepository: MockProfileRepository(),
        onSwitchRole: { _ in },
        onSignOut: {}
    )
}
