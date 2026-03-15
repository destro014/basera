import SwiftUI

struct RoleSelectionView: View {
    @Binding var selectedRole: UserRole

    let isLoading: Bool
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                        .frame(height: AppTheme.Spacing.xxLarge)
                    headerContainer
                    Spacer()
                        .frame(height: AppTheme.Spacing.xxLarge)
                    optionsContainer
                    Spacer()
                        .frame(height: AppTheme.Spacing.xxLarge)
                    buttonContainer
                }
                .frame(maxWidth: 402, minHeight: max(proxy.size.height - 32, 0), alignment: .top)
                .padding(.horizontal, proxy.size.width >= 520 ? 24 : 16)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.Colors.backgroundPrimary.ignoresSafeArea())
        }
    }

    private var headerContainer: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
            Text("How will you use Basera?")
                .baseraTextStyle(AppTheme.Typography.headlineLarge)
                .foregroundStyle(AppTheme.Colors.textPrimary)
        }
    }

    private var optionsContainer: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            optionCard(
                role: .renter,
                emoji: "🏠",
                title: "Find a place to rent",
                subtitle: "I am looking for properties."
            )

            optionCard(
                role: .owner,
                emoji: "🏢",
                title: "List my property",
                subtitle: "I want to rent out my property."
            )
        }
    }

    private var buttonContainer: some View {
        BaseraButton(
            title: "Continue",
            style: .primary,
            isLoading: isLoading,
            action: onContinue
        )
    }

    private func optionCard(role: UserRole, emoji: String, title: String, subtitle: String) -> some View {
        Button {
            selectedRole = role
        } label: {
            HStack(alignment: .top, spacing: AppTheme.Spacing.medium) {
                Text(emoji)
                    .font(.system(size: 22))
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                    Text(title)
                        .baseraTextStyle(AppTheme.Typography.titleMedium)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text(subtitle)
                        .baseraTextStyle(AppTheme.Typography.bodyMedium)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }

                Spacer(minLength: 0)

                Image(systemName: selectedRole == role ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedRole == role ? AppTheme.Colors.brandPrimary : AppTheme.Colors.borderPrimary)
            }
            .padding(AppTheme.Spacing.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.Colors.surfacePrimary)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous)
                    .stroke(
                        selectedRole == role ? AppTheme.Colors.brandPrimary : AppTheme.Colors.borderPrimary,
                        lineWidth: selectedRole == role ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RoleSelectionView(
        selectedRole: .constant(.renter),
        isLoading: false,
        onContinue: {}
    )
}
