import SwiftUI

struct BasraChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(AppTheme.Typography.caption)
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.vertical, AppTheme.Spacing.small)
            .background(AppTheme.Colors.brandSecondary.opacity(0.15))
            .foregroundStyle(AppTheme.Colors.brandSecondary)
            .clipShape(Capsule())
    }
}

#Preview {
    BasraChip(text: "Verified")
        .padding()
}
