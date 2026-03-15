// VdPreviewGallery.swift — Vroxal Design System
// ─────────────────────────────────────────────────────────────
// Full token gallery for verifying Colors, Typography and Scale.
// Open this file in Xcode and enable the canvas:
//   Editor → Canvas  (or ⌥⌘↩)
// ─────────────────────────────────────────────────────────────

import SwiftUI
import VroxalDesign

// ═════════════════════════════════════════════════════════════
// MARK: — Top-level preview entry point
// ═════════════════════════════════════════════════════════════

#Preview("Vd Token Gallery") {
    NavigationStack {
        List {
            NavigationLink("Colors") { VdColorGallery() }
            NavigationLink("Typography") { VdTypographyGallery() }
            NavigationLink("Scale") { VdScaleGallery() }
        }
        .scrollContentBackground(.hidden)
        .background(Color.vdBackground)
        .navigationTitle("Vroxal Design")
        .navigationBarTitleDisplayMode(.large)
    }
}


// ═════════════════════════════════════════════════════════════
// MARK: — Colors Gallery
// ═════════════════════════════════════════════════════════════

struct VdColorGallery: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VdSpacing.xxl) {

                // ── Raw palette ───────────────────────────────
                sectionHeader("Raw Palette", subtitle: "root.json → Color.*")

                paletteRow("BlueGlow", colors: [
                    ("#DEDBFD", "50"), ("#CEC9FC", "100"), ("#BDB7FB", "200"),
                    ("#9C92F8", "300"), ("#7B6EF6", "400"), ("#5a4af4", "500"),
                    ("#483bc3", "600"), ("#362C92", "700"), ("#1F1A55", "800"), ("#120F31", "900")
                ])
                paletteRow("Green", colors: [
                    ("#e7f3ee", "50"), ("#cfe7dd", "100"), ("#9fcfbb", "200"),
                    ("#6eb799", "300"), ("#3e9f77", "400"), ("#0e8755", "500"),
                    ("#0b6c44", "600"), ("#085133", "700"), ("#063622", "800"), ("#031b11", "900")
                ])
                paletteRow("Red", colors: [
                    ("#fbe9ea", "50"), ("#f8d2d4", "100"), ("#f0a5a9", "200"),
                    ("#e9787e", "300"), ("#e14b53", "400"), ("#da1e28", "500"),
                    ("#ae1820", "600"), ("#831218", "700"), ("#570c10", "800"), ("#2c0608", "900")
                ])
                paletteRow("Orange", colors: [
                    ("#fcf0e6", "50"), ("#f8e0cc", "100"), ("#f1c299", "200"),
                    ("#eaa366", "300"), ("#e38533", "400"), ("#dc6600", "500"),
                    ("#b05200", "600"), ("#843d00", "700"), ("#582900", "800"), ("#2c1400", "900")
                ])
                paletteRow("Blue", colors: [
                    ("#eaf1fb", "50"), ("#d6e3f6", "100"), ("#adc7ee", "200"),
                    ("#83aae5", "300"), ("#5a8edd", "400"), ("#3172d4", "500"),
                    ("#275baa", "600"), ("#1d447f", "700"), ("#142e55", "800"), ("#0a172a", "900")
                ])
                paletteRow("Grey", colors: [
                    ("#F6F5FF", "50"), ("#E7E6F5", "100"), ("#D7D5E5", "200"),
                    ("#9F9CBA", "300"), ("#797791", "400"), ("#5A5870", "500"),
                    ("#48465C", "600"), ("#323045", "700"), ("#19172B", "800"), ("#04021A", "900")
                ])

                divider()

                // ── Semantic — Text ───────────────────────────
                sectionHeader("Text Tokens", subtitle: "light.json + dark.json → Color.Text.*")

                semanticGroup("Default") {
                    semanticRow("vdTextPrimary",    .vdTextPrimary,    "Text/Default/Primary")
                    semanticRow("vdTextSecondary",  .vdTextSecondary,  "Text/Default/Secondary")
                    semanticRow("vdTextTertiary",   .vdTextTertiary,   "Text/Default/Tertiary")
                    semanticRow("vdTextDisabled",   .vdTextDisabled,   "Text/Default/Disabled")
                }
                semanticGroup("Accent (Primary)") {
                    semanticRow("vdTextAccent",          .vdTextAccent,          "Text/Primary/Primary")
                    semanticRow("vdTextAccentSecondary", .vdTextAccentSecondary, "Text/Primary/Secondary")
                    semanticRow("vdTextOnPrimary",       .vdTextOnPrimary,       "Text/Primary/OnPrimary")
                }
                semanticGroup("Status") {
                    semanticRow("vdTextSuccess", .vdTextSuccess, "Text/Success/Primary")
                    semanticRow("vdTextError",   .vdTextError,   "Text/Error/Primary")
                    semanticRow("vdTextWarning", .vdTextWarning, "Text/Warning/Primary")
                    semanticRow("vdTextInfo",    .vdTextInfo,    "Text/Info/Primary")
                    semanticRow("vdTextNeutral", .vdTextNeutral, "Text/Neutral/Primary")
                }

                divider()

                // ── Semantic — Background ─────────────────────
                sectionHeader("Background Tokens", subtitle: "Color.Background.*")

                semanticGroup("Default") {
                    semanticRow("vdBackground",      .vdBackground,      "Background/Default/Primary")
                    semanticRow("vdSurface",         .vdSurface,         "Background/Default/Secondary")
                    semanticRow("vdSurfaceAlt",      .vdSurfaceAlt,      "Background/Default/Tertiary")
                    semanticRow("vdBackgroundDisabled", .vdBackgroundDisabled, "Background/Default/Disabled")
                }
                semanticGroup("Primary (brand)") {
                    semanticRow("vdBgPrimary",        .vdBgPrimary,        "Background/Primary/Primary")
                    semanticRow("vdBgPrimaryHover",   .vdBgPrimaryHover,   "Background/Primary/PrimaryHover")
                    semanticRow("vdBgPrimarySubtle",  .vdBgPrimarySubtle,  "Background/Primary/Secondary")
                    semanticRow("vdBgPrimaryTertiary",.vdBgPrimaryTertiary,"Background/Primary/Tertiary")
                }
                semanticGroup("Status") {
                    semanticRow("vdBgSuccess",       .vdBgSuccess,       "Background/Success/Primary")
                    semanticRow("vdBgSuccessSubtle", .vdBgSuccessSubtle, "Background/Success/Secondary")
                    semanticRow("vdBgError",         .vdBgError,         "Background/Error/Primary")
                    semanticRow("vdBgErrorSubtle",   .vdBgErrorSubtle,   "Background/Error/Secondary")
                    semanticRow("vdBgWarning",       .vdBgWarning,       "Background/Warning/Primary")
                    semanticRow("vdBgWarningSubtle", .vdBgWarningSubtle, "Background/Warning/Secondary")
                    semanticRow("vdBgInfo",          .vdBgInfo,          "Background/Info/Primary")
                    semanticRow("vdBgInfoSubtle",    .vdBgInfoSubtle,    "Background/Info/Secondary")
                    semanticRow("vdBgNeutral",       .vdBgNeutral,       "Background/Neutral/Primary")
                    semanticRow("vdBgNeutralSubtle", .vdBgNeutralSubtle, "Background/Neutral/Secondary")
                }

                divider()

                // ── Semantic — Border ─────────────────────────
                sectionHeader("Border Tokens", subtitle: "Color.Border.*")

                semanticGroup("Default") {
                    semanticRow("vdBorderDefault",  .vdBorderDefault,  "Border/Default/Primary")
                    semanticRow("vdBorderSubtle",   .vdBorderSubtle,   "Border/Default/Secondary")
                    semanticRow("vdBorderTertiary", .vdBorderTertiary, "Border/Default/Tertiary")
                    semanticRow("vdBorderDisabled", .vdBorderDisabled, "Border/Default/Disabled")
                }
                semanticGroup("Status") {
                    semanticRow("vdBorderPrimary", .vdBorderPrimary, "Border/Primary/Primary")
                    semanticRow("vdBorderSuccess", .vdBorderSuccess, "Border/Success/Primary")
                    semanticRow("vdBorderError",   .vdBorderError,   "Border/Error/Primary")
                    semanticRow("vdBorderWarning", .vdBorderWarning, "Border/Warning/Primary")
                    semanticRow("vdBorderInfo",    .vdBorderInfo,    "Border/Info/Primary")
                    semanticRow("vdBorderNeutral", .vdBorderNeutral, "Border/Neutral/Primary")
                }

                divider()

                // ── Semantic — Icon ───────────────────────────
                sectionHeader("Icon Tokens", subtitle: "Color.Icon.*")

                semanticGroup("Default") {
                    iconRow("vdIconPrimary",   .vdIconPrimary,   "Icon/Default/Primary")
                    iconRow("vdIconSecondary", .vdIconSecondary, "Icon/Default/Secondary")
                    iconRow("vdIconTertiary",  .vdIconTertiary,  "Icon/Default/Tertiary")
                    iconRow("vdIconDisabled",  .vdIconDisabled,  "Icon/Default/Disabled")
                }
                semanticGroup("Brand & Status") {
                    iconRow("vdIconAccent",   .vdIconAccent,   "Icon/Primary/Primary")
                    iconRow("vdIconSuccess",  .vdIconSuccess,  "Icon/Success/Primary")
                    iconRow("vdIconError",    .vdIconError,    "Icon/Error/Primary")
                    iconRow("vdIconWarning",  .vdIconWarning,  "Icon/Warning/Primary")
                    iconRow("vdIconInfo",     .vdIconInfo,     "Icon/Info/Primary")
                    iconRow("vdIconNeutral",  .vdIconNeutral,  "Icon/Neutral/Primary")
                }
            }
            .padding(VdSpacing.lg)
        }
        .background(Color.vdBackground)
        .navigationTitle("Colors")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — Typography Gallery
// ═════════════════════════════════════════════════════════════

struct VdTypographyGallery: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VdSpacing.none) {

                // ── Display ───────────────────────────────────
                sectionHeader("Display", subtitle: "SemiBold · tracking negative")
                typeRow("Display Large",  VdFont.displayLarge,  "60 / 72 / -1.5")
                typeRow("Display Medium", VdFont.displayMedium, "48 / 56 / -1.0")
                typeRow("Display Small",  VdFont.displaySmall,  "40 / 48 / -0.5")

                divider()

                // ── Headline ──────────────────────────────────
                sectionHeader("Headline", subtitle: "SemiBold · tracking -0.3")
                typeRow("Headline Large",  VdFont.headlineLarge,  "34 / 40")
                typeRow("Headline Medium", VdFont.headlineMedium, "28 / 36")
                typeRow("Headline Small",  VdFont.headlineSmall,  "24 / 32")

                divider()

                // ── Title ─────────────────────────────────────
                sectionHeader("Title", subtitle: "SemiBold · tracking 0")
                typeRow("Title Large",  VdFont.titleLarge,  "20 / 28")
                typeRow("Title Medium", VdFont.titleMedium, "16 / 24")
                typeRow("Title Small",  VdFont.titleSmall,  "14 / 20")

                divider()

                // ── Label ─────────────────────────────────────
                sectionHeader("Label", subtitle: "Medium (500) · tracking +0.2")
                typeRow("Label Large",      VdFont.labelLarge,      "16 / 24")
                typeRow("Label Medium",     VdFont.labelMedium,     "14 / 24")
                typeRow("Label Small",      VdFont.labelSmall,      "12 / 16")
                typeRow("Label Extra Small",VdFont.labelExtraSmall, "10 / 16")

                divider()

                // ── Body ──────────────────────────────────────
                sectionHeader("Body", subtitle: "Regular (400) · tracking 0")
                typeRow("Body Extra Large", VdFont.bodyExtraLarge, "24 / 36")
                typeRow("Body Large",       VdFont.bodyLarge,      "16 / 24")
                typeRow("Body Medium",      VdFont.bodyMedium,     "14 / 24")
                typeRow("Body Medium Italic", VdFont.bodyMediumItalic, "14 / 24 · italic")
                typeRow("Body Small",       VdFont.bodySmall,      "12 / 16")
                typeRow("Body Extra Small", VdFont.bodyExtraSmall, "10 / 16")

                divider()

                // ── Live text sample ──────────────────────────
                sectionHeader("Live Sample", subtitle: "All weights in context")
                VStack(alignment: .leading, spacing: VdSpacing.sm) {
                    Text("Vroxal Design System")
                        .vdFont(VdFont.displaySmall)
                        .foregroundStyle(Color.vdTextPrimary)
                    Text("Build consistent, accessible experiences across every platform.")
                        .vdFont(VdFont.bodyLarge)
                        .foregroundStyle(Color.vdTextSecondary)
                    Text("TOKENS · COMPONENTS · PATTERNS")
                        .vdFont(VdFont.labelSmall)
                        .foregroundStyle(Color.vdTextAccent)
                        .tracking(VdTracking.label)
                }
                .padding(VdSpacing.lg)
                .background(Color.vdSurface)
                .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
                .padding(.top, VdSpacing.md)
            }
            .padding(VdSpacing.lg)
        }
        .background(Color.vdBackground)
        .navigationTitle("Typography")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — Scale Gallery
// ═════════════════════════════════════════════════════════════

struct VdScaleGallery: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VdSpacing.xxl) {

                // ── Spacing ───────────────────────────────────
                sectionHeader("VdSpacing", subtitle: "Scale.Spacing.* · brand.json → root.json")

                VStack(alignment: .leading, spacing: VdSpacing.xs) {
                    spacingBar("none / s0",   VdSpacing.none,  "0 pt")
                    spacingBar("xxs  / s50",  VdSpacing.xxs,   "2 pt")
                    spacingBar("xs   / s100", VdSpacing.xs,    "4 pt")
                    spacingBar("sm   / s200", VdSpacing.sm,    "8 pt")
                    spacingBar("smMd / s300", VdSpacing.smMd,  "12 pt")
                    spacingBar("md   / s400", VdSpacing.md,    "16 pt")
                    spacingBar("lg   / s600", VdSpacing.lg,    "24 pt")
                    spacingBar("xl   / s800", VdSpacing.xl,    "32 pt")
                    spacingBar("xxl  / s1000",VdSpacing.xxl,   "40 pt")
                    spacingBar("xxxl / s1200",VdSpacing.xxxl,  "48 pt")
                    spacingBar("huge / s1600",VdSpacing.huge,  "64 pt")
                }

                divider()

                // ── Border Radius ─────────────────────────────
                sectionHeader("VdRadius", subtitle: "Scale.Border.Radius.*")

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: VdSpacing.sm), count: 3), spacing: VdSpacing.sm) {
                    radiusBox("none\n0pt",    VdRadius.none)
                    radiusBox("xs\n4pt",      VdRadius.xs)
                    radiusBox("sm\n8pt",      VdRadius.sm)
                    radiusBox("md\n12pt",     VdRadius.md)
                    radiusBox("lg\n16pt",     VdRadius.lg)
                    radiusBox("xl\n24pt",     VdRadius.xl)
                    radiusBox("xxl\n32pt",    VdRadius.xxl)
                    radiusBox("xxxl\n40pt",   VdRadius.xxxl)
                    radiusBox("full\n120pt",  VdRadius.full)
                }

                divider()

                // ── Border Width ──────────────────────────────
                sectionHeader("VdBorderWidth", subtitle: "Scale.Border.Width.*")

                VStack(alignment: .leading, spacing: VdSpacing.md) {
                    borderWidthRow("none / sm — 1pt", VdBorderWidth.sm)
                    borderWidthRow("md — 2pt",        VdBorderWidth.md)
                    borderWidthRow("lg — 4pt",        VdBorderWidth.lg)
                    borderWidthRow("xl — 8pt",        VdBorderWidth.xl)
                }

                divider()

                // ── Icon Size ─────────────────────────────────
                sectionHeader("VdIconSize", subtitle: "Scale.Icon.Size.*")

                HStack(alignment: .bottom, spacing: VdSpacing.lg) {
                    iconSizeBox("xs\n16pt", VdIconSize.xs)
                    iconSizeBox("sm\n20pt", VdIconSize.sm)
                    iconSizeBox("md\n24pt", VdIconSize.md)
                    iconSizeBox("lg\n32pt", VdIconSize.lg)
                    iconSizeBox("xl\n40pt", VdIconSize.xl)
                }
            }
            .padding(VdSpacing.lg)
        }
        .background(Color.vdBackground)
        .navigationTitle("Scale")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — Shared helper views
// ═════════════════════════════════════════════════════════════

// ── Section header ────────────────────────────────────────────
private func sectionHeader(_ title: String, subtitle: String) -> some View {
    VStack(alignment: .leading, spacing: VdSpacing.xxs) {
        Text(title)
            .vdFont(VdFont.titleLarge)
            .foregroundStyle(Color.vdTextPrimary)
        Text(subtitle)
            .vdFont(VdFont.labelSmall)
            .foregroundStyle(Color.vdTextTertiary)
    }
    .padding(.top, VdSpacing.md)
    .padding(.bottom, VdSpacing.xs)
}

// ── Section divider ───────────────────────────────────────────
private func divider() -> some View {
    Rectangle()
        .fill(Color.vdBorderTertiary)
        .frame(height: 1)
        .padding(.vertical, VdSpacing.sm)
}

// ── Palette row (raw hex swatches) ────────────────────────────
private func paletteRow(_ name: String, colors: [(String, String)]) -> some View {
    VStack(alignment: .leading, spacing: VdSpacing.xxs) {
        Text(name)
            .vdFont(VdFont.labelSmall)
            .foregroundStyle(Color.vdTextSecondary)
        HStack(spacing: 3) {
            ForEach(colors, id: \.1) { hex, shade in
                VStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: VdRadius.xs)
                        .fill(Color(hex: hex))
                        .frame(height: 36)
                    Text(shade)
                        .vdFont(VdFont.labelExtraSmall)
                        .foregroundStyle(Color.vdTextTertiary)
                }
            }
        }
    }
}

private extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let red, green, blue: Double
        switch sanitized.count {
        case 6:
            red = Double((value >> 16) & 0xFF) / 255
            green = Double((value >> 8) & 0xFF) / 255
            blue = Double(value & 0xFF) / 255
        default:
            red = 0
            green = 0
            blue = 0
        }

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}

// ── Semantic group container ──────────────────────────────────
private func semanticGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: VdSpacing.xxs) {
        Text(title)
            .vdFont(VdFont.labelSmall)
            .foregroundStyle(Color.vdTextTertiary)
            .padding(.bottom, VdSpacing.xxs)
        content()
    }
    .padding(.bottom, VdSpacing.sm)
}

// ── Semantic color row (with light/dark swatch) ───────────────
private func semanticRow(_ token: String, _ color: Color, _ figmaPath: String) -> some View {
    HStack(spacing: VdSpacing.md) {
        // Swatch showing both light and dark
        HStack(spacing: 2) {
            RoundedRectangle(cornerRadius: VdRadius.xs)
                .fill(color)
                .frame(width: 32, height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: VdRadius.xs)
                        .strokeBorder(Color.vdBorderTertiary.opacity(0.4), lineWidth: 0.5)
                )
        }
        VStack(alignment: .leading, spacing: 1) {
            Text(".\(token)")
                .vdFont(VdFont.labelSmall)
                .foregroundStyle(Color.vdTextPrimary)
            Text(figmaPath)
                .vdFont(VdFont.bodyExtraSmall)
                .foregroundStyle(Color.vdTextTertiary)
        }
        Spacer()
    }
    .padding(.vertical, VdSpacing.xxs)
}

// ── Icon token row ────────────────────────────────────────────
private func iconRow(_ token: String, _ color: Color, _ figmaPath: String) -> some View {
    HStack(spacing: VdSpacing.md) {
        Image(systemName: "star.fill")
            .font(.system(size: VdIconSize.md))
            .foregroundStyle(color)
            .frame(width: 32, height: 32)
        VStack(alignment: .leading, spacing: 1) {
            Text(".\(token)")
                .vdFont(VdFont.labelSmall)
                .foregroundStyle(Color.vdTextPrimary)
            Text(figmaPath)
                .vdFont(VdFont.bodyExtraSmall)
                .foregroundStyle(Color.vdTextTertiary)
        }
        Spacer()
    }
    .padding(.vertical, VdSpacing.xxs)
}

// ── Typography row ────────────────────────────────────────────
private func typeRow(_ label: String, _ style: VdTextStyle, _ spec: String) -> some View {
    HStack(alignment: .firstTextBaseline) {
        Text("Vroxal")
            .vdFont(style)                          // ← was .font(font)
            .foregroundStyle(Color.vdTextPrimary)
            .minimumScaleFactor(0.4)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
        VStack(alignment: .trailing, spacing: 1) {
            Text(label)
                .vdFont(VdFont.labelSmall)
                .foregroundStyle(Color.vdTextSecondary)
            Text(spec)
                .vdFont(VdFont.bodyExtraSmall)
                .foregroundStyle(Color.vdTextTertiary)
        }
    }
    .padding(.vertical, VdSpacing.xs)
    .overlay(alignment: .bottom) {
        Rectangle()
            .fill(Color.vdBorderTertiary.opacity(0.5))
            .frame(height: 0.5)
    }
}

// ── Spacing bar ───────────────────────────────────────────────
private func spacingBar(_ label: String, _ value: CGFloat, _ pts: String) -> some View {
    HStack(spacing: VdSpacing.sm) {
        Text(label)
            .vdFont(VdFont.labelSmall)
            .foregroundStyle(Color.vdTextSecondary)
            .frame(width: 100, alignment: .leading)
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.vdBgPrimarySubtle)
                .frame(width: 200, height: 16)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.vdBgPrimary)
                .frame(width: max(value, 2), height: 16)
        }
        Text(pts)
            .vdFont(VdFont.labelSmall)
            .foregroundStyle(Color.vdTextTertiary)
    }
}

// ── Radius box ────────────────────────────────────────────────
private func radiusBox(_ label: String, _ radius: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: min(radius, 36))
        .fill(Color.vdBgPrimarySubtle)
        .overlay(
            RoundedRectangle(cornerRadius: min(radius, 36))
                .strokeBorder(Color.vdBorderPrimary, lineWidth: VdBorderWidth.sm)
        )
        .frame(height: 72)
        .overlay(
            Text(label)
                .vdFont(VdFont.labelSmall)
                .foregroundStyle(Color.vdTextAccent)
                .multilineTextAlignment(.center)
        )
}

// ── Border width row ──────────────────────────────────────────
private func borderWidthRow(_ label: String, _ width: CGFloat) -> some View {
    HStack(spacing: VdSpacing.md) {
        Text(label)
            .vdFont(VdFont.labelSmall)
            .foregroundStyle(Color.vdTextSecondary)
            .frame(width: 120, alignment: .leading)
        RoundedRectangle(cornerRadius: VdRadius.sm)
            .strokeBorder(Color.vdBorderPrimary, lineWidth: width)
            .frame(height: 36)
    }
}

// ── Icon size box ─────────────────────────────────────────────
private func iconSizeBox(_ label: String, _ size: CGFloat) -> some View {
    VStack(spacing: VdSpacing.xs) {
        Image(systemName: "square.grid.2x2.fill")
            .font(.system(size: size))
            .foregroundStyle(Color.vdIconAccent)
        Text(label)
            .vdFont(VdFont.labelExtraSmall)
            .foregroundStyle(Color.vdTextTertiary)
            .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
}
