import SwiftUI

struct BaseraLoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            ProgressView()
            Text(message)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding()
    }
}

#Preview {
    BaseraLoadingView(message: "Loading Basera data")
}
