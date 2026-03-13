import SwiftUI

struct BaseraCard<Content: View>: View {
    let backgroundColor: Color
    @ViewBuilder let content: Content

    init(
        backgroundColor: Color = AppTheme.Colors.surfacePrimary,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppTheme.Spacing.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
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
