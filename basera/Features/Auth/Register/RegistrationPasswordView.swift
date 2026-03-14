import SwiftUI

struct RegistrationPasswordView: View {
    @Binding var password: String
    @Binding var confirmPassword: String

    let notice: AuthStepNotice?
    let passwordValidationMessage: String?
    let confirmPasswordValidationMessage: String?
    let isLoading: Bool
    let onSubmit: () -> Void

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
            Text("Create password")
                .baseraTextStyle(AppTheme.Typography.headlineLarge)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Create a secure password before you complete your profile.")
                .baseraTextStyle(AppTheme.Typography.bodyLarge)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    private var inputContainer: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            BaseraTextField(
                title: "Password",
                prompt: "Minimum 8 characters",
                text: $password,
                textContentType: .newPassword,
                textInputAutocapitalization: .never,
                isSecure: true,
                allowsSecureTextToggle: true,
                errorMessage: passwordValidationMessage
            )

            BaseraTextField(
                title: "Confirm Password",
                prompt: "Re-enter password",
                text: $confirmPassword,
                textContentType: .newPassword,
                textInputAutocapitalization: .never,
                isSecure: true,
                allowsSecureTextToggle: true,
                errorMessage: confirmPasswordValidationMessage
            )
        }
    }

    private var buttonContainer: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            BaseraButton(
                title: "Create Password",
                style: .primary,
                isLoading: isLoading,
                action: onSubmit
            )

            Text("By continuing, you agree to [Terms and Conditions](https://pramodpoudel.com.np/) and [Privacy Policy](https://pramodpoudel.com.np/).")
                .baseraTextStyle(AppTheme.Typography.bodyMedium)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .tint(AppTheme.Colors.brandPrimary)
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
}

#Preview {
    RegistrationPasswordView(
        password: .constant(""),
        confirmPassword: .constant(""),
        notice: nil,
        passwordValidationMessage: nil,
        confirmPasswordValidationMessage: nil,
        isLoading: false,
        onSubmit: {}
    )
}
