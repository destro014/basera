import SwiftUI

struct BaseraLoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            ProgressView()
                .tint(AppTheme.Colors.brandPrimary)
            Text(message)
                .baseraTextStyle(AppTheme.Typography.bodyLarge)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding()
    }
}

#Preview {
    BaseraLoadingView(message: "Loading Basera data")
}
