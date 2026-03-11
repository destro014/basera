import SwiftUI

struct AuthWelcomeView: View {
    let onContinue: (UserRole) -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            BasraAvatar(initials: "BA", size: 72)

            Text("Welcome to Basra")
                .font(AppTheme.Typography.title)

            Text("Choose a role to continue in preview mode.")
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: AppTheme.Spacing.medium) {
                BasraButton(title: "Continue as Renter", style: .primary) {
                    onContinue(.renter)
                }

                BasraButton(title: "Continue as Owner", style: .secondary) {
                    onContinue(.owner)
                }
            }
        }
        .padding()
    }
}

#Preview {
    AuthWelcomeView(onContinue: { _ in })
}
