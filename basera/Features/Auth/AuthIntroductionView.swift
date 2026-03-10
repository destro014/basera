import SwiftUI

struct AuthIntroductionView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            Text("Basera helps renters and owners keep every important rental record organised from day one.")
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            VStack(spacing: AppTheme.Spacing.medium) {
                introPoint(
                    iconName: "person.2.fill",
                    title: "One account, flexible roles",
                    message: "Start as a renter, an owner, or both. If you do both, you can switch roles later without creating a second account."
                )

                introPoint(
                    iconName: "lock.shield.fill",
                    title: "Privacy-first listing flow",
                    message: "Public listings keep the exact property address hidden until an owner reviews and approves the renter."
                )

                introPoint(
                    iconName: "doc.text.fill",
                    title: "Records that stay accessible",
                    message: "Track agreements, monthly invoices, partial payments, advance payments, and the formal move-out flow in one place."
                )
            }

            BaseraButton(title: "Continue", style: .primary, action: onContinue)
        }
    }

    private func introPoint(iconName: String, title: String, message: String) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.medium) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.brandPrimary)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                Text(title)
                    .font(AppTheme.Typography.subtitle)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Text(message)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .padding(AppTheme.Spacing.large)
        .background(AppTheme.Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))
    }
}

#Preview {
    AuthIntroductionView(onContinue: {})
        .padding()
}
