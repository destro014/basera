import SwiftUI

struct BaseraErrorStateView: View {
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
            BaseraButton(title: "Try Again", style: .secondary, action: retryAction)
        }
        .padding()
    }
}

#Preview {
    BaseraErrorStateView(title: "Something went wrong", message: "Basera could not refresh this section.", retryAction: {})
        .padding()
}
