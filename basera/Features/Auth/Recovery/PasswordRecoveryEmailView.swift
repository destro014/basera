import SwiftUI

struct PasswordRecoveryEmailView: View {
    @Binding var email: String

    let notice: AuthStepNotice?
    let emailValidationMessage: String?
    let isLoading: Bool
    let onSubmit: () -> Void
    let onBackToLogin: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                        .frame(height: AppTheme.Spacing.xxLarge)
                    headerContainer
                    Spacer()
                        .frame(height: AppTheme.Spacing.xxLarge)
                    inputContainer
                    if let notice {
                        Spacer()
                            .frame(height: AppTheme.Spacing.large)

                        BaseraInlineMessageView(
                            tone: tone(for: notice.style),
                            message: notice.message
                        )

                        Spacer()
                            .frame(height: AppTheme.Spacing.large)
                    } else {
                        Spacer()
                            .frame(height: AppTheme.Spacing.xxLarge)
                    }
                    buttonContainer
                    Spacer()
                        .frame(height: AppTheme.Spacing.large)
                    backToLoginContainer
                }
                .frame(maxWidth: 402, minHeight: max(proxy.size.height - 32, 0), alignment: .top)
                .padding(.horizontal, proxy.size.width >= 520 ? 24 : 16)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.Colors.backgroundPrimary.ignoresSafeArea())
        }
    }

    private var logoContainer: some View {
        Image("logo-horizontal")
            .resizable()
            .scaledToFit()
            .frame(height: 40)
            .accessibilityHidden(true)
    }

    private var headerContainer: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
            Text("Recover password")
                .baseraTextStyle(AppTheme.Typography.headlineLarge)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Enter your account email to receive a verification code for password recovery.")
                .baseraTextStyle(AppTheme.Typography.bodyLarge)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    private var inputContainer: some View {
        BaseraTextField(
            title: "Email",
            prompt: "you@example.com",
            text: $email,
            keyboardType: .emailAddress,
            textContentType: .emailAddress,
            textInputAutocapitalization: .never,
            errorMessage: emailValidationMessage
        )
    }

    private var buttonContainer: some View {
        BaseraButton(
            title: "Send code",
            style: .primary,
            isLoading: isLoading,
            action: onSubmit
        )
    }

    private var backToLoginContainer: some View {
        HStack(spacing: AppTheme.Spacing.xSmall) {
            Text("Remember your password?")
                .baseraTextStyle(AppTheme.Typography.bodyLarge)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            Button(action: onBackToLogin) {
                Text("Login")
                    .baseraTextStyle(AppTheme.Typography.labelLarge)
                    .foregroundStyle(AppTheme.Colors.brandPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
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
}

#Preview {
    PasswordRecoveryEmailView(
        email: .constant(""),
        notice: nil,
        emailValidationMessage: nil,
        isLoading: false,
        onSubmit: {},
        onBackToLogin: {}
    )
}
