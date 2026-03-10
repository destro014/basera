import SwiftUI

struct BaseraButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: String
    let style: Style
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.small) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                }

                Text(title)
                    .font(AppTheme.Typography.body.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.medium)
        }
        .buttonStyle(.plain)
        .foregroundStyle(foregroundColor)
        .background(backgroundColor)
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                .stroke(borderColor, lineWidth: style == .secondary ? 1 : 0)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
        .opacity(isDisabled || isLoading ? 0.7 : 1)
        .disabled(isDisabled || isLoading)
    }

    private var foregroundColor: Color {
        style == .primary ? AppTheme.Colors.onPrimary : AppTheme.Colors.brandPrimary
    }

    private var backgroundColor: Color {
        style == .primary ? AppTheme.Colors.brandPrimary : AppTheme.Colors.surface
    }

    private var borderColor: Color {
        style == .primary ? .clear : AppTheme.Colors.borderLight
    }
}

#Preview {
    VStack(spacing: 12) {
        BaseraButton(title: "Continue in Basera", style: .primary, action: {})
        BaseraButton(title: "Secondary", style: .secondary, action: {})
        BaseraButton(title: "Loading", style: .primary, isLoading: true, action: {})
    }
    .padding()
}
