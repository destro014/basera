import SwiftUI

extension AppTheme {
    enum Palette {
        fileprivate static func asset(_ name: String) -> Color {
            Color(name)
        }

        // MARK: - Root tokens (pure source values from design)
        enum Root {
            enum Brand {
                static let primary = Palette.asset("brandPrimary")
                static let primaryHover = Palette.asset("brandPrimaryHover")
                static let secondary = Palette.asset("brandSecondary")
                static let secondaryHover = Palette.asset("brandSecondaryHover")
                static let tertiary = Palette.asset("brandTertiary")
                static let tertiaryHover = Palette.asset("brandTertiaryHover")
                static let onPrimary = Palette.asset("brandOnPrimary")
                static let onSecondary = Palette.asset("brandOnSecondary")
                static let onTertiary = Palette.asset("brandOnTertiary")
            }

            enum Success {
                static let primary = Palette.asset("successPrimary")
                static let primaryHover = Palette.asset("successPrimaryHover")
                static let secondary = Palette.asset("successSecondary")
                static let secondaryHover = Palette.asset("successSecondaryHover")
                static let tertiary = Palette.asset("successTertiary")
                static let tertiaryHover = Palette.asset("successTertiaryHover")
                static let onPrimary = Palette.asset("successOnPrimary")
                static let onSecondary = Palette.asset("successOnSecondary")
                static let onTertiary = Palette.asset("successOnTertiary")
            }

            enum Error {
                static let primary = Palette.asset("errorPrimary")
                static let primaryHover = Palette.asset("errorPrimaryHover")
                static let secondary = Palette.asset("errorSecondary")
                static let secondaryHover = Palette.asset("errorSecondaryHover")
                static let tertiary = Palette.asset("errorTertiary")
                static let tertiaryHover = Palette.asset("errorTertiaryHover")
                static let onPrimary = Palette.asset("errorOnPrimary")
                static let onSecondary = Palette.asset("errorOnSecondary")
                static let onTertiary = Palette.asset("errorOnTertiary")
            }

            enum Warning {
                static let primary = Palette.asset("warningPrimary")
                static let primaryHover = Palette.asset("warningPrimaryHover")
                static let secondary = Palette.asset("warningSecondary")
                static let secondaryHover = Palette.asset("warningSecondaryHover")
                static let tertiary = Palette.asset("warningTertiary")
                static let tertiaryHover = Palette.asset("warningTertiaryHover")
                static let onPrimary = Palette.asset("warningOnPrimary")
                static let onSecondary = Palette.asset("warningOnSecondary")
                static let onTertiary = Palette.asset("warningOnTertiary")
            }

            enum Info {
                static let primary = Palette.asset("infoPrimary")
                static let primaryHover = Palette.asset("infoPrimaryHover")
                static let secondary = Palette.asset("infoSecondary")
                static let secondaryHover = Palette.asset("infoSecondaryHover")
                static let tertiary = Palette.asset("infoTertiary")
                static let tertiaryHover = Palette.asset("infoTertiaryHover")
                static let onPrimary = Palette.asset("infoOnPrimary")
                static let onSecondary = Palette.asset("infoOnSecondary")
                static let onTertiary = Palette.asset("infoOnTertiary")
            }

            enum Neutral {
                static let primary = Palette.asset("neutralPrimary")
                static let primaryHover = Palette.asset("neutralPrimaryHover")
                static let secondary = Palette.asset("neutralSecondary")
                static let secondaryHover = Palette.asset("neutralSecondaryHover")
                static let tertiary = Palette.asset("neutralTertiary")
                static let tertiaryHover = Palette.asset("neutralTertiaryHover")
                static let onPrimary = Palette.asset("neutralOnPrimary")
                static let onSecondary = Palette.asset("neutralOnSecondary")
                static let onTertiary = Palette.asset("neutralOnTertiary")
            }

            enum Base {
                static let textPrimary = Palette.asset("textPrimary")
                static let textSecondary = Palette.asset("textSecondary")
                static let textDisabled = Palette.asset("textDisabled")
                static let backgroundPrimary = Palette.asset("backgroundPrimary")
                static let surfacePrimary = Palette.asset("surfacePrimary")
                static let surfaceDisabled = Palette.asset("surfaceDisabled")
                static let onSurfacePrimary = Palette.asset("onSurfacePrimary")
                static let onSurfaceDisabled = Palette.asset("onSurfaceDisabled")
                static let borderPrimary = Palette.asset("borderPrimary")
                static let borderSecondary = Palette.asset("borderSecondary")
                static let borderDisabled = Palette.asset("borderDisabled")
            }
        }

        // MARK: - Brand tokens
        enum Brand {
            static let primary = Root.Brand.primary
            static let primaryHover = Root.Brand.primaryHover
            static let secondary = Root.Brand.secondary
            static let secondaryHover = Root.Brand.secondaryHover
            static let tertiary = Root.Brand.tertiary
            static let tertiaryHover = Root.Brand.tertiaryHover
            static let onPrimary = Root.Brand.onPrimary
            static let onSecondary = Root.Brand.onSecondary
            static let onTertiary = Root.Brand.onTertiary
        }

        enum Success {
            static let primary = Root.Success.primary
            static let primaryHover = Root.Success.primaryHover
            static let secondary = Root.Success.secondary
            static let secondaryHover = Root.Success.secondaryHover
            static let tertiary = Root.Success.tertiary
            static let tertiaryHover = Root.Success.tertiaryHover
            static let onPrimary = Root.Success.onPrimary
            static let onSecondary = Root.Success.onSecondary
            static let onTertiary = Root.Success.onTertiary
        }

        enum Error {
            static let primary = Root.Error.primary
            static let primaryHover = Root.Error.primaryHover
            static let secondary = Root.Error.secondary
            static let secondaryHover = Root.Error.secondaryHover
            static let tertiary = Root.Error.tertiary
            static let tertiaryHover = Root.Error.tertiaryHover
            static let onPrimary = Root.Error.onPrimary
            static let onSecondary = Root.Error.onSecondary
            static let onTertiary = Root.Error.onTertiary
        }

        enum Warning {
            static let primary = Root.Warning.primary
            static let primaryHover = Root.Warning.primaryHover
            static let secondary = Root.Warning.secondary
            static let secondaryHover = Root.Warning.secondaryHover
            static let tertiary = Root.Warning.tertiary
            static let tertiaryHover = Root.Warning.tertiaryHover
            static let onPrimary = Root.Warning.onPrimary
            static let onSecondary = Root.Warning.onSecondary
            static let onTertiary = Root.Warning.onTertiary
        }

        enum Info {
            static let primary = Root.Info.primary
            static let primaryHover = Root.Info.primaryHover
            static let secondary = Root.Info.secondary
            static let secondaryHover = Root.Info.secondaryHover
            static let tertiary = Root.Info.tertiary
            static let tertiaryHover = Root.Info.tertiaryHover
            static let onPrimary = Root.Info.onPrimary
            static let onSecondary = Root.Info.onSecondary
            static let onTertiary = Root.Info.onTertiary
        }

        enum Neutral {
            static let primary = Root.Neutral.primary
            static let primaryHover = Root.Neutral.primaryHover
            static let secondary = Root.Neutral.secondary
            static let secondaryHover = Root.Neutral.secondaryHover
            static let tertiary = Root.Neutral.tertiary
            static let tertiaryHover = Root.Neutral.tertiaryHover
            static let onPrimary = Root.Neutral.onPrimary
            static let onSecondary = Root.Neutral.onSecondary
            static let onTertiary = Root.Neutral.onTertiary
        }

        // MARK: - Mapped semantic tokens
        enum Mapped {
            enum Text {
                static let primary = Root.Base.textPrimary
                static let secondary = Root.Base.textSecondary
                static let disabled = Root.Base.textDisabled
            }

            enum Background {
                static let primary = Root.Base.backgroundPrimary
            }

            enum Surface {
                static let primary = Root.Base.surfacePrimary
                static let disabled = Root.Base.surfaceDisabled
            }

            enum OnSurface {
                static let primary = Root.Base.onSurfacePrimary
                static let disabled = Root.Base.onSurfaceDisabled
            }

            enum Border {
                static let primary = Root.Base.borderPrimary
                static let secondary = Root.Base.borderSecondary
                static let disabled = Root.Base.borderDisabled
            }
        }

        // Backward-compatible aliases for existing usages.
        enum Text {
            static let primary = Mapped.Text.primary
            static let secondary = Mapped.Text.secondary
            static let disabled = Mapped.Text.disabled
        }

        enum Background {
            static let primary = Mapped.Background.primary
        }

        enum Surface {
            static let primary = Mapped.Surface.primary
            static let disabled = Mapped.Surface.disabled
        }

        enum OnSurface {
            static let primary = Mapped.OnSurface.primary
            static let disabled = Mapped.OnSurface.disabled
        }

        enum Border {
            static let primary = Mapped.Border.primary
            static let secondary = Mapped.Border.secondary
            static let disabled = Mapped.Border.disabled
        }
    }
}
