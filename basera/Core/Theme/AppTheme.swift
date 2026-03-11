import SwiftUI

enum AppTheme {
    enum Colors {
        static let brandPrimary = Color(red: 0.09, green: 0.4, blue: 0.75)
        static let brandSecondary = Color(red: 0.12, green: 0.65, blue: 0.56)
        static let background = Color(.systemBackground)
        static let cardBackground = Color(.secondarySystemBackground)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let border = Color(.separator)
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
