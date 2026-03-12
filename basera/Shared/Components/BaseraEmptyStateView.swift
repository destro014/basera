import SwiftUI

struct BaseraEmptyStateView: View {
    let title: String
    let message: String
    var systemImage: String = "tray"
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        BaseraCard {
            VStack(spacing: AppTheme.Spacing.medium) {
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                VStack(spacing: AppTheme.Spacing.small) {
                    Text(title)
                        .baseraTextStyle(AppTheme.Typography.titleMedium)
                        .multilineTextAlignment(.center)
                    Text(message)
                        .baseraTextStyle(AppTheme.Typography.bodyMedium)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                if let actionTitle, let action {
                    BaseraButton(title: actionTitle, style: .secondary, action: action)
                        .frame(maxWidth: 240)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.medium)
        }
    }
}

#Preview("Default") {
    BaseraEmptyStateView(title: "No Listings Yet", message: "Basera will show your saved properties here.")
        .padding()
}

#Preview("With Action") {
    BaseraEmptyStateView(
        title: "No Notifications",
        message: "We will alert you when owners respond.",
        systemImage: "bell.slash",
        actionTitle: "Refresh",
        action: {}
    )
    .padding()
}
