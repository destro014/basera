import SwiftUI

struct BasraButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.medium)
        }
        .foregroundStyle(style == .primary ? .white : AppTheme.Colors.brandPrimary)
        .background(style == .primary ? AppTheme.Colors.brandPrimary : AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 12) {
        BasraButton(title: "Continue in Basra", style: .primary, action: {})
        BasraButton(title: "Secondary", style: .secondary, action: {})
    }
    .padding()
}
