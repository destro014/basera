import SwiftUI
import VroxalDesign

struct LoginView: View {
    @Binding var email: String
    @Binding var password: String
    @State private var isPasswordSecure = true
    @State private var passwordUpdatedSheetHeight: CGFloat = 280

    let notice: AuthStepNotice?
    let emailValidationMessage: String?
    let passwordValidationMessage: String?
    let isLoading: Bool
    let canUseBiometricLogin: Bool
    let biometricButtonTitle: String
    let biometricSystemImageName: String
    let passwordUpdatedEmail: String?
    let onSubmit: () -> Void
    let onBiometricLogin: () -> Void
    let onDismissPasswordUpdatedSheet: () -> Void
    let onContinueToLoginFromPasswordUpdatedSheet: () -> Void
    let onForgotPassword: () -> Void
    let onNavigateToRegistration: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let contentHorizontalPadding =
                proxy.size.width >= 520 ? VdSpacing.lg : VdSpacing.md

            VStack(alignment: .leading, spacing: VdSpacing.none) {
                Spacer()
                    .frame(height: VdSpacing.xxl)

                logoContainer

                Spacer()
                    .frame(height: VdSpacing.lg)

                headerContainer

                Spacer()
                    .frame(height: VdSpacing.xl)

                inputContainer

                if let notice {
                    Spacer()
                        .frame(height: VdSpacing.md)

                    AuthNoticeBanner(notice: notice)

                    Spacer()
                        .frame(height: VdSpacing.md)
                } else {
                    Spacer()
                        .frame(height: VdSpacing.xl)
                }

                buttonContainer

                Spacer(minLength: VdSpacing.xl)
            }
            .frame(
                maxWidth: 420,
                minHeight: max(proxy.size.height - 32, 0),
                alignment: .top
            )
            .padding(.horizontal, contentHorizontalPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .safeAreaInset(edge: .bottom, spacing: VdSpacing.none) {
                registerContainer(
                    horizontalPadding: contentHorizontalPadding,
                    bottomSafeAreaInset: proxy.safeAreaInsets.bottom
                )
            }
            .baseraScreenBackground()

            .sheet(isPresented: passwordUpdatedSheetBinding) {
                passwordUpdatedSheet
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(
                                    key: PasswordUpdatedSheetHeightPreferenceKey
                                        .self,
                                    value: geometry.size.height
                                )
                        }
                    )
                    .onPreferenceChange(
                        PasswordUpdatedSheetHeightPreferenceKey.self
                    ) { contentHeight in
                        passwordUpdatedSheetHeight = min(
                            max(contentHeight + 1, 220),
                            520
                        )
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
            .frame(height: 44)
            .accessibilityHidden(true)
    }

    private var headerContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.xs) {
            Text("Login to your account")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text("Enter email and password to login")
                .vdFont(VdFont.bodyLarge)
                .foregroundStyle(Color.vdContentDefaultSecondary)
        }
    }

    private var inputContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.md) {
            VdTextField(
                "Email",
                text: $email,
                placeholder: "you@example.com",
                state: inputState(for: emailValidationMessage),
                leadingIcon: "envelope",
                helperText: emailValidationMessage
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .keyboardType(.emailAddress)
            .textContentType(.username)

            VdTextField(
                "Password",
                text: $password,
                placeholder: "Password",
                state: inputState(for: passwordValidationMessage),
                isSecure: isPasswordSecure,
                leadingIcon: "lock",
                helperText: passwordValidationMessage,
                trailingIcon: isPasswordSecure ? "eye" : "eye.slash",
                onTrailingAction: { isPasswordSecure.toggle() }
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .textContentType(.password)
            Button(action: onForgotPassword) {
                Text("Forgot Password?")
                    .vdFont(VdFont.labelMedium)
                    .foregroundStyle(Color.vdContentPrimaryBase)
            }
            .buttonStyle(.plain)

            .disabled(isLoading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var buttonContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.sm) {
            VdButton(
                "Login",
                color: .primary,
                style: .solid,
                size: .large,
                fullWidth: true,
                isLoading: isLoading,
                action: onSubmit
            )

            if canUseBiometricLogin {
                VdButton(
                    biometricButtonTitle,
                    color: .primary,
                    style: .outlined,
                    size: .large,
                    fullWidth: true,
                    isLoading: isLoading,
                    leftIcon: biometricSystemImageName,
                    action: onBiometricLogin
                )
                .disabled(isLoading)
            }
        }

    }

    private func registerContainer(
        horizontalPadding: CGFloat,
        bottomSafeAreaInset: CGFloat
    ) -> some View {
        HStack(alignment: .center, spacing: VdSpacing.sm) {
            Text("Don't have an account?")
                .vdFont(VdFont.bodyMedium)
                .foregroundStyle(Color.vdContentDefaultSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VdButton(
                title: "Register",
                style: .subtle,
                isDisabled: isLoading,
                action: onNavigateToRegistration
            )
            .frame(width: 107)
        }
        .frame(maxWidth: 420, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, horizontalPadding)
        .padding(.top, VdSpacing.md)
        .padding(
            .bottom,
            max(bottomSafeAreaInset + VdSpacing.xs, VdSpacing.lg)
        )
        .background(
            TopRoundedRectangle(radius: VdRadius.xl)
                .fill(Color.vdBackgroundDefaultSecondary)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func inputState(for validationMessage: String?) -> VdInputState {
        validationMessage == nil ? .default : .error
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
        VStack(alignment: .leading, spacing: VdSpacing.md) {
            Spacer()
                .frame(height: VdSpacing.lg)

            Text("Password updated")
                .vdFont(VdFont.headlineMedium)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text(
                "Your password has been updated successfully. Now you can login to your account."
            )
            .vdFont(VdFont.bodyLarge)
            .foregroundStyle(Color.vdContentDefaultSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
                .frame(height: VdSpacing.lg)

            VdButton(
                "Continue to Login",
                color: .primary,
                style: .solid,
                size: .medium,
                rounded: true,
                fullWidth: true,
                action: onContinueToLoginFromPasswordUpdatedSheet
            )
        }
        .padding(.horizontal, VdSpacing.md)
        .padding(.vertical, VdSpacing.lg)
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
        biometricSystemImageName: "faceid",
        passwordUpdatedEmail: nil,
        onSubmit: {},
        onBiometricLogin: {},
        onDismissPasswordUpdatedSheet: {},
        onContinueToLoginFromPasswordUpdatedSheet: {},
        onForgotPassword: {},
        onNavigateToRegistration: {}
    )
}
