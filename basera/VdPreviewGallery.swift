import SwiftUI
import VroxalDesign

public struct VdPreviewGallery: View {

    @State private var email = ""
    @State private var notes = ""
    @State private var selectedCountry: String? = nil
    @State private var selectedDate: Date? = Date()
    @State private var agreed = true
    @State private var newsletter = false
    @State private var billingCycle = "monthly"
    @State private var selectedPlan = "pro"
    @State private var standaloneSelection = true
    @State private var otp = "12"
    @State private var showSnackbar = false

    private let countries = ["Nepal", "India", "United States", "Germany", "Australia"]

    public init() {}

    public var body: some View {
        List {
            header
                .listRowInsets(
                    EdgeInsets(
                        top: VdSpacing.sm,
                        leading: VdSpacing.lg,
                        bottom: VdSpacing.xs,
                        trailing: VdSpacing.lg
                    )
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            Section("Foundations") {
                previewLink(
                    title: "Typography",
                    subtitle: "Display, headline, title, label, and body styles",
                    symbol: "textformat.size"
                ) {
                    detailScreen(title: "Typography") {
                        typographySection
                    }
                }

                previewLink(
                    title: "Spacing & Scale",
                    subtitle: "Spacing, radius, border widths, and icon sizes",
                    symbol: "ruler"
                ) {
                    detailScreen(title: "Spacing & Scale") {
                        spacingSection
                    }
                }

                previewLink(
                    title: "Colors",
                    subtitle: "Content, background, and border tokens",
                    symbol: "paintpalette"
                ) {
                    detailScreen(title: "Colors") {
                        colorSection
                    }
                }
            }

            Section("Components") {
                previewLink(
                    title: "Actions",
                    subtitle: "Buttons and icon buttons",
                    symbol: "hand.tap"
                ) {
                    detailScreen(title: "Actions") {
                        actionsSection
                    }
                }

                previewLink(
                    title: "Display",
                    subtitle: "Badges and token display components",
                    symbol: "rectangle.grid.2x2"
                ) {
                    detailScreen(title: "Display") {
                        displaySection
                    }
                }

                previewLink(
                    title: "Forms",
                    subtitle: "Fields, selectors, checks, radios, and OTP",
                    symbol: "square.and.pencil"
                ) {
                    detailScreen(title: "Forms") {
                        formsSection
                    }
                }

                previewLink(
                    title: "Feedback",
                    subtitle: "Alert, snackbar, loading, skeleton, and empty state",
                    symbol: "bell.badge"
                ) {
                    feedbackDetailScreen
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.vdBackgroundDefaultBase)
        .navigationTitle("VD Preview")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: VdSpacing.sm) {
            Text("Vroxal Design System")
                .vdFont(.headlineSmall)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text("Components, colors, spacing, and typography from the vd-swift package")
                .vdFont(.bodyMedium)
                .foregroundStyle(Color.vdContentDefaultSecondary)
        }
        .padding(VdSpacing.md)
        .background(Color.vdBackgroundDefaultSecondary)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                .strokeBorder(
                    Color.vdBorderDefaultTertiary,
                    lineWidth: VdBorderWidth.sm
                )
        }
    }

    private var feedbackDetailScreen: some View {
        detailScreen(title: "Feedback") {
            feedbackSection
        }
        .vdSnackbar(
            isPresented: $showSnackbar,
            message: "Saved changes",
            action: "Undo",
            onAction: {},
            leadingIcon: "checkmark.circle.fill",
            closable: true
        )
    }

    private func detailScreen<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ScrollView {
            content()
                .padding(VdSpacing.lg)
        }
        .background(Color.vdBackgroundDefaultBase)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func previewLink<Destination: View>(
        title: String,
        subtitle: String,
        symbol: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(alignment: .top, spacing: VdSpacing.sm) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.vdContentPrimaryBase)
                    .frame(width: 22)

                VStack(alignment: .leading, spacing: VdSpacing.xs) {
                    Text(title)
                        .vdFont(.labelLarge)
                        .foregroundStyle(Color.vdContentDefaultBase)

                    Text(subtitle)
                        .vdFont(.bodySmall)
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, VdSpacing.xxs)
        }
    }

    private var typographySection: some View {
        section("Typography") {
            VStack(alignment: .leading, spacing: VdSpacing.md) {
                ForEach(typographyTokens) { token in
                    VStack(alignment: .leading, spacing: VdSpacing.xs) {
                        Text(token.id)
                            .vdFont(.labelSmall)
                            .foregroundStyle(Color.vdContentDefaultTertiary)

                        Text(token.sample)
                            .vdFont(token.style)
                            .foregroundStyle(Color.vdContentDefaultBase)
                    }
                }
            }
        }
    }

    private var spacingSection: some View {
        section("Spacing & Scale") {
            VStack(alignment: .leading, spacing: VdSpacing.lg) {
                tokenValueBlock(title: "Spacing", tokens: spacingTokens)
                tokenValueBlock(title: "Radius", tokens: radiusTokens)
                tokenValueBlock(title: "Border Width", tokens: borderWidthTokens)
                tokenValueBlock(title: "Icon Size", tokens: iconSizeTokens)
            }
        }
    }

    private var colorSection: some View {
        section("Colors") {
            VStack(alignment: .leading, spacing: VdSpacing.lg) {
                colorTokenBlock(title: "Content", tokens: contentColorTokens)
                colorTokenBlock(title: "Background", tokens: backgroundColorTokens)
                colorTokenBlock(title: "Border", tokens: borderColorTokens)
            }
        }
    }

    private var actionsSection: some View {
        section("Actions") {
            VStack(alignment: .leading, spacing: VdSpacing.lg) {
                VdButton(
                    "Primary Full Width",
                    color: .primary,
                    style: .solid,
                    size: .medium,
                    fullWidth: true,
                    leftIcon: "sparkles",
                    rightIcon: "arrow.right"
                ) {}

                HStack(spacing: VdSpacing.sm) {
                    VdButton("Neutral", color: .neutral, style: .subtle, size: .small) {}
                    VdButton("Outlined", color: .info, style: .outlined, size: .small) {}
                    VdButton("Ghost", color: .error, style: .transparent, size: .small) {}
                }

                HStack(spacing: VdSpacing.sm) {
                    VdIconButton(icon: "plus", color: .primary, style: .solid, size: .small, action: {})
                    VdIconButton(icon: "pencil", color: .primary, style: .subtle, size: .medium, action: {})
                    VdIconButton(icon: "trash", color: .neutral, style: .outlined, size: .large, rounded: true, action: {})
                    VdIconButton(icon: "arrow.clockwise", color: .primary, style: .transparent, size: .medium, isLoading: true, action: {})
                }
            }
        }
    }

    private var displaySection: some View {
        section("Display") {
            VStack(alignment: .leading, spacing: VdSpacing.md) {
                tokenFlow {
                    VdBadge("Primary", color: .primary, style: .solid)
                    VdBadge("Success", color: .success, style: .solid)
                    VdBadge("Error", color: .error, style: .solid)
                    VdBadge("Warning", color: .warning, style: .solid)
                    VdBadge("Info", color: .info, style: .solid)
                    VdBadge("Neutral", color: .neutral, style: .solid)
                    VdBadge("Primary", color: .primary, style: .subtle, size: .small)
                    VdBadge("Success", color: .success, style: .subtle, size: .small, rounded: true)
                }
            }
        }
    }

    private var formsSection: some View {
        section("Forms") {
            VStack(alignment: .leading, spacing: VdSpacing.lg) {
                VdTextField(
                    "Email",
                    text: $email,
                    placeholder: "you@example.com",
                    leadingIcon: "envelope",
                    helperText: "Use your work email",
                    trailingIcon: "xmark.circle.fill",
                    onTrailingAction: { email = "" }
                )

                VdTextArea(
                    text: $notes,
                    label: "Notes",
                    placeholder: "Write something...",
                    helperText: "Max 240 chars",
                    isOptional: true,
                    leadingIcon: "doc.text",
                    trailingIcon: "xmark.circle.fill",
                    onTrailingAction: { notes = "" },
                    characterLimit: 240
                )

                VdSelectField(
                    selection: $selectedCountry,
                    options: countries,
                    label: "Country",
                    placeholder: "Select a country",
                    helperText: "Required",
                    leadingIcon: "globe"
                )

                VdDateTimeField(
                    "Schedule",
                    selection: $selectedDate,
                    placeholder: "Pick date & time",
                    isOptional: true,
                    leadingIcon: "calendar",
                    helperText: "Native picker",
                    mode: .dateTime
                )

                HStack(alignment: .top, spacing: VdSpacing.lg) {
                    VStack(alignment: .leading, spacing: VdSpacing.sm) {
                        VdCheckbox(isChecked: $agreed, label: "Agree to terms", description: "Required")
                        VdCheckbox(isChecked: $newsletter, isIndeterminate: false, label: "Email updates")
                    }

                    VdRadioGroup(selection: $billingCycle) {
                        VdRadioOption(value: "monthly", label: "Monthly")
                        VdRadioOption(value: "yearly", label: "Yearly", description: "Save 20%")
                    }
                }

                VdSelectionCard(
                    selectionStyle: .checkbox,
                    isSelected: $standaloneSelection,
                    icon: "star",
                    title: "Standalone Selection Card",
                    description: "Single selectable card"
                )

                VdSelectionCardGroup(selection: $selectedPlan) {
                    VdSelectionCardOption(
                        value: "free",
                        icon: "sparkles",
                        title: "Free",
                        description: "Basic features"
                    )
                    VdSelectionCardOption(
                        value: "pro",
                        icon: "bolt.fill",
                        title: "Pro",
                        description: "Advanced features"
                    )
                }

                VdCodeInput(code: $otp, length: 6, state: .default)
            }
        }
    }

    private var feedbackSection: some View {
        section("Feedback") {
            VStack(alignment: .leading, spacing: VdSpacing.lg) {
                VdAlert(
                    color: .warning,
                    title: "Action required",
                    description: "Please review billing information.",
                    action: "Review",
                    actionInline: true,
                    closable: true,
                    onAction: {},
                    onClose: {}
                )

                VdSnackbar(
                    message: "Profile saved",
                    action: "Undo",
                    onAction: {},
                    leadingIcon: "checkmark.circle.fill",
                    closable: true,
                    onClose: {}
                )

                HStack(spacing: VdSpacing.md) {
                    VdLoadingState(style: .inline, title: "Loading", description: "Please wait")
                        .frame(maxWidth: .infinity)

                    VStack(spacing: VdSpacing.sm) {
                        VdSpinner(size: 24, color: .vdContentPrimaryBase)
                        Rectangle()
                            .fill(Color.vdBackgroundDefaultSecondary)
                            .frame(width: 120, height: 12)
                            .vdSkeleton(true)
                    }
                    .frame(maxWidth: .infinity)
                }

                VdEmptyState(
                    title: "No Items Found",
                    description: "Create a new item to get started.",
                    icon: "tray",
                    boxed: true,
                    actions: true,
                    primaryAction: true,
                    secondaryAction: true,
                    primaryActionTitle: "Create",
                    secondaryActionTitle: "Dismiss",
                    onPrimaryAction: {},
                    onSecondaryAction: {}
                )
                .frame(maxWidth: .infinity)

                VdButton("Show Snackbar", color: .info, style: .subtle, fullWidth: true) {
                    showSnackbar = true
                }
            }
        }
    }

    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: VdSpacing.md) {
            Text(title)
                .vdFont(.titleMedium)
                .foregroundStyle(Color.vdContentDefaultBase)

            content()
        }
        .padding(VdSpacing.md)
        .background(Color.vdBackgroundDefaultSecondary)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: VdRadius.lg, style: .continuous)
                .strokeBorder(Color.vdBorderDefaultTertiary, lineWidth: VdBorderWidth.sm)
        }
    }

    private func tokenValueBlock(title: String, tokens: [NumericToken]) -> some View {
        VStack(alignment: .leading, spacing: VdSpacing.sm) {
            Text(title)
                .vdFont(.labelLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            ForEach(tokens) { token in
                HStack(spacing: VdSpacing.sm) {
                    Text(token.id)
                        .vdFont(.bodySmall)
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                        .frame(width: 160, alignment: .leading)

                    Text("\(Int(token.value))")
                        .vdFont(.bodySmall)
                        .foregroundStyle(Color.vdContentDefaultBase)
                        .frame(width: 40, alignment: .leading)

                    RoundedRectangle(cornerRadius: VdRadius.full)
                        .fill(Color.vdBackgroundPrimaryBase)
                        .frame(width: max(token.value, 1), height: 8)

                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func colorTokenBlock(title: String, tokens: [ColorToken]) -> some View {
        VStack(alignment: .leading, spacing: VdSpacing.sm) {
            Text(title)
                .vdFont(.labelLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            LazyVGrid(columns: [
                GridItem(.flexible(minimum: 140), spacing: VdSpacing.sm),
                GridItem(.flexible(minimum: 140), spacing: VdSpacing.sm),
                GridItem(.flexible(minimum: 140), spacing: VdSpacing.sm)
            ], spacing: VdSpacing.sm) {
                ForEach(tokens) { token in
                    VStack(alignment: .leading, spacing: VdSpacing.xs) {
                        RoundedRectangle(cornerRadius: VdRadius.sm)
                            .fill(token.color)
                            .frame(height: 32)
                            .overlay {
                                RoundedRectangle(cornerRadius: VdRadius.sm)
                                    .strokeBorder(Color.vdBorderDefaultTertiary, lineWidth: VdBorderWidth.sm)
                            }

                        Text(token.id)
                            .vdFont(.labelExtraSmall)
                            .foregroundStyle(Color.vdContentDefaultSecondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(VdSpacing.xs)
                    .background(Color.vdBackgroundDefaultBase)
                    .clipShape(RoundedRectangle(cornerRadius: VdRadius.sm, style: .continuous))
                }
            }
        }
    }

    private func tokenFlow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: VdSpacing.sm) {
            content()
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var typographyTokens: [TypographyToken] {
        [
            .init(id: "Display/Large", style: .displayLarge, sample: "Display Large"),
            .init(id: "Display/Medium", style: .displayMedium, sample: "Display Medium"),
            .init(id: "Display/Small", style: .displaySmall, sample: "Display Small"),
            .init(id: "Headline/Large", style: .headlineLarge, sample: "Headline Large"),
            .init(id: "Headline/Medium", style: .headlineMedium, sample: "Headline Medium"),
            .init(id: "Headline/Small", style: .headlineSmall, sample: "Headline Small"),
            .init(id: "Title/Large", style: .titleLarge, sample: "Title Large"),
            .init(id: "Title/Medium", style: .titleMedium, sample: "Title Medium"),
            .init(id: "Title/Small", style: .titleSmall, sample: "Title Small"),
            .init(id: "Label/Large", style: .labelLarge, sample: "Label Large"),
            .init(id: "Label/Medium", style: .labelMedium, sample: "Label Medium"),
            .init(id: "Label/Small", style: .labelSmall, sample: "Label Small"),
            .init(id: "Label/ExtraSmall", style: .labelExtraSmall, sample: "Label ExtraSmall"),
            .init(id: "Body/ExtraLarge", style: .bodyExtraLarge, sample: "Body ExtraLarge"),
            .init(id: "Body/Large", style: .bodyLarge, sample: "Body Large"),
            .init(id: "Body/Medium", style: .bodyMedium, sample: "Body Medium"),
            .init(id: "Body/MediumItalic", style: .bodyMediumItalic, sample: "Body Medium Italic"),
            .init(id: "Body/Small", style: .bodySmall, sample: "Body Small"),
            .init(id: "Body/ExtraSmall", style: .bodyExtraSmall, sample: "Body ExtraSmall")
        ]
    }

    private var spacingTokens: [NumericToken] {
        [
            .init(id: "VdSpacing.s0", value: VdSpacing.s0),
            .init(id: "VdSpacing.s50", value: VdSpacing.s50),
            .init(id: "VdSpacing.s100", value: VdSpacing.s100),
            .init(id: "VdSpacing.s200", value: VdSpacing.s200),
            .init(id: "VdSpacing.s300", value: VdSpacing.s300),
            .init(id: "VdSpacing.s400", value: VdSpacing.s400),
            .init(id: "VdSpacing.s600", value: VdSpacing.s600),
            .init(id: "VdSpacing.s800", value: VdSpacing.s800),
            .init(id: "VdSpacing.s1000", value: VdSpacing.s1000),
            .init(id: "VdSpacing.s1200", value: VdSpacing.s1200),
            .init(id: "VdSpacing.s1600", value: VdSpacing.s1600),
            .init(id: "VdSpacing.s1800", value: VdSpacing.s1800),
            .init(id: "VdSpacing.s2400", value: VdSpacing.s2400),
            .init(id: "VdSpacing.s3000", value: VdSpacing.s3000),
            .init(id: "VdSpacing.neg50", value: VdSpacing.neg50),
            .init(id: "VdSpacing.neg100", value: VdSpacing.neg100),
            .init(id: "VdSpacing.neg200", value: VdSpacing.neg200),
            .init(id: "VdSpacing.neg300", value: VdSpacing.neg300),
            .init(id: "VdSpacing.neg400", value: VdSpacing.neg400),
            .init(id: "VdSpacing.neg600", value: VdSpacing.neg600),
            .init(id: "VdSpacing.none", value: VdSpacing.none),
            .init(id: "VdSpacing.xxs", value: VdSpacing.xxs),
            .init(id: "VdSpacing.xs", value: VdSpacing.xs),
            .init(id: "VdSpacing.sm", value: VdSpacing.sm),
            .init(id: "VdSpacing.smMd", value: VdSpacing.smMd),
            .init(id: "VdSpacing.md", value: VdSpacing.md),
            .init(id: "VdSpacing.lg", value: VdSpacing.lg),
            .init(id: "VdSpacing.xl", value: VdSpacing.xl),
            .init(id: "VdSpacing.xxl", value: VdSpacing.xxl),
            .init(id: "VdSpacing.xxxl", value: VdSpacing.xxxl),
            .init(id: "VdSpacing.huge", value: VdSpacing.huge)
        ]
    }

    private var radiusTokens: [NumericToken] {
        [
            .init(id: "VdRadius.none", value: VdRadius.none),
            .init(id: "VdRadius.xs", value: VdRadius.xs),
            .init(id: "VdRadius.sm", value: VdRadius.sm),
            .init(id: "VdRadius.md", value: VdRadius.md),
            .init(id: "VdRadius.lg", value: VdRadius.lg),
            .init(id: "VdRadius.xl", value: VdRadius.xl),
            .init(id: "VdRadius.xxl", value: VdRadius.xxl),
            .init(id: "VdRadius.xxxl", value: VdRadius.xxxl),
            .init(id: "VdRadius.full", value: VdRadius.full)
        ]
    }

    private var borderWidthTokens: [NumericToken] {
        [
            .init(id: "VdBorderWidth.none", value: VdBorderWidth.none),
            .init(id: "VdBorderWidth.sm", value: VdBorderWidth.sm),
            .init(id: "VdBorderWidth.md", value: VdBorderWidth.md),
            .init(id: "VdBorderWidth.lg", value: VdBorderWidth.lg),
            .init(id: "VdBorderWidth.xl", value: VdBorderWidth.xl)
        ]
    }

    private var iconSizeTokens: [NumericToken] {
        [
            .init(id: "VdIconSize.xs", value: VdIconSize.xs),
            .init(id: "VdIconSize.sm", value: VdIconSize.sm),
            .init(id: "VdIconSize.md", value: VdIconSize.md),
            .init(id: "VdIconSize.lg", value: VdIconSize.lg),
            .init(id: "VdIconSize.xl", value: VdIconSize.xl)
        ]
    }

    private var contentColorTokens: [ColorToken] {
        [
            .init(id: "vdContentDefaultBase", color: .vdContentDefaultBase),
            .init(id: "vdContentDefaultSecondary", color: .vdContentDefaultSecondary),
            .init(id: "vdContentDefaultTertiary", color: .vdContentDefaultTertiary),
            .init(id: "vdContentDefaultDisabled", color: .vdContentDefaultDisabled),
            .init(id: "vdContentDefaultAlwaysLight", color: .vdContentDefaultAlwaysLight),
            .init(id: "vdContentDefaultAlwaysDark", color: .vdContentDefaultAlwaysDark),
            .init(id: "vdContentPrimaryBase", color: .vdContentPrimaryBase),
            .init(id: "vdContentPrimarySecondary", color: .vdContentPrimarySecondary),
            .init(id: "vdContentPrimaryTertiary", color: .vdContentPrimaryTertiary),
            .init(id: "vdContentPrimaryOnBase", color: .vdContentPrimaryOnBase),
            .init(id: "vdContentPrimaryOnSecondary", color: .vdContentPrimaryOnSecondary),
            .init(id: "vdContentPrimaryOnTertiary", color: .vdContentPrimaryOnTertiary),
            .init(id: "vdContentSuccessBase", color: .vdContentSuccessBase),
            .init(id: "vdContentSuccessSecondary", color: .vdContentSuccessSecondary),
            .init(id: "vdContentSuccessTertiary", color: .vdContentSuccessTertiary),
            .init(id: "vdContentSuccessOnBase", color: .vdContentSuccessOnBase),
            .init(id: "vdContentSuccessOnSecondary", color: .vdContentSuccessOnSecondary),
            .init(id: "vdContentSuccessOnTertiary", color: .vdContentSuccessOnTertiary),
            .init(id: "vdContentErrorBase", color: .vdContentErrorBase),
            .init(id: "vdContentErrorSecondary", color: .vdContentErrorSecondary),
            .init(id: "vdContentErrorTertiary", color: .vdContentErrorTertiary),
            .init(id: "vdContentErrorOnBase", color: .vdContentErrorOnBase),
            .init(id: "vdContentErrorOnSecondary", color: .vdContentErrorOnSecondary),
            .init(id: "vdContentErrorOnTertiary", color: .vdContentErrorOnTertiary),
            .init(id: "vdContentWarningBase", color: .vdContentWarningBase),
            .init(id: "vdContentWarningSecondary", color: .vdContentWarningSecondary),
            .init(id: "vdContentWarningTertiary", color: .vdContentWarningTertiary),
            .init(id: "vdContentWarningOnBase", color: .vdContentWarningOnBase),
            .init(id: "vdContentWarningOnSecondary", color: .vdContentWarningOnSecondary),
            .init(id: "vdContentWarningOnTertiary", color: .vdContentWarningOnTertiary),
            .init(id: "vdContentInfoBase", color: .vdContentInfoBase),
            .init(id: "vdContentInfoSecondary", color: .vdContentInfoSecondary),
            .init(id: "vdContentInfoTertiary", color: .vdContentInfoTertiary),
            .init(id: "vdContentInfoOnBase", color: .vdContentInfoOnBase),
            .init(id: "vdContentInfoOnSecondary", color: .vdContentInfoOnSecondary),
            .init(id: "vdContentInfoOnTertiary", color: .vdContentInfoOnTertiary),
            .init(id: "vdContentNeutralBase", color: .vdContentNeutralBase),
            .init(id: "vdContentNeutralSecondary", color: .vdContentNeutralSecondary),
            .init(id: "vdContentNeutralTertiary", color: .vdContentNeutralTertiary),
            .init(id: "vdContentNeutralOnBase", color: .vdContentNeutralOnBase),
            .init(id: "vdContentNeutralOnSecondary", color: .vdContentNeutralOnSecondary),
            .init(id: "vdContentNeutralOnTertiary", color: .vdContentNeutralOnTertiary)
        ]
    }

    private var backgroundColorTokens: [ColorToken] {
        [
            .init(id: "vdBackgroundDefaultBase", color: .vdBackgroundDefaultBase),
            .init(id: "vdBackgroundDefaultSecondary", color: .vdBackgroundDefaultSecondary),
            .init(id: "vdBackgroundDefaultTertiary", color: .vdBackgroundDefaultTertiary),
            .init(id: "vdBackgroundDefaultDisabled", color: .vdBackgroundDefaultDisabled),
            .init(id: "vdBackgroundDefaultAlwaysLight", color: .vdBackgroundDefaultAlwaysLight),
            .init(id: "vdBackgroundDefaultAlwaysDark", color: .vdBackgroundDefaultAlwaysDark),
            .init(id: "vdBackgroundPrimaryBase", color: .vdBackgroundPrimaryBase),
            .init(id: "vdBackgroundPrimaryBaseHover", color: .vdBackgroundPrimaryBaseHover),
            .init(id: "vdBackgroundPrimarySecondary", color: .vdBackgroundPrimarySecondary),
            .init(id: "vdBackgroundPrimarySecondaryHover", color: .vdBackgroundPrimarySecondaryHover),
            .init(id: "vdBackgroundPrimaryTertiary", color: .vdBackgroundPrimaryTertiary),
            .init(id: "vdBackgroundPrimaryTertiaryHover", color: .vdBackgroundPrimaryTertiaryHover),
            .init(id: "vdBackgroundSuccessBase", color: .vdBackgroundSuccessBase),
            .init(id: "vdBackgroundSuccessBaseHover", color: .vdBackgroundSuccessBaseHover),
            .init(id: "vdBackgroundSuccessSecondary", color: .vdBackgroundSuccessSecondary),
            .init(id: "vdBackgroundSuccessSecondaryHover", color: .vdBackgroundSuccessSecondaryHover),
            .init(id: "vdBackgroundSuccessTertiary", color: .vdBackgroundSuccessTertiary),
            .init(id: "vdBackgroundSuccessTertiaryHover", color: .vdBackgroundSuccessTertiaryHover),
            .init(id: "vdBackgroundErrorBase", color: .vdBackgroundErrorBase),
            .init(id: "vdBackgroundErrorBaseHover", color: .vdBackgroundErrorBaseHover),
            .init(id: "vdBackgroundErrorSecondary", color: .vdBackgroundErrorSecondary),
            .init(id: "vdBackgroundErrorSecondaryHover", color: .vdBackgroundErrorSecondaryHover),
            .init(id: "vdBackgroundErrorTertiary", color: .vdBackgroundErrorTertiary),
            .init(id: "vdBackgroundErrorTertiaryHover", color: .vdBackgroundErrorTertiaryHover),
            .init(id: "vdBackgroundWarningBase", color: .vdBackgroundWarningBase),
            .init(id: "vdBackgroundWarningBaseHover", color: .vdBackgroundWarningBaseHover),
            .init(id: "vdBackgroundWarningSecondary", color: .vdBackgroundWarningSecondary),
            .init(id: "vdBackgroundWarningSecondaryHover", color: .vdBackgroundWarningSecondaryHover),
            .init(id: "vdBackgroundWarningTertiary", color: .vdBackgroundWarningTertiary),
            .init(id: "vdBackgroundWarningTertiaryHover", color: .vdBackgroundWarningTertiaryHover),
            .init(id: "vdBackgroundInfoBase", color: .vdBackgroundInfoBase),
            .init(id: "vdBackgroundInfoBaseHover", color: .vdBackgroundInfoBaseHover),
            .init(id: "vdBackgroundInfoSecondary", color: .vdBackgroundInfoSecondary),
            .init(id: "vdBackgroundInfoSecondaryHover", color: .vdBackgroundInfoSecondaryHover),
            .init(id: "vdBackgroundInfoTertiary", color: .vdBackgroundInfoTertiary),
            .init(id: "vdBackgroundInfoTertiaryHover", color: .vdBackgroundInfoTertiaryHover),
            .init(id: "vdBackgroundNeutralBase", color: .vdBackgroundNeutralBase),
            .init(id: "vdBackgroundNeutralBaseHover", color: .vdBackgroundNeutralBaseHover),
            .init(id: "vdBackgroundNeutralSecondary", color: .vdBackgroundNeutralSecondary),
            .init(id: "vdBackgroundNeutralSecondaryHover", color: .vdBackgroundNeutralSecondaryHover),
            .init(id: "vdBackgroundNeutralTertiary", color: .vdBackgroundNeutralTertiary),
            .init(id: "vdBackgroundNeutralTertiaryHover", color: .vdBackgroundNeutralTertiaryHover),
            .init(id: "vdBackgroundOverlayBase", color: .vdBackgroundOverlayBase)
        ]
    }

    private var borderColorTokens: [ColorToken] {
        [
            .init(id: "vdBorderDefaultBase", color: .vdBorderDefaultBase),
            .init(id: "vdBorderDefaultSecondary", color: .vdBorderDefaultSecondary),
            .init(id: "vdBorderDefaultTertiary", color: .vdBorderDefaultTertiary),
            .init(id: "vdBorderDefaultDisabled", color: .vdBorderDefaultDisabled),
            .init(id: "vdBorderPrimaryBase", color: .vdBorderPrimaryBase),
            .init(id: "vdBorderPrimarySecondary", color: .vdBorderPrimarySecondary),
            .init(id: "vdBorderPrimaryTertiary", color: .vdBorderPrimaryTertiary),
            .init(id: "vdBorderSuccessBase", color: .vdBorderSuccessBase),
            .init(id: "vdBorderSuccessSecondary", color: .vdBorderSuccessSecondary),
            .init(id: "vdBorderSuccessTertiary", color: .vdBorderSuccessTertiary),
            .init(id: "vdBorderErrorBase", color: .vdBorderErrorBase),
            .init(id: "vdBorderErrorSecondary", color: .vdBorderErrorSecondary),
            .init(id: "vdBorderErrorTertiary", color: .vdBorderErrorTertiary),
            .init(id: "vdBorderWarningBase", color: .vdBorderWarningBase),
            .init(id: "vdBorderWarningSecondary", color: .vdBorderWarningSecondary),
            .init(id: "vdBorderWarningTertiary", color: .vdBorderWarningTertiary),
            .init(id: "vdBorderInfoBase", color: .vdBorderInfoBase),
            .init(id: "vdBorderInfoSecondary", color: .vdBorderInfoSecondary),
            .init(id: "vdBorderInfoTertiary", color: .vdBorderInfoTertiary),
            .init(id: "vdBorderNeutralBase", color: .vdBorderNeutralBase),
            .init(id: "vdBorderNeutralSecondary", color: .vdBorderNeutralSecondary),
            .init(id: "vdBorderNeutralTertiary", color: .vdBorderNeutralTertiary)
        ]
    }
}

private struct TypographyToken: Identifiable {
    let id: String
    let style: VdTextStyle
    let sample: String
}

private struct NumericToken: Identifiable {
    let id: String
    let value: CGFloat
}

private struct ColorToken: Identifiable {
    let id: String
    let color: Color
}

#Preview("VdPreviewGallery") {
    NavigationStack {
        VdPreviewGallery()
    }
}
