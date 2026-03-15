import SwiftUI

struct OnboardingView: View {
    let notice: AuthStepNotice?
    let onLogin: () -> Void
    let onRegister: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {

                    Image("logo-horizontal")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .accessibilityHidden(true)
                    Spacer()
                        .frame(height: AppTheme.Spacing.xLarge)


                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                        Text("Welcome to Basera")
                            .baseraTextStyle(AppTheme.Typography.headlineLarge)
                            .foregroundStyle(AppTheme.Colors.textPrimary)

                        Text("Manage the rental journey in one place, from discovery and approvals to agreements, monthly invoices, and move-out records.")
                            .baseraTextStyle(AppTheme.Typography.bodyLarge)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                    Spacer()
                        .frame(height: AppTheme.Spacing.xxLarge)


                        introPoint(
                            iconName: "person.2.fill",
                            title: "Single role account setup",
                            message: "Choose renter or owner during registration. Each account keeps one role for clear workflows."
                        )

                        introPoint(
                            iconName: "lock.shield.fill",
                            title: "Privacy-first listing flow",
                            message: "Public listings keep the exact property address hidden until an owner reviews and approves the renter."
                        )

                        introPoint(
                            iconName: "doc.text.fill",
                            title: "Records that stay accessible",
                            message: "Track agreements, monthly invoices, partial payments, advance payments, and the formal move-out flow in one place."
                        )

                        Spacer()

                        HStack(spacing: AppTheme.Spacing.medium) {
                            BaseraButton(title: "Register", style: .primary, action: onRegister)
                                .frame(maxWidth: .infinity)
                            BaseraButton(title: "Login", style: .secondary, action: onLogin)
                                .frame(maxWidth: .infinity)
                        }
                    
                
                }
                .frame(maxWidth: 402, minHeight: max(proxy.size.height - 32, 0), alignment: .top)
                .padding(.horizontal, proxy.size.width >= 520 ? 24 : 16)
                .padding(.top, 24)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.Colors.backgroundPrimary.ignoresSafeArea())
        }
    }


    private func tone(for style: AuthStepNotice.Style) -> BaseraInlineMessageView.Tone {
        switch style {
        case .info:
            .info
        case .success:
            .success
        case .error:
            .error
        }
    }

    private func introPoint(iconName: String, title: String, message: String) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.medium) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                Text(title)
                    .baseraTextStyle(AppTheme.Typography.titleMedium)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Text(message)
                    .baseraTextStyle(AppTheme.Typography.bodyMedium)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.large)
        .background(AppTheme.Colors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))
    }
}

#Preview {
    OnboardingView(
        notice: nil,
        onLogin: {},
        onRegister: {}
    )
}
