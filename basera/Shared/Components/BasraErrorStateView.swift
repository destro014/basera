import SwiftUI

struct BasraErrorStateView: View {
    let title: String
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 28))
                .foregroundStyle(AppTheme.Colors.warning)
            Text(title)
                .font(AppTheme.Typography.subtitle)
            Text(message)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            BasraButton(title: "Try Again", style: .secondary, action: retryAction)
        }
        .padding()
    }
}

#Preview {
    BasraErrorStateView(title: "Something went wrong", message: "Basra could not refresh this section.", retryAction: {})
        .padding()
}
