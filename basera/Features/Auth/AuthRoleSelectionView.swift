import SwiftUI

struct AuthRoleSelectionView: View {
    let selectedOption: UserRoleSelectionOption?
    let onSelect: (UserRoleSelectionOption) -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            Text("Your choice controls the first dashboard you’ll see after onboarding. If you choose both, you can switch roles anytime from Settings.")
                .baseraTextStyle(AppTheme.Typography.bodyLarge)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            VStack(spacing: AppTheme.Spacing.medium) {
                ForEach(UserRoleSelectionOption.allCases) { option in
                    Button {
                        onSelect(option)
                    } label: {
                        HStack(alignment: .top, spacing: AppTheme.Spacing.medium) {
                            Image(systemName: option.iconName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(selectedOption == option ? AppTheme.Colors.brandOnSecondary : AppTheme.Colors.textPrimary)
                                .frame(width: 24, height: 24)

                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                                Text(option.title)
                                    .baseraTextStyle(AppTheme.Typography.titleMedium)
                                    .foregroundStyle(selectedOption == option ? AppTheme.Colors.brandOnSecondary : AppTheme.Colors.textPrimary)

                                Text(option.subtitle)
                                    .baseraTextStyle(AppTheme.Typography.bodyMedium)
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                            }

                            Spacer()

                            selectionIndicator(isSelected: selectedOption == option)
                        }
                        .padding(AppTheme.Spacing.large)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(cardBackground(isSelected: selectedOption == option))
                        .overlay {
                            RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous)
                                .stroke(selectedOption == option ? AppTheme.Colors.brandOnSecondary : .clear, lineWidth: 1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            BaseraButton(title: "Continue", style: .primary, action: onContinue)
        }
    }

    private func cardBackground(isSelected: Bool) -> Color {
        isSelected ? AppTheme.Colors.brandSecondary : AppTheme.Colors.surfacePrimary
    }

    private func selectionIndicator(isSelected: Bool) -> some View {
        Circle()
            .fill(isSelected ? AppTheme.Colors.brandPrimary : .clear)
            .frame(width: 20, height: 20)
            .overlay {
                Circle()
                    .stroke(isSelected ? AppTheme.Colors.brandPrimary : AppTheme.Colors.textSecondary, lineWidth: 2)
            }
            .overlay {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.brandOnPrimary)
                }
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
