import SwiftUI

struct BaseraPageContainer<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ViewBuilder private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .frame(maxWidth: horizontalSizeClass == .regular ? 900 : .infinity)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, horizontalSizeClass == .regular ? AppTheme.Spacing.xLarge * 2 : AppTheme.Spacing.large)
            .padding(.vertical, AppTheme.Spacing.large)
        .baseraScreenBackground()
    }
}

struct BaseraScreenBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.backgroundPrimary)
    }
}

struct BaseraListBackgroundModifier: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollContentBackground(.hidden)
                .background(AppTheme.Colors.backgroundPrimary)
        } else {
            content
                .background(AppTheme.Colors.backgroundPrimary)
        }
    }
}

extension View {
    func baseraScreenBackground() -> some View {
        modifier(BaseraScreenBackgroundModifier())
    }

    func baseraListBackground() -> some View {
        modifier(BaseraListBackgroundModifier())
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
