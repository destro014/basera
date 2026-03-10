import SwiftUI

struct BaseraEmptyStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: "tray")
                .font(.system(size: 28))
                .foregroundStyle(AppTheme.Colors.textSecondary)
            Text(title)
                .font(AppTheme.Typography.subtitle)
            Text(message)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    BaseraEmptyStateView(title: "No Listings Yet", message: "Basera will show your saved properties here.")
}
