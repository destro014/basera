import SwiftUI

struct SettingsView: View {
    let user: AppUser
    let profileRepository: ProfileRepositoryProtocol
    let onSwitchRole: (UserRole) -> Void
    let onSignOut: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    HStack {
                        BaseraAvatar(initials: initials)
                        VStack(alignment: .leading) {
                            Text(user.displayName)
                            Text(user.phoneNumber)
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                    }

                    NavigationLink("Profile and Verification") {
                        ProfileHubView(
                            user: user,
                            repository: profileRepository,
                            onSwitchRole: onSwitchRole
                        )
                    }
                }

                if user.canSwitchRoles {
                    Section("Switch Role") {
                        ForEach(Array(user.availableRoles), id: \.self) { role in
                            Button(role.title) {
                                onSwitchRole(role)
                            }
                            .foregroundStyle(user.activeRole == role ? AppTheme.Colors.brandPrimary : AppTheme.Colors.textPrimary)
                        }
                    }
                }

                Section {
                    Button("Sign Out", role: .destructive, action: onSignOut)
                }
            }
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
}

#Preview {
    SettingsView(
        user: PreviewData.user(activeRole: .owner),
        profileRepository: MockProfileRepository(),
        onSwitchRole: { _ in },
        onSignOut: {}
    )
}
