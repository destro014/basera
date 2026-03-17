// VdComponentGallery.swift — Vroxal Design System
// ─────────────────────────────────────────────────────────────
// Component gallery for the consuming app.
// Mirrors the structure of VdPreviewGallery (token gallery).
//
// Open in Xcode and enable the canvas:
//   Editor → Canvas  (⌥⌘↩)
//
// SECTIONS
//   Actions    — VdButton · VdIconButton
//   Display    — VdBadge
//   Forms      — VdTextField · VdTextArea · VdSelectField
//              · VdCodeInput · VdCheckbox · VdRadioButton
//              · VdSelectionCard
//   Feedback   — VdAlert · VdSnackbar · VdLoadingState
// ─────────────────────────────────────────────────────────────

import SwiftUI
import VroxalDesign

// ═════════════════════════════════════════════════════════════
// MARK: — Entry point
// ═════════════════════════════════════════════════════════════

struct VdPreviewApp: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Actions") {
                    NavigationLink("VdButton") { VdButtonGallery() }
                    NavigationLink("VdIconButton") { VdIconButtonGallery() }
                }
                Section("Display") {
                    NavigationLink("VdBadge") { VdBadgeGallery() }
                }
                Section("Forms") {
                    NavigationLink("VdTextField") { VdTextFieldGallery() }
                    NavigationLink("VdTextArea") { VdTextAreaGallery() }
                    NavigationLink("VdSelectField") { VdSelectFieldGallery() }
                    NavigationLink("VdCodeInput") { VdCodeInputGallery() }
                    NavigationLink("VdCheckbox") { VdCheckboxGallery() }
                    NavigationLink("VdRadioButton") { VdRadioButtonGallery() }
                    NavigationLink("VdSelectionCard") { VdSelectionCardGallery() }
                }
                Section("Feedback") {
                    NavigationLink("VdAlert") { VdAlertGallery() }
                    NavigationLink("VdSnackbar") { VdSnackbarGallery() }
                    NavigationLink("VdLoadingState") { VdLoadingStateGallery() }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.vdBackgroundDefaultBase)
            .navigationTitle("Components")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview("Vd Component Gallery") {
    VdPreviewApp()
}

// ═════════════════════════════════════════════════════════════
// MARK: — VdButton
// ═════════════════════════════════════════════════════════════

private struct VdButtonGallery: View {
    var body: some View {
        galleryScroll {

            gallerySection("Styles × Primary") {
                VdButton("Solid",       style: .solid,       action: {})
                VdButton("Subtle",      style: .subtle,      action: {})
                VdButton("Outlined",    style: .outlined,    action: {})
                VdButton("Transparent", style: .transparent, action: {})
            }

            gallerySection("Colors") {
                LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: VdSpacing.sm) {
                    VdButton("Primary", color: .primary, action: {})
                    VdButton("Neutral", color: .neutral, action: {})
                    VdButton("Success", color: .success, action: {})
                    VdButton("Error",   color: .error,   action: {})
                    VdButton("Warning", color: .warning, action: {})
                    VdButton("Info",    color: .info,    action: {})
                }
            }

            gallerySection("Sizes") {
                VdButton("Small",  size: .small,  action: {})
                VdButton("Medium", size: .medium, action: {})
                VdButton("Large",  size: .large,  action: {})
            }

            gallerySection("Rounded") {
                HStack {
                    VdButton("Rounded", rounded: true, action: {})
                    VdButton("Square",  rounded: false, action: {})
                }
            }

            gallerySection("Icons") {
                VdButton("Left icon",  leftIcon: "arrow.left",  action: {})
                VdButton("Right icon", rightIcon: "arrow.right", action: {})
                VdButton("Both",       leftIcon: "lock", rightIcon: "chevron.right", action: {})
            }

            gallerySection("States") {
                VdButton("Loading",  isLoading: true,  action: {})
//                VdButton("Disabled", isDisabled: true, action: {})
            }
        }
        .navigationTitle("VdButton")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — VdIconButton
// ═════════════════════════════════════════════════════════════

private struct VdIconButtonGallery: View {
    var body: some View {
        galleryScroll {

            gallerySection("Styles — Primary") {
                HStack(spacing: VdSpacing.sm) {
                    VdIconButton(icon: "square.grid.2x2", style: .solid,       action: {})
                    VdIconButton(icon: "square.grid.2x2", style: .subtle,      action: {})
                    VdIconButton(icon: "square.grid.2x2", style: .outlined,    action: {})
                    VdIconButton(icon: "square.grid.2x2", style: .transparent, action: {})
                }
            }

            gallerySection("Styles — Neutral") {
                HStack(spacing: VdSpacing.sm) {
                    VdIconButton(icon: "square.grid.2x2", color: .neutral, style: .solid,       action: {})
                    VdIconButton(icon: "square.grid.2x2", color: .neutral, style: .subtle,      action: {})
                    VdIconButton(icon: "square.grid.2x2", color: .neutral, style: .outlined,    action: {})
                    VdIconButton(icon: "square.grid.2x2", color: .neutral, style: .transparent, action: {})
                }
            }

            gallerySection("Sizes") {
                HStack(alignment: .bottom, spacing: VdSpacing.md) {
                    VStack {
                        VdIconButton(icon: "plus", size: .small,  action: {})
                        Text("Small").vdFontInline(VdFont.labelSmall).foregroundStyle(Color.vdContentDefaultTertiary)
                    }
                    VStack {
                        VdIconButton(icon: "plus", size: .medium, action: {})
                        Text("Medium").vdFontInline(VdFont.labelSmall).foregroundStyle(Color.vdContentDefaultTertiary)
                    }
                    VStack {
                        VdIconButton(icon: "plus", size: .large,  action: {})
                        Text("Large").vdFontInline(VdFont.labelSmall).foregroundStyle(Color.vdContentDefaultTertiary)
                    }
                }
            }

            gallerySection("Rounded") {
                HStack(spacing: VdSpacing.sm) {
                    VdIconButton(icon: "heart",    style: .solid,       rounded: true, action: {})
                    VdIconButton(icon: "star",     style: .subtle,      rounded: true, action: {})
                    VdIconButton(icon: "bookmark", style: .outlined,    rounded: true, action: {})
                    VdIconButton(icon: "ellipsis", color: .neutral, style: .transparent, rounded: true, action: {})
                }
            }

            gallerySection("States") {
                HStack(spacing: VdSpacing.sm) {
                    VdIconButton(icon: "arrow.clockwise", isLoading: true,  action: {})
                    VdIconButton(icon: "trash",           isDisabled: true, action: {})
                }
            }
        }
        .navigationTitle("VdIconButton")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — VdBadge
// ═════════════════════════════════════════════════════════════

private struct VdBadgeGallery: View {
    var body: some View {
        galleryScroll {

            gallerySection("Solid — all colors") {
                FlowLayout(spacing: VdSpacing.sm) {
                    VdBadge("Primary", color: .primary)
                    VdBadge("Neutral", color: .neutral)
                    VdBadge("Success", color: .success)
                    VdBadge("Error",   color: .error)
                    VdBadge("Warning", color: .warning)
                    VdBadge("Info",    color: .info)
                }
            }

            gallerySection("Subtle — all colors") {
                FlowLayout(spacing: VdSpacing.sm) {
                    VdBadge("Primary", color: .primary, style: .subtle)
                    VdBadge("Neutral", color: .neutral, style: .subtle)
                    VdBadge("Success", color: .success, style: .subtle)
                    VdBadge("Error",   color: .error,   style: .subtle)
                    VdBadge("Warning", color: .warning, style: .subtle)
                    VdBadge("Info",    color: .info,    style: .subtle)
                }
            }

            gallerySection("Sizes") {
                HStack(alignment: .center, spacing: VdSpacing.sm) {
                    VdBadge("Medium", size: .medium)
                    VdBadge("Small",  size: .small)
                }
            }

            gallerySection("Rounded") {
                HStack(spacing: VdSpacing.sm) {
                    VdBadge("Rounded", rounded: true)
                    VdBadge("Square",  rounded: false)
                }
            }
        }
        .navigationTitle("VdBadge")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — VdTextField
// ═════════════════════════════════════════════════════════════

private struct VdTextFieldGallery: View {
    @State private var text = ""

    var body: some View {
        galleryScroll {

            gallerySection("Default") {
                VdTextField("Label",
                    text: .constant(""),
                    placeholder: "Placeholder",
                    state: .default,
                    leadingIcon: "envelope",
                    helperText: "Help or instruction text")
            }

            gallerySection("With value") {
                VdTextField("Email",
                    text: .constant("hello@vroxal.com"),
                    state: .default,
                    leadingIcon: "envelope")
            }

            gallerySection("Disabled") {
                VdTextField("Label",
                    text: .constant(""),
                    placeholder: "Placeholder",
                    state: .disabled,
                    leadingIcon: "lock",
                    helperText: "This field is disabled")
            }

            gallerySection("Error") {
                VdTextField("Email",
                    text: .constant("bad@"),
                    state: .error,
                    leadingIcon: "envelope",
                    helperText: "Enter a valid email address")
            }

            gallerySection("Success") {
                VdTextField("Email",
                    text: .constant("hello@vroxal.com"),
                    state: .success,
                    leadingIcon: "envelope",
                    helperText: "Looks good!")
            }

            gallerySection("Warning") {
                VdTextField("Email",
                    text: .constant("test@"),
                    state: .warning,
                    leadingIcon: "envelope",
                    helperText: "Double-check this address")
            }

            gallerySection("Interactive") {
                VdTextField("Your name",
                    text: $text,
                    placeholder: "Enter your name",
                    state: .default,
                    characterLimit: 40)
            }
        }
        .navigationTitle("VdTextField")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — VdTextArea
// ═════════════════════════════════════════════════════════════

private struct VdTextAreaGallery: View {
    @State private var text = ""

    var body: some View {
        galleryScroll {

            gallerySection("Default") {
                VdTextArea(text: .constant(""),
                    label: "Label",
                    placeholder: "Placeholder",
                    helperText: "Help or instruction text",
                    isOptional: true,
                    leadingIcon: "text.alignleft")
            }

            gallerySection("With value") {
                VdTextArea(text: .constant("Nothing more exciting happening here in terms of content, but just filling up the space."),
                    label: "Bio",
                    leadingIcon: "text.alignleft",
                    characterLimit: 250)
            }

            gallerySection("Error") {
                VdTextArea(text: .constant(""),
                    label: "Notes",
                    helperText: "This field is required",
                    state: .error)
            }

            gallerySection("Success") {
                VdTextArea(text: .constant("Looking great!"),
                    label: "Notes",
                    helperText: "Saved successfully",
                    state: .success)
            }

            gallerySection("Disabled") {
                VdTextArea(text: .constant(""),
                    label: "Notes",
                    placeholder: "Placeholder",
                    helperText: "This field is disabled",
                    state: .disabled)
            }

            gallerySection("Interactive — live counter") {
                VdTextArea(text: $text,
                    label: "Message",
                    placeholder: "Write something...",
                    helperText: text.isEmpty ? "Required" : nil,
                    characterLimit: 200)
            }
        }
        .navigationTitle("VdTextArea")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — VdSelectField
// ═════════════════════════════════════════════════════════════

private struct VdSelectFieldGallery: View {
    @State private var country:  String? = nil
    @State private var currency: String? = nil

    private let countries  = ["Nepal", "India", "United States", "United Kingdom", "Australia", "Germany"]
    private let currencies = ["USD ($)", "EUR (€)", "GBP (£)", "NPR (₨)", "INR (₹)"]

    var body: some View {
        galleryScroll {

            gallerySection("Default") {
                VdSelectField(selection: .constant(nil),
                    options: countries,
                    label: "Country",
                    placeholder: "Select a country",
                    helperText: "Help or instruction text",
                    isOptional: true,
                    leadingIcon: "globe")
            }

            gallerySection("With value") {
                VdSelectField(selection: .constant("Nepal"),
                    options: countries,
                    label: "Country",
                    leadingIcon: "globe")
            }

            gallerySection("Error") {
                VdSelectField(selection: .constant(nil),
                    options: countries,
                    label: "Country",
                    placeholder: "Select a country",
                    helperText: "Please select a valid option",
                    leadingIcon: "globe",
                    state: .error)
            }

            gallerySection("Success") {
                VdSelectField(selection: .constant("Nepal"),
                    options: countries,
                    label: "Country",
                    helperText: "Great choice!",
                    leadingIcon: "globe",
                    state: .success)
            }

            gallerySection("Warning") {
                VdSelectField(selection: .constant("Nepal"),
                    options: countries,
                    label: "Country",
                    helperText: "Limited availability in this region",
                    leadingIcon: "globe",
                    state: .warning)
            }

            gallerySection("Disabled") {
                VdSelectField(selection: .constant(nil),
                    options: countries,
                    label: "Country",
                    placeholder: "Select a country",
                    helperText: "This field is disabled",
                    state: .disabled)
            }

            gallerySection("Interactive") {
                VdSelectField(selection: $country,
                    options: countries,
                    label: "Country",
                    placeholder: "Select your country",
                    helperText: country == nil ? "Required" : nil,
                    leadingIcon: "globe",
                    state: country == nil ? .default : .success)

                VdSelectField(selection: $currency,
                    options: currencies,
                    label: "Currency",
                    placeholder: "Select currency",
                    helperText: "Used for billing",
                    leadingIcon: "banknote")
            }
        }
        .navigationTitle("VdSelectField")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — VdCodeInput
// ═════════════════════════════════════════════════════════════

private struct VdCodeInputGallery: View {
    @State private var otp4 = ""
    @State private var otp6 = ""

    var body: some View {
        galleryScroll {

            gallerySection("4-digit") {
                VdCodeInput(code: $otp4, length: 4)
            }

            gallerySection("6-digit") {
                VdCodeInput(code: $otp6, length: 6)
            }

            gallerySection("Partially filled") {
                VdCodeInput(code: .constant("123"), length: 6)
            }

            gallerySection("Fully filled") {
                VdCodeInput(code: .constant("123456"), length: 6)
            }

            gallerySection("Error state") {
                VdCodeInput(code: .constant("12"), length: 6, state: .error)
            }

            gallerySection("Disabled state") {
                VdCodeInput(code: .constant("48"), length: 6, state: .disabled)
            }

            gallerySection("Custom length — 8 digit") {
                VdCodeInput(code: .constant(""), length: 8)
            }
        }
        .navigationTitle("VdCodeInput")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — VdCheckbox
// ═════════════════════════════════════════════════════════════

private struct VdCheckboxGallery: View {
    @State private var checked1  = false
    @State private var checked2  = true
    @State private var selectAll = false
    @State private var items     = [false, true, false, false]

    var body: some View {
        galleryScroll {

            gallerySection("States") {
                HStack(spacing: VdSpacing.xl) {
                    VStack(alignment: .leading, spacing: VdSpacing.sm) {
                        VdCheckbox(isChecked: .constant(false), label: "Unchecked")
                        VdCheckbox(isChecked: .constant(true), label: "Checked")
                    }
                    VStack(alignment: .leading, spacing: VdSpacing.sm) {
                        VdCheckbox(isChecked: .constant(false), label: "Disabled", isDisabled: true)
                        VdCheckbox(isChecked: .constant(true), label: "Disabled", isDisabled: true)
                    }
                }
            }

            gallerySection("Interactive — toggle") {
                VdCheckbox(isChecked: $checked1, label: "Receive marketing emails")
                VdCheckbox(isChecked: $checked2, label: "Agree to terms and conditions")
            }

            gallerySection("Select all pattern") {
                VStack(alignment: .leading, spacing: VdSpacing.sm) {
                    VdCheckbox(isChecked: $selectAll, label: "Select all")
                        .onChange(of: selectAll) { newValue in
                            items = items.map { _ in newValue }
                        }
                    Divider()
                    ForEach(0..<items.count, id: \.self) { i in
                        VdCheckbox(isChecked: $items[i], label: "Option \(i + 1)")
                    }
                }
            }
        }
        .navigationTitle("VdCheckbox")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — VdRadioButton
// ═════════════════════════════════════════════════════════════

private struct VdRadioButtonGallery: View {
    @State private var plan      = "starter"
    @State private var frequency = "monthly"

    var body: some View {
        galleryScroll {

            gallerySection("Standalone states") {
                HStack(spacing: VdSpacing.xl) {
                    VStack(alignment: .leading, spacing: VdSpacing.sm) {
                        VdRadioButton(isSelected: .constant(false), label: "Unselected")
                        VdRadioButton(isSelected: .constant(true), label: "Selected")
                    }
                    VStack(alignment: .leading, spacing: VdSpacing.sm) {
                        VdRadioButton(isSelected: .constant(false), label: "Disabled", isDisabled: true)
                        VdRadioButton(isSelected: .constant(true), label: "Disabled", isDisabled: true)
                    }
                }
            }

            gallerySection("VdRadioGroup — plan") {
                VdRadioGroup(selection: $plan) {
                    VdRadioOption(value: "starter", label: "Starter")
                    VdRadioOption(value: "pro", label: "Pro")
                    VdRadioOption(value: "enterprise", label: "Enterprise")
                }
            }

            gallerySection("VdRadioGroup — billing") {
                VdRadioGroup(selection: $frequency) {
                    VdRadioOption(value: "monthly", label: "Monthly")
                    VdRadioOption(value: "annually", label: "Annually")
                }
            }
        }
        .navigationTitle("VdRadioButton")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — VdSelectionCard
// ═════════════════════════════════════════════════════════════

private struct VdSelectionCardGallery: View {
    @State private var checkA    = false
    @State private var checkB    = true
    @State private var checkC    = false
    @State private var plan      = "pro"

    var body: some View {
        galleryScroll {

            gallerySection("Checkbox mode") {
                VStack(spacing: VdSpacing.sm) {
                    VdSelectionCard(selectionStyle: .checkbox,
                        isSelected: $checkA,
                        icon: "bolt",
                        title: "Fast delivery",
                        description: "Arrive within 24 hours")
                    VdSelectionCard(selectionStyle: .checkbox,
                        isSelected: $checkB,
                        icon: "shield",
                        title: "Extended warranty",
                        description: "Coverage for 2 years")
                    VdSelectionCard(selectionStyle: .checkbox,
                        isSelected: $checkC,
                        icon: "gift",
                        title: "Gift wrap",
                        description: "Add a personalised message")
                }
            }

            gallerySection("Radio mode — VdSelectionCardGroup") {
                VdSelectionCardGroup(selection: $plan) {
                    VdSelectionCardOption(value: "starter",
                        icon: "leaf",
                        title: "Starter",
                        description: "For small teams")
                    VdSelectionCardOption(value: "pro",
                        icon: "star",
                        title: "Pro",
                        description: "For growing businesses")
                    VdSelectionCardOption(value: "enterprise",
                        icon: "building.2",
                        title: "Enterprise",
                        description: "Custom pricing")
                }
            }
        }
        .navigationTitle("VdSelectionCard")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — VdAlert
// ═════════════════════════════════════════════════════════════

private struct VdAlertGallery: View {
    @State private var showPrimary = true
    @State private var showError   = true

    var body: some View {
        galleryScroll {

            gallerySection("All colors — default style") {
                VStack(spacing: VdSpacing.sm) {
                    VdAlert(color: .primary, title: "Primary",
                        description: "An informational alert for brand-level messages.")
                    VdAlert(color: .neutral, title: "Neutral",
                        description: "A neutral alert for general information.")
                    VdAlert(color: .success, title: "Success",
                        description: "Operation completed successfully.")
                    VdAlert(color: .error, title: "Error",
                        description: "Something went wrong. Please try again.")
                    VdAlert(color: .warning, title: "Warning",
                        description: "This action cannot be undone.")
                    VdAlert(color: .info, title: "Info",
                        description: "Your session will expire in 5 minutes.")
                }
            }

            gallerySection("With action — stacked") {
                VdAlert(color: .error,
                    title: "Upload failed",
                    description: "File size exceeds the 10 MB limit.",
                    action: "Try again",
                    onAction: {})
            }

            gallerySection("With action — inline") {
                VdAlert(color: .info,
                    title: "Update available",
                    description: "Version 2.1 is ready to install.",
                    action: "Install now",
                    actionInline: true,
                    onAction: {})
            }

            gallerySection("Closable") {
                if showPrimary {
                    VdAlert(color: .primary,
                        title: "Welcome back!",
                        description: "You have 3 unread notifications.",
                        closable: true,
                        onClose: { showPrimary = false })
                }
                if showError {
                    VdAlert(color: .error,
                        title: "Payment failed",
                        description: "Please update your payment method.",
                        action: "Update card",
                        closable: true,
                        onAction: {},
                        onClose: { showError = false })
                }
                if !showPrimary && !showError {
                    VdButton("Reset", style: .outlined, action: {
                        showPrimary = true
                        showError   = true
                    })
                }
            }
        }
        .navigationTitle("VdAlert")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — VdSnackbar
// ═════════════════════════════════════════════════════════════

private struct VdSnackbarGallery: View {
    @State private var showBasic    = false
    @State private var showWithIcon = false
    @State private var showAction   = false
    @State private var showClose    = false
    @State private var showLong     = false

    var body: some View {
        galleryScroll {
            gallerySection("Snackbar triggers") {
                VStack(spacing: VdSpacing.sm) {
                    VdButton("Show basic snackbar", style: .outlined, action: { showBasic = true })
                    VdButton("Show with icon",      style: .outlined, action: { showWithIcon = true })
                    VdButton("Show with action",    style: .outlined, action: { showAction = true })
                    VdButton("Show with close",     style: .outlined, action: { showClose = true })
                    VdButton("Show long message",   style: .outlined, action: { showLong = true })
                }
            }

            gallerySection("Usage note") {
                Text("Snackbars appear at the bottom of the screen. Tap a button above to trigger one. They auto-dismiss after the timeout unless a close button is shown.")
                    .vdFontInline(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary)
            }
        }
        .vdSnackbar(
            isPresented: $showBasic,
            message: "Changes saved successfully")
        .vdSnackbar(
            isPresented: $showWithIcon,
            message: "File uploaded")
        .vdSnackbar(
            isPresented: $showAction,
            message: "Message deleted",
            onAction: { showAction = false })
        .vdSnackbar(
            isPresented: $showClose,
            message: "You have been signed out")
        .vdSnackbar(
            isPresented: $showLong,
            message: "Your export is ready. Download it from the Files section before it expires in 24 hours.")
        .navigationTitle("VdSnackbar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — VdLoadingState
// ═════════════════════════════════════════════════════════════

private struct VdLoadingStateGallery: View {
    @State private var showOverlay = false
    @State private var isLoading   = true

    var body: some View {
        galleryScroll {

            gallerySection("Spinner only") {
                VdLoadingState()
                    .frame(maxWidth: .infinity)
                    .padding(VdSpacing.lg)
                    .background(Color.vdBackgroundDefaultSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
            }

            gallerySection("With title") {
                VdLoadingState(title: "Loading your data")
                    .frame(maxWidth: .infinity)
                    .padding(VdSpacing.lg)
                    .background(Color.vdBackgroundDefaultSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
            }

            gallerySection("With title + description") {
                VdLoadingState(
                    title: "Processing payment",
                    description: "Please don't close the app. This usually takes a few seconds.")
                .frame(maxWidth: .infinity)
                .padding(VdSpacing.lg)
                .background(Color.vdBackgroundDefaultSecondary)
                .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
            }

            gallerySection("Overlay (3 second demo)") {
                ZStack {
                    VStack(spacing: VdSpacing.md) {
                        Text("Tap the button to trigger a full-screen overlay loading state for 3 seconds.")
                            .vdFontInline(VdFont.bodyMedium)
                            .foregroundStyle(Color.vdContentDefaultSecondary)
                            .multilineTextAlignment(.center)
                        VdButton("Show overlay", action: {
                            showOverlay = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showOverlay = false
                            }
                        })
                    }
                    .frame(maxWidth: .infinity)
                    .padding(VdSpacing.lg)
                    .background(Color.vdBackgroundDefaultSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))

                    if showOverlay {
                        VdLoadingState(style: .overlay, title: "Saving changes...")
                            .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
                    }
                }
            }

            gallerySection("Skeleton — toggle") {
                VStack(spacing: VdSpacing.md) {
                    Toggle("Show skeleton", isOn: $isLoading)
                        .tint(Color.vdBackgroundPrimaryBase)

                    HStack(spacing: VdSpacing.md) {
                        Circle()
                            .fill(Color.vdBackgroundPrimarySecondary)
                            .vdSkeleton(isLoading)
                            .frame(width: 48, height: 48)

                        VStack(alignment: .leading, spacing: VdSpacing.xs) {
                            Text("Ada Lovelace")
                                .vdFontInline(VdFont.labelMedium)
                                .foregroundStyle(Color.vdContentDefaultBase)
                                .vdSkeleton(isLoading)
                            Text("ada@vroxal.com")
                                .vdFontInline(VdFont.bodySmall)
                                .foregroundStyle(Color.vdContentDefaultSecondary)
                                .vdSkeleton(isLoading)
                        }
                        Spacer()
                    }
                    .padding(VdSpacing.md)
                    .background(Color.vdBackgroundDefaultSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
                }
            }

            gallerySection("Skeleton — card layout") {
                VStack(spacing: VdSpacing.sm) {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: VdSpacing.md) {
                            RoundedRectangle(cornerRadius: VdRadius.sm)
                                .vdSkeleton()
                                .frame(width: 48, height: 48)
                            VStack(alignment: .leading, spacing: VdSpacing.xs) {
                                RoundedRectangle(cornerRadius: VdRadius.xs)
                                    .vdSkeleton()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 14)
                                RoundedRectangle(cornerRadius: VdRadius.xs)
                                    .vdSkeleton()
                                    .frame(width: 160, height: 12)
                            }
                        }
                        .padding(VdSpacing.md)
                        .background(Color.vdBackgroundDefaultSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
                    }
                }
            }
        }
        .navigationTitle("VdLoadingState")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ═════════════════════════════════════════════════════════════
// MARK: — Shared layout helpers
// ═════════════════════════════════════════════════════════════

/// Wraps gallery content in a scroll view with consistent padding and background.
private func galleryScroll<Content: View>(
    @ViewBuilder content: () -> Content
) -> some View {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {
            content()
        }
        .padding(VdSpacing.lg)
    }
    .background(Color.vdBackgroundDefaultBase)
}

/// Titled section container used throughout gallery screens.
private func gallerySection<Content: View>(
    _ title: String,
    @ViewBuilder content: () -> Content
) -> some View {
    VStack(alignment: .leading, spacing: VdSpacing.sm) {
        Text(title)
            .vdFontInline(VdFont.labelSmall)
            .foregroundStyle(Color.vdContentDefaultTertiary)
        content()
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — FlowLayout
// Simple left-to-right wrapping layout used for badge rows.
// ─────────────────────────────────────────────────────────────

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                height += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
    }
}
