import SwiftUI

struct AuthRoleSelectionView: View {
    let selectedOption: UserRoleSelectionOption?
    let onSelect: (UserRoleSelectionOption) -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            Text("Your choice controls the first dashboard you’ll see after onboarding. If you choose both, you can switch roles anytime from Settings.")
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            VStack(spacing: AppTheme.Spacing.medium) {
                ForEach(UserRoleSelectionOption.allCases) { option in
                    Button {
                        onSelect(option)
                    } label: {
                        HStack(alignment: .top, spacing: AppTheme.Spacing.medium) {
                            Image(systemName: option.iconName)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(selectedOption == option ? AppTheme.Colors.onPrimary : AppTheme.Colors.brandPrimary)
                                .frame(width: 28, height: 28)

                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                                Text(option.title)
                                    .font(AppTheme.Typography.subtitle)
                                    .foregroundStyle(selectedOption == option ? AppTheme.Colors.onPrimary : AppTheme.Colors.textPrimary)

                                Text(option.subtitle)
                                    .font(AppTheme.Typography.body)
                                    .foregroundStyle(selectedOption == option ? AppTheme.Colors.onPrimary.opacity(0.86) : AppTheme.Colors.textSecondary)
                            }

                            Spacer()

                            Image(systemName: selectedOption == option ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(selectedOption == option ? AppTheme.Colors.onPrimary : AppTheme.Colors.border)
                        }
                        .padding(AppTheme.Spacing.large)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(cardBackground(isSelected: selectedOption == option))
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            BaseraButton(title: "Continue", style: .primary, action: onContinue)
        }
    }

    private func cardBackground(isSelected: Bool) -> AnyShapeStyle {
        if isSelected {
            return AnyShapeStyle(LinearGradient(
                colors: [AppTheme.Colors.brandPrimary, AppTheme.Colors.brandSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        } else {
            return AnyShapeStyle(AppTheme.Colors.surface)
        }
    }
}

#Preview("Empty") {
    AuthRoleSelectionView(selectedOption: nil, onSelect: { _ in }, onContinue: {})
        .padding()
}

#Preview("Selected") {
    AuthRoleSelectionView(selectedOption: .both, onSelect: { _ in }, onContinue: {})
        .padding()
}
