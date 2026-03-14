import SwiftUI

struct LoginView: View {
    @Binding var email: String
    @Binding var password: String
    @State private var passwordUpdatedSheetHeight: CGFloat = 280

    let notice: AuthStepNotice?
    let emailValidationMessage: String?
    let passwordValidationMessage: String?
    let isLoading: Bool
    let canUseBiometricLogin: Bool
    let biometricButtonTitle: String
    let passwordUpdatedEmail: String?
    let onSubmit: () -> Void
    let onBiometricLogin: () -> Void
    let onDismissPasswordUpdatedSheet: () -> Void
    let onContinueToLoginFromPasswordUpdatedSheet: () -> Void
    let onForgotPassword: () -> Void
    let onNavigateToRegistration: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                        .frame(height: AppTheme.Spacing.xxLarge)

                    logoContainer
                    //logo
                    Spacer()
                        .frame(height: AppTheme.Spacing.xLarge)
                    //header
                    headerContainer
                    Spacer()
                        .frame(height: AppTheme.Spacing.xxLarge)
                    //inputfield
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
                    registerContainer
                }
                .frame(
                    maxWidth: 402,
                    minHeight: max(proxy.size.height - 32, 0),
                    alignment: .top
                )
                .padding(.horizontal, proxy.size.width >= 520 ? 24 : 16)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.Colors.backgroundPrimary.ignoresSafeArea())
            .sheet(isPresented: passwordUpdatedSheetBinding) {
                passwordUpdatedSheet
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(
                                    key: PasswordUpdatedSheetHeightPreferenceKey.self,
                                    value: geometry.size.height
                                )
                        }
                    )
                    .onPreferenceChange(PasswordUpdatedSheetHeightPreferenceKey.self) { contentHeight in
                        passwordUpdatedSheetHeight = min(max(contentHeight + 1, 220), 520)
                    }
                    .presentationDetents([.height(passwordUpdatedSheetHeight)])
                    .presentationDragIndicator(.visible)
            }
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
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.xSmall
        ) {
            Text("Login")
                .baseraTextStyle(AppTheme.Typography.headlineLarge)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text(
                "Enter email and password to login to your account"
            )
            .baseraTextStyle(AppTheme.Typography.bodyLarge)
            .foregroundStyle(AppTheme.Colors.textSecondary)
        }

    }
    private var inputContainer: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            BaseraTextField(
                title: "Email",
                prompt: "you@example.com",
                text: $email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                textInputAutocapitalization: .never,
                errorMessage: emailValidationMessage
            )

            BaseraTextField(
                title: "Password",
                prompt: "Password",
                text: $password,
                textContentType: .password,
                textInputAutocapitalization: .never,
                isSecure: true,
                allowsSecureTextToggle: true,
                errorMessage: passwordValidationMessage
            )

            Button(action: onForgotPassword) {
                Text("Forgot Password?")
                    .baseraTextStyle(AppTheme.Typography.labelLarge)
                    .foregroundStyle(AppTheme.Colors.brandPrimary)
            }


        }

    }
    private var buttonContainer: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            BaseraButton(
                title: "Login",
                style: .primary,
                isLoading: isLoading,
                action: onSubmit
            )

            if canUseBiometricLogin {
                BaseraButton(
                    title: biometricButtonTitle,
                    style: .secondary,
                    leftIcon: "faceid",
                    iconWeight: .bold,
                    isDisabled: isLoading,
                    action: onBiometricLogin
                    
                )
            }
        }
    }
    private var registerContainer: some View {
        HStack(spacing: AppTheme.Spacing.xSmall) {
            Text("Don't have an account?")
                .baseraTextStyle(AppTheme.Typography.bodyLarge)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            Button(action: onNavigateToRegistration) {
                Text("Register")
                    .baseraTextStyle(
                        AppTheme.Typography.labelLarge
                    )
                    .foregroundStyle(
                        AppTheme.Colors.brandPrimary
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)

    }

    private func tone(for style: AuthStepNotice.Style)
        -> BaseraInlineMessageView.Tone
    {
        switch style {
        case .info:
            .info
        case .success:
            .success
        case .error:
            .error
        }
    }

    private var passwordUpdatedSheetBinding: Binding<Bool> {
        Binding(
            get: { passwordUpdatedEmail != nil },
            set: { isPresented in
                if isPresented == false && passwordUpdatedEmail != nil {
                    onDismissPasswordUpdatedSheet()
                }
            }
        )
    }

    private var passwordUpdatedSheet: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Spacer()
                .frame(height: AppTheme.Spacing.xLarge)
            Text("Password updated")
                .baseraTextStyle(AppTheme.Typography.headlineLarge)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Your password has been updated successfully. Now you can login to your account.")
                .baseraTextStyle(AppTheme.Typography.bodyLarge)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
                .frame(height: AppTheme.Spacing.xLarge)
            
            BaseraButton(
                title: "Continue to Login",
                style: .primary,
                action: onContinueToLoginFromPasswordUpdatedSheet
            )
        }
        .padding(.horizontal, AppTheme.Spacing.large)
        .padding(.vertical, AppTheme.Spacing.xLarge)
    }
}

private struct PasswordUpdatedSheetHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    LoginView(
        email: .constant(""),
        password: .constant(""),
        notice: AuthStepNotice(
            style: .info,
            message: "Use your registered email and password."
        ),
        emailValidationMessage: nil,
        passwordValidationMessage: nil,
        isLoading: false,
        canUseBiometricLogin: true,
        biometricButtonTitle: "Use Face ID",
        passwordUpdatedEmail: nil,
        onSubmit: {},
        onBiometricLogin: {},
        onDismissPasswordUpdatedSheet: {},
        onContinueToLoginFromPasswordUpdatedSheet: {},
        onForgotPassword: {},
        onNavigateToRegistration: {}
    )
}
