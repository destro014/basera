import SwiftUI

struct BaseraLoadingView: View {
    let message: String

    var body: some View {
        BaseraCard {
            VStack(spacing: AppTheme.Spacing.medium) {
                ProgressView()
                    .controlSize(.large)
                    .tint(AppTheme.Colors.brandPrimary)

                Text(message)
                    .baseraTextStyle(AppTheme.Typography.bodyMedium)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.large)
        }
    }
}

#Preview {
    BaseraLoadingView(message: "Loading Basera data")
        .padding()
}
