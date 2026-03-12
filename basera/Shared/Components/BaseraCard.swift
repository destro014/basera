import SwiftUI

struct BaseraCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(AppTheme.Spacing.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.Colors.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))
    }
}

#Preview {
    BaseraCard {
        Text("Basera card content")
            .baseraTextStyle(AppTheme.Typography.bodyLarge)
            .foregroundStyle(AppTheme.Colors.textPrimary)
    }
    .padding()
}
