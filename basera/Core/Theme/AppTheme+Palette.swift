import SwiftUI

extension AppTheme {
    enum Palette {
        fileprivate static func color(_ name: String) -> Color {
            Color(name)
        }

        enum Primary {
            static let darker = Palette.color("PrimaryDarker")
            static let dark = Palette.color("PrimaryDark")
            static let regular = Palette.color("PrimaryRegular")
            static let light = Palette.color("PrimaryLight")
            static let lighter = Palette.color("PrimaryLighter")
            static let onPrimary = Palette.color("PrimaryOnPrimary")
        }

        enum Success {
            static let darker = Palette.color("SuccessDarker")
            static let dark = Palette.color("SuccessDark")
            static let regular = Palette.color("SuccessRegular")
            static let light = Palette.color("SuccessLight")
            static let lighter = Palette.color("SuccessLighter")
            static let onSuccess = Palette.color("SuccessOnSuccess")
        }

        enum Info {
            static let darker = Palette.color("InfoDarker")
            static let dark = Palette.color("InfoDark")
            static let regular = Palette.color("InfoRegular")
            static let light = Palette.color("InfoLight")
            static let lighter = Palette.color("InfoLighter")
            static let onInfo = Palette.color("InfoOnInfo")
        }

        enum Error {
            static let darker = Palette.color("ErrorDarker")
            static let dark = Palette.color("ErrorDark")
            static let regular = Palette.color("ErrorRegular")
            static let light = Palette.color("ErrorLight")
            static let lighter = Palette.color("ErrorLighter")
            static let onError = Palette.color("ErrorOnError")
        }

        enum Warning {
            static let darker = Palette.color("WarningDarker")
            static let dark = Palette.color("WarningDark")
            static let regular = Palette.color("WarningRegular")
            static let light = Palette.color("WarningLight")
            static let lighter = Palette.color("WarningLighter")
            static let onWarning = Palette.color("WarningOnWarning")
        }

        enum Text {
            static let primary = Palette.color("TextPrimary")
            static let secondary = Palette.color("TextSecondary")
            static let disabled = Palette.color("TextDisabled")
        }

        enum Surface {
            static let darker = Palette.color("SurfaceDarker")
            static let dark = Palette.color("SurfaceDark")
            static let regular = Palette.color("SurfaceRegular")
            static let opaque = Palette.color("SurfaceOpaque")
        }

        enum OnSurface {
            static let darker = Palette.color("OnSurfaceDarker")
            static let dark = Palette.color("OnSurfaceDark")
            static let regular = Palette.color("OnSurfaceRegular")
            static let onOpaque = Palette.color("OnSurfaceOnOpaque")
        }

        enum Border {
            static let dark = Palette.color("BorderDark")
            static let regular = Palette.color("BorderRegular")
            static let light = Palette.color("BorderLight")
        }

        enum Separator {
            static let regular = Palette.color("SeparatorRegular")
            static let light = Palette.color("SeparatorLight")
        }

        enum Background {
            static let regular = Palette.color("BackgroundRegular")
            static let light = Palette.color("BackgroundLight")
        }
    }
}
