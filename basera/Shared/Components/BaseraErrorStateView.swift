import SwiftUI

struct BaseraErrorStateView: View {
    let title: String
    let message: String
    var retryTitle: String = "Try Again"
    let retryAction: () -> Void

    var body: some View {
        BaseraCard {
            VStack(spacing: AppTheme.Spacing.medium) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(AppTheme.Colors.warningPrimary)

                VStack(spacing: AppTheme.Spacing.small) {
                    Text(title)
                        .baseraTextStyle(AppTheme.Typography.titleMedium)
                        .multilineTextAlignment(.center)
                    Text(message)
                        .baseraTextStyle(AppTheme.Typography.bodyMedium)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                BaseraButton(title: retryTitle, style: .secondary, action: retryAction)
                    .frame(maxWidth: 240)
            }
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.medium)
        }
    }
}

#Preview {
    BaseraErrorStateView(title: "Something went wrong", message: "Basera could not refresh this section.", retryAction: {})
        .padding()
}
