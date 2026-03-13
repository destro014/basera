import SwiftUI

extension AppTheme {
    enum Typography {
        struct Style {
            let size: CGFloat
            let lineHeight: CGFloat
            let tracking: CGFloat
            let weight: Font.Weight
            let relativeTextStyle: Font.TextStyle

            var font: Font {
                Font.custom(AppTheme.Typography.fontName(for: weight), size: size, relativeTo: relativeTextStyle)
            }

            var lineSpacing: CGFloat {
                max(0, lineHeight - size)
            }
        }

        static let displayLarge = Style(size: 64, lineHeight: 72, tracking: -1.5, weight: .semibold, relativeTextStyle: .largeTitle)
        static let displayMedium = Style(size: 52, lineHeight: 64, tracking: -2, weight: .semibold, relativeTextStyle: .largeTitle)
        static let displaySmall = Style(size: 40, lineHeight: 48, tracking: -2, weight: .semibold, relativeTextStyle: .title)

        static let headlineLarge = Style(size: 32, lineHeight: 40, tracking: -0.5, weight: .semibold, relativeTextStyle: .title)
        static let headlineMedium = Style(size: 28, lineHeight: 36, tracking: -0.5, weight: .semibold, relativeTextStyle: .title2)
        static let headlineSmall = Style(size: 24, lineHeight: 32, tracking: -0.5, weight: .semibold, relativeTextStyle: .title3)

        static let titleLarge = Style(size: 20, lineHeight: 24, tracking: 0.1, weight: .semibold, relativeTextStyle: .headline)
        static let titleMedium = Style(size: 16, lineHeight: 24, tracking: 0.1, weight: .semibold, relativeTextStyle: .subheadline)
        static let titleSmall = Style(size: 14, lineHeight: 20, tracking: 0.1, weight: .semibold, relativeTextStyle: .subheadline)

        static let bodyXLarge = Style(size: 20, lineHeight: 28, tracking: 0, weight: .regular, relativeTextStyle: .body)
        static let bodyLarge = Style(size: 16, lineHeight: 24, tracking: 0, weight: .regular, relativeTextStyle: .body)
        static let bodyMedium = Style(size: 14, lineHeight: 20, tracking: 0, weight: .regular, relativeTextStyle: .callout)
        static let bodySmall = Style(size: 12, lineHeight: 16, tracking: 0.4, weight: .regular, relativeTextStyle: .caption)

        static let labelLarge = Style(size: 16, lineHeight: 24, tracking: 0.3, weight: .medium, relativeTextStyle: .callout)
        static let labelMedium = Style(size: 14, lineHeight: 16, tracking: 0.3, weight: .medium, relativeTextStyle: .caption)
        static let labelSmall = Style(size: 12, lineHeight: 16, tracking: 0.3, weight: .medium, relativeTextStyle: .caption2)

        static let title = titleLarge.font
        static let subtitle = titleMedium.font
        static let body = bodyLarge.font
        static let caption = bodySmall.font

        private static func fontName(for weight: Font.Weight) -> String {
            switch weight {
            case .medium:
                return "Rubik-Medium"
            case .semibold, .bold, .heavy, .black:
                return "Rubik-SemiBold"
            default:
                return "Rubik-Regular"
            }
        }
    }
}

private struct BaseraTextStyleModifier: ViewModifier {
    let style: AppTheme.Typography.Style

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .font(style.font)
                .kerning(style.tracking)
                .lineSpacing(style.lineSpacing)
        } else {
            content
                .font(style.font)
                .lineSpacing(style.lineSpacing)
        }
    }
}

extension View {
    func baseraTextStyle(_ style: AppTheme.Typography.Style) -> some View {
        modifier(BaseraTextStyleModifier(style: style))
    }
}
