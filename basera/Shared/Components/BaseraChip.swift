import SwiftUI

struct BaseraChip: View {
    let text: String

    var body: some View {
        Text(text)
            .baseraTextStyle(AppTheme.Typography.labelLarge)
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.vertical, AppTheme.Spacing.small)
            .background(AppTheme.Colors.brandSecondary.opacity(0.15))
            .foregroundStyle(AppTheme.Colors.brandSecondary)
            .clipShape(Capsule())
    }
}

#Preview {
    BaseraChip(text: "Verified")
        .padding()
}
