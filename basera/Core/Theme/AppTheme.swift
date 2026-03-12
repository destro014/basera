import SwiftUI

enum AppTheme {
    enum Colors {
        static let brandPrimary = Palette.Brand.primary
        static let brandPrimaryHover = Palette.Brand.primaryHover
        static let brandSecondary = Palette.Brand.secondary
        static let brandSecondaryHover = Palette.Brand.secondaryHover
        static let brandTertiary = Palette.Brand.tertiary
        static let brandTertiaryHover = Palette.Brand.tertiaryHover
        static let brandOnPrimary = Palette.Brand.onPrimary
        static let brandOnSecondary = Palette.Brand.onSecondary
        static let brandOnTertiary = Palette.Brand.onTertiary

        static let successPrimary = Palette.Success.primary
        static let successPrimaryHover = Palette.Success.primaryHover
        static let successSecondary = Palette.Success.secondary
        static let successSecondaryHover = Palette.Success.secondaryHover
        static let successTertiary = Palette.Success.tertiary
        static let successTertiaryHover = Palette.Success.tertiaryHover
        static let successOnPrimary = Palette.Success.onPrimary
        static let successOnSecondary = Palette.Success.onSecondary
        static let successOnTertiary = Palette.Success.onTertiary

        static let errorPrimary = Palette.Error.primary
        static let errorPrimaryHover = Palette.Error.primaryHover
        static let errorSecondary = Palette.Error.secondary
        static let errorSecondaryHover = Palette.Error.secondaryHover
        static let errorTertiary = Palette.Error.tertiary
        static let errorTertiaryHover = Palette.Error.tertiaryHover
        static let errorOnPrimary = Palette.Error.onPrimary
        static let errorOnSecondary = Palette.Error.onSecondary
        static let errorOnTertiary = Palette.Error.onTertiary

        static let warningPrimary = Palette.Warning.primary
        static let warningPrimaryHover = Palette.Warning.primaryHover
        static let warningSecondary = Palette.Warning.secondary
        static let warningSecondaryHover = Palette.Warning.secondaryHover
        static let warningTertiary = Palette.Warning.tertiary
        static let warningTertiaryHover = Palette.Warning.tertiaryHover
        static let warningOnPrimary = Palette.Warning.onPrimary
        static let warningOnSecondary = Palette.Warning.onSecondary
        static let warningOnTertiary = Palette.Warning.onTertiary

        static let infoPrimary = Palette.Info.primary
        static let infoPrimaryHover = Palette.Info.primaryHover
        static let infoSecondary = Palette.Info.secondary
        static let infoSecondaryHover = Palette.Info.secondaryHover
        static let infoTertiary = Palette.Info.tertiary
        static let infoTertiaryHover = Palette.Info.tertiaryHover
        static let infoOnPrimary = Palette.Info.onPrimary
        static let infoOnSecondary = Palette.Info.onSecondary
        static let infoOnTertiary = Palette.Info.onTertiary

        static let neutralPrimary = Palette.Neutral.primary
        static let neutralPrimaryHover = Palette.Neutral.primaryHover
        static let neutralSecondary = Palette.Neutral.secondary
        static let neutralSecondaryHover = Palette.Neutral.secondaryHover
        static let neutralTertiary = Palette.Neutral.tertiary
        static let neutralTertiaryHover = Palette.Neutral.tertiaryHover
        static let neutralOnPrimary = Palette.Neutral.onPrimary
        static let neutralOnSecondary = Palette.Neutral.onSecondary
        static let neutralOnTertiary = Palette.Neutral.onTertiary

        static let textPrimary = Palette.Text.primary
        static let textSecondary = Palette.Text.secondary
        static let textDisabled = Palette.Text.disabled

        static let backgroundPrimary = Palette.Background.primary

        static let surfacePrimary = Palette.Surface.primary
        static let surfaceDisabled = Palette.Surface.disabled

        static let onSurfacePrimary = Palette.OnSurface.primary
        static let onSurfaceDisabled = Palette.OnSurface.disabled

        static let borderPrimary = Palette.Border.primary
        static let borderSecondary = Palette.Border.secondary
        static let borderDisabled = Palette.Border.disabled
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
}
