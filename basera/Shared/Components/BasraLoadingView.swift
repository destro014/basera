import SwiftUI

struct BasraLoadingView: View {
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
    BasraLoadingView(message: "Loading Basra data")
}
