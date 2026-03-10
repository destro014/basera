import SwiftUI

enum AppTheme {
    enum Colors {
        static let brandPrimary = Color(red: 0.09, green: 0.4, blue: 0.75)
        static let brandSecondary = Color(red: 0.12, green: 0.65, blue: 0.56)
        static let info = Color(red: 0.08, green: 0.36, blue: 0.72)
        static let background = Palette.Background.regular
        static let backgroundLight = Palette.Background.light
        static let cardBackground = Palette.Surface.regular
        static let surface = Palette.Surface.regular
        static let surfaceDark = Palette.Surface.dark
        static let surfaceDarker = Palette.Surface.darker
        static let surfaceOpaque = Palette.Surface.opaque
        static let textPrimary = Palette.Text.primary
        static let textSecondary = Palette.Text.secondary
        static let textDisabled = Palette.Text.disabled
        static let border = Palette.Border.regular
        static let borderLight = Palette.Border.light
        static let borderDark = Palette.Border.dark
        static let separator = Palette.Separator.regular
        static let onPrimary = Palette.Primary.onPrimary
        static let success = Color.green
        static let warning = Color.orange
        static let danger = Color.red
    }

    enum Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 24
    }

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let full: CGFloat = 999
    }

    enum Typography {
        static let title = Font.title2.weight(.semibold)
        static let subtitle = Font.headline
        static let body = Font.body
        static let caption = Font.caption
    }
}
