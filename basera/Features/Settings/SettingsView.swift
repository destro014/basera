import SwiftUI

struct SettingsView: View {
    let user: AppUser
    let onSwitchRole: (UserRole) -> Void
    let onSignOut: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    HStack {
                        BasraAvatar(initials: initials)
                        VStack(alignment: .leading) {
                            Text(user.fullName)
                            Text(user.phoneNumber)
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
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
        user.fullName
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
        onSwitchRole: { _ in },
        onSignOut: {}
    )
}
