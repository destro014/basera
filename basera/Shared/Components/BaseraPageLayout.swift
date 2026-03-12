import SwiftUI

struct BaseraPageContainer<Content: View>: View {
    @ViewBuilder private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding: CGFloat = geometry.size.width >= 768 ? AppTheme.Spacing.xLarge * 2 : AppTheme.Spacing.large
            let maxWidth: CGFloat = geometry.size.width >= 768 ? 900 : .infinity

            content()
                .frame(maxWidth: maxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, AppTheme.Spacing.large)
        }
    }
}

#Preview("iPhone") {
    BaseraPageContainer {
        BaseraCard {
            Text("Adaptive page container")
                .baseraTextStyle(AppTheme.Typography.titleMedium)
        }
    }
    .frame(height: 200)
}

#Preview("iPad") {
    BaseraPageContainer {
        BaseraCard {
            Text("Adaptive page container")
                .baseraTextStyle(AppTheme.Typography.titleMedium)
        }
    }
    .frame(width: 1024, height: 200)
}
