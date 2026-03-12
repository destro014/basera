import SwiftUI

extension AppTheme {
    enum Palette {
        fileprivate static func color(_ name: String) -> Color {
            Color(name)
        }

        enum Brand {
            static let primary = Palette.color("brandPrimary")
            static let primaryHover = Palette.color("brandPrimaryHover")
            static let secondary = Palette.color("brandSecondary")
            static let secondaryHover = Palette.color("brandSecondaryHover")
            static let tertiary = Palette.color("brandTertiary")
            static let tertiaryHover = Palette.color("brandTertiaryHover")
            static let onPrimary = Palette.color("brandOnPrimary")
            static let onSecondary = Palette.color("brandOnSecondary")
            static let onTertiary = Palette.color("brandOnTertiary")
        }

        enum Success {
            static let primary = Palette.color("successPrimary")
            static let primaryHover = Palette.color("successPrimaryHover")
            static let secondary = Palette.color("successSecondary")
            static let secondaryHover = Palette.color("successSecondaryHover")
            static let tertiary = Palette.color("successTertiary")
            static let tertiaryHover = Palette.color("successTertiaryHover")
            static let onPrimary = Palette.color("successOnPrimary")
            static let onSecondary = Palette.color("successOnSecondary")
            static let onTertiary = Palette.color("successOnTertiary")
        }

        enum Error {
            static let primary = Palette.color("errorPrimary")
            static let primaryHover = Palette.color("errorPrimaryHover")
            static let secondary = Palette.color("errorSecondary")
            static let secondaryHover = Palette.color("errorSecondaryHover")
            static let tertiary = Palette.color("errorTertiary")
            static let tertiaryHover = Palette.color("errorTertiaryHover")
            static let onPrimary = Palette.color("errorOnPrimary")
            static let onSecondary = Palette.color("errorOnSecondary")
            static let onTertiary = Palette.color("errorOnTertiary")
        }

        enum Warning {
            static let primary = Palette.color("warningPrimary")
            static let primaryHover = Palette.color("warningPrimaryHover")
            static let secondary = Palette.color("warningSecondary")
            static let secondaryHover = Palette.color("warningSecondaryHover")
            static let tertiary = Palette.color("warningTertiary")
            static let tertiaryHover = Palette.color("warningTertiaryHover")
            static let onPrimary = Palette.color("warningOnPrimary")
            static let onSecondary = Palette.color("warningOnSecondary")
            static let onTertiary = Palette.color("warningOnTertiary")
        }

        enum Info {
            static let primary = Palette.color("infoPrimary")
            static let primaryHover = Palette.color("infoPrimaryHover")
            static let secondary = Palette.color("infoSecondary")
            static let secondaryHover = Palette.color("infoSecondaryHover")
            static let tertiary = Palette.color("infoTertiary")
            static let tertiaryHover = Palette.color("infoTertiaryHover")
            static let onPrimary = Palette.color("infoOnPrimary")
            static let onSecondary = Palette.color("infoOnSecondary")
            static let onTertiary = Palette.color("infoOnTertiary")
        }

        enum Neutral {
            static let primary = Palette.color("neutralPrimary")
            static let primaryHover = Palette.color("neutralPrimaryHover")
            static let secondary = Palette.color("neutralSecondary")
            static let secondaryHover = Palette.color("neutralSecondaryHover")
            static let tertiary = Palette.color("neutralTertiary")
            static let tertiaryHover = Palette.color("neutralTertiaryHover")
            static let onPrimary = Palette.color("neutralOnPrimary")
            static let onSecondary = Palette.color("neutralOnSecondary")
            static let onTertiary = Palette.color("neutralOnTertiary")
        }

        enum Text {
            static let primary = Palette.color("textPrimary")
            static let secondary = Palette.color("textSecondary")
            static let disabled = Palette.color("textDisabled")
        }

        enum Background {
            static let primary = Palette.color("backgroundPrimary")
        }

        enum Surface {
            static let primary = Palette.color("surfacePrimary")
            static let disabled = Palette.color("surfaceDisabled")
        }

        enum OnSurface {
            static let primary = Palette.color("onSurfacePrimary")
            static let disabled = Palette.color("onSurfaceDisabled")
        }

        enum Border {
            static let primary = Palette.color("borderPrimary")
            static let secondary = Palette.color("borderSecondary")
            static let disabled = Palette.color("borderDisabled")
        }
    }
}
