import SwiftUI

struct BaseraButton: View {
    enum Style {
        case primary
        case secondary
        case subtle
    }

    let title: String
    let style: Style
    var leftIcon: String? = nil
    var rightIcon: String? = nil
    var iconWeight: Font.Weight? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .frame(height: 24)

                } else {
                    HStack(spacing: AppTheme.Spacing.small) {
                        if let leftIcon {
                            Image(systemName: leftIcon)
                                .font(.system(size: 24, weight: iconWeight ?? .semibold))

                        }

                        Text(title)
                            .baseraTextStyle(AppTheme.Typography.labelLarge)
                            .lineLimit(1)
                            .frame(height: 24)


                        if let rightIcon {
                            Image(systemName: rightIcon)
                                .font(.system(size: 24, weight: iconWeight ?? .regular))

                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, AppTheme.Spacing.xLarge)
            .padding(.vertical, AppTheme.Spacing.large)
            .contentShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))
        }
        .buttonStyle(.plain)
        .foregroundStyle(foregroundColor)
        .background(backgroundColor)
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous)
                .stroke(borderColor, lineWidth: borderWidth)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))
        .opacity(opacity)
        .disabled(isDisabled || isLoading)
        
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            AppTheme.Colors.brandOnPrimary
        case .secondary:
            AppTheme.Colors.brandPrimary
        case .subtle:
            AppTheme.Colors.brandOnSecondary
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            AppTheme.Colors.brandPrimary
        case .secondary:
            AppTheme.Colors.surfacePrimary
        case .subtle:
            AppTheme.Colors.brandSecondary
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary, .subtle:
            .clear
        case .secondary:
            AppTheme.Colors.brandPrimary
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .primary, .subtle:
            0
        case .secondary:
            1
        }
    }

    private var opacity: Double {
        guard isDisabled || isLoading else { return 1 }
        return style == .subtle ? 1 : 0.7
    }
}

#Preview {
    VStack(spacing: 12) {
        BaseraButton(title: "Continue in Basera", style: .primary, action: {})
        BaseraButton(title: "Back", style: .primary, leftIcon: "arrow.left", action: {})
        BaseraButton(title: "Next", style: .secondary, rightIcon: "chevron.right", action: {})
        BaseraButton(title: "Swap Role", style: .subtle, leftIcon: "arrow.left.arrow.right", rightIcon: "chevron.right", action: {})
        BaseraButton(title: "Thick Face ID", style: .secondary, leftIcon: "faceid", iconWeight: .bold, action: {})
        BaseraButton(title: "Secondary", style: .secondary, action: {})
        BaseraButton(title: "Subtle", style: .subtle, action: {})
        BaseraButton(title: "Loading", style: .primary, isLoading: true, action: {})
    }
    .padding()
}
