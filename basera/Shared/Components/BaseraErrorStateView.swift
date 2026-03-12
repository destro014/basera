import SwiftUI

struct BaseraErrorStateView: View {
    let title: String
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 28))
                .foregroundStyle(AppTheme.Colors.warningPrimary)
            Text(title)
                .baseraTextStyle(AppTheme.Typography.titleMedium)
            Text(message)
                .baseraTextStyle(AppTheme.Typography.bodyLarge)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            BaseraButton(title: "Try Again", style: .secondary, action: retryAction)
        }
        .padding()
    }
}

#Preview {
    BaseraErrorStateView(title: "Something went wrong", message: "Basera could not refresh this section.", retryAction: {})
        .padding()
}
