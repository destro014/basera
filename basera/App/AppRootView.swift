import SwiftUI
import VroxalDesign

struct AppRootView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = AppRootViewModel()

    var body: some View {
        Group {
            switch viewModel.route {
            case .loading:
                AppStartupLoadingView()
            case .onboarding:
                OnboardingView(
                    notice: nil,
                    onLogin: {
                        viewModel.continueFromOnboarding(to: .login)
                    },
                    onRegister: {
                        viewModel.continueFromOnboarding(to: .registration)
                    }
                )
            case .signedOut(let entryPoint):
                SignedOutAuthFlowView(
                    authRepository: environment.authRepository,
                    biometricLoginManager: environment.biometricLoginManager,
                    initialStep: initialAuthStep(for: entryPoint),
                    onAuthenticated: { completion in
                        viewModel.handleAuthenticatedUser(
                            completion.user,
                            credentials: completion.credentials,
                            environment: environment
                        )
                    }
                )
            case .signedIn(let user):
                HomeShellView(
                    user: user,
                    onSignOut: {
                        Task {
                            await viewModel.signOut(environment: environment)
                        }
                    }
                )
            }
        }
        .task {
            await viewModel.load(environment: environment)
        }
        .alert(
            "Enable \(viewModel.biometricPrompt?.biometryDisplayName ?? "Biometric") login?",
            isPresented: Binding(
                get: { viewModel.biometricPrompt != nil },
                set: { isPresented in
                    if isPresented == false {
                        viewModel.dismissBiometricPrompt(environment: environment)
                    }
                }
            )
        ) {
            Button("Not Now", role: .cancel) {
                viewModel.dismissBiometricPrompt(environment: environment)
            }
            Button("Enable") {
                Task {
                    await viewModel.enableBiometricLogin(environment: environment)
                }
            }
        } message: {
            Text("You can use \(viewModel.biometricPrompt?.biometryDisplayName ?? "biometrics") for faster login next time.")
        }
        .baseraScreenBackground()
    }

    private func initialAuthStep(for entryPoint: AuthEntryPoint) -> AuthFlowStep {
        switch entryPoint {
        case .login:
            .login
        case .registration:
            .registration
        }
    }
}

private struct AppStartupLoadingView: View {
    var body: some View {
        VStack(spacing: VdSpacing.xl) {
            Image("logo-vertical")
                .resizable()
                .scaledToFit()
                .frame(width: 180)
                .accessibilityLabel("Basera")

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .baseraScreenBackground()
    }
}

#Preview {
    AppStartupLoadingView()
        .environmentObject(AppEnvironment.bootstrap())
}

private struct SignedOutAuthFlowView: View {
    @StateObject private var viewModel: AuthFlowViewModel

    let onAuthenticated: (AuthFlowCompletion) -> Void

    init(
        authRepository: AuthRepositoryProtocol,
        biometricLoginManager: BiometricLoginManagerProtocol,
        initialStep: AuthFlowStep = .login,
        onAuthenticated: @escaping (AuthFlowCompletion) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: AuthFlowViewModel(
                authRepository: authRepository,
                biometricLoginManager: biometricLoginManager,
                initialStep: initialStep
            )
        )
        self.onAuthenticated = onAuthenticated
    }

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            contentView(for: viewModel.rootStep)
                .navigationDestination(for: AuthFlowStep.self) { step in
                    contentView(for: step)
                }
        }
        .animation(.easeInOut(duration: 0.24), value: viewModel.navigationPath)
        .animation(.easeInOut(duration: 0.24), value: viewModel.rootStep)
    }

    @ViewBuilder
    private func contentView(for step: AuthFlowStep) -> some View {
        let notice = viewModel.step == step ? viewModel.notice : nil

        switch step {
        case .login:
            LoginView(
                email: Binding(
                    get: { viewModel.loginEmail },
                    set: { viewModel.updateLoginEmail($0) }
                ),
                password: Binding(
                    get: { viewModel.loginPassword },
                    set: { viewModel.updateLoginPassword($0) }
                ),
                notice: notice,
                emailValidationMessage: viewModel.loginEmailError,
                passwordValidationMessage: viewModel.loginPasswordError,
                isLoading: viewModel.isLoading,
                canUseBiometricLogin: viewModel.canUseBiometricLogin,
                biometricButtonTitle: viewModel.biometricLoginTitle,
                biometricSystemImageName: viewModel.biometricLoginSystemImageName,
                passwordUpdatedEmail: viewModel.passwordUpdatedEmailForSheet,
                onSubmit: {
                    Task {
                        if let completion = await viewModel.signIn() {
                            onAuthenticated(completion)
                        }
                    }
                },
                onBiometricLogin: {
                    Task {
                        if let completion = await viewModel.signInWithBiometrics() {
                            onAuthenticated(completion)
                        }
                    }
                },
                onDismissPasswordUpdatedSheet: viewModel.dismissPasswordUpdatedSheet,
                onContinueToLoginFromPasswordUpdatedSheet: viewModel.continueToLoginFromPasswordUpdatedSheet,
                onForgotPassword: viewModel.moveToPasswordRecovery,
                onNavigateToRegistration: viewModel.moveToRegistration
            )
        case .registration:
            RegistrationView(
                email: Binding(
                    get: { viewModel.registrationEmail },
                    set: { viewModel.updateRegistrationEmail($0) }
                ),
                notice: notice,
                emailValidationMessage: viewModel.registrationEmailError,
                isLoading: viewModel.isLoading,
                existingAccountEmail: viewModel.existingAccountEmailForSheet,
                onSubmit: {
                    Task {
                        await viewModel.startRegistration()
                    }
                },
                onDismissExistingAccountSheet: viewModel.dismissExistingAccountSheet,
                onContinueToLoginFromExistingAccount: viewModel.continueToLoginFromExistingAccountSheet,
                onNavigateToLogin: viewModel.moveToLogin
            )
            .navigationBarBackButtonHidden(true)
        case .emailVerification:
            OTPVerificationView(
                code: Binding(
                    get: { viewModel.verificationCode },
                    set: { viewModel.updateVerificationCode($0) }
                ),
                maskedEmail: viewModel.registrationMaskedEmail,
                notice: notice,
                validationMessage: viewModel.verificationCodeError,
                isLoading: viewModel.isLoading,
                canResendCode: viewModel.canResendCode,
                resendButtonTitle: viewModel.resendButtonTitle,
                onVerify: {
                    Task {
                        await viewModel.verifyEmailCode()
                    }
                },
                onResend: {
                    Task {
                        await viewModel.resendEmailCode()
                    }
                },
                onEditEmail: viewModel.editRegistrationEmail
            )
        case .registrationPassword:
            RegistrationPasswordView(
                password: Binding(
                    get: { viewModel.registrationPassword },
                    set: { viewModel.updateRegistrationPassword($0) }
                ),
                confirmPassword: Binding(
                    get: { viewModel.confirmPassword },
                    set: { viewModel.updateConfirmPassword($0) }
                ),
                notice: notice,
                passwordValidationMessage: viewModel.registrationPasswordError,
                confirmPasswordValidationMessage: viewModel.confirmPasswordError,
                isLoading: viewModel.isLoading,
                onSubmit: {
                    Task {
                        await viewModel.completeRegistrationPassword()
                    }
                }
            )
        case .roleSelection:
            RoleSelectionView(
                selectedRole: Binding(
                    get: { viewModel.selectedRole },
                    set: { viewModel.selectedRole = $0 }
                ),
                isLoading: viewModel.isLoading,
                onContinue: viewModel.continueToProfileSetupFromRoleSelection
            )
        case .profileSetup:
            ProfileCreationView(
                fullName: Binding(
                    get: { viewModel.fullName },
                    set: { viewModel.updateFullName($0) }
                ),
                phoneNumber: Binding(
                    get: { viewModel.phoneNumber },
                    set: { viewModel.updatePhoneNumber($0) }
                ),
                notice: notice,
                fullNameValidationMessage: viewModel.fullNameError,
                phoneNumberValidationMessage: viewModel.phoneNumberError,
                isLoading: viewModel.isLoading,
                onSubmit: {
                    Task {
                        if let completion = await viewModel.completeProfileSetup() {
                            onAuthenticated(completion)
                        }
                    }
                }
            )
        case .passwordRecoveryEmail:
            PasswordRecoveryEmailView(
                email: Binding(
                    get: { viewModel.passwordRecoveryEmail },
                    set: { viewModel.updatePasswordRecoveryEmail($0) }
                ),
                notice: notice,
                emailValidationMessage: viewModel.passwordRecoveryEmailError,
                isLoading: viewModel.isLoading,
                onSubmit: {
                    Task {
                        await viewModel.startPasswordRecovery()
                    }
                },
                onBackToLogin: viewModel.moveToLogin
            )
        case .passwordRecoveryVerification:
            PasswordRecoveryOTPView(
                code: Binding(
                    get: { viewModel.passwordRecoveryCode },
                    set: { viewModel.updatePasswordRecoveryCode($0) }
                ),
                maskedEmail: viewModel.passwordRecoveryMaskedEmail,
                notice: notice,
                validationMessage: viewModel.passwordRecoveryCodeError,
                isLoading: viewModel.isLoading,
                canResendCode: viewModel.canResendCode,
                resendButtonTitle: viewModel.resendButtonTitle,
                onVerify: {
                    Task {
                        await viewModel.verifyPasswordRecoveryCode()
                    }
                },
                onResend: {
                    Task {
                        await viewModel.resendPasswordRecoveryCode()
                    }
                },
                onEditEmail: viewModel.editPasswordRecoveryEmail
            )
        case .passwordRecoveryReset:
            PasswordResetView(
                newPassword: Binding(
                    get: { viewModel.newPassword },
                    set: { viewModel.updateNewPassword($0) }
                ),
                confirmPassword: Binding(
                    get: { viewModel.confirmNewPassword },
                    set: { viewModel.updateConfirmNewPassword($0) }
                ),
                notice: notice,
                newPasswordValidationMessage: viewModel.newPasswordError,
                confirmPasswordValidationMessage: viewModel.confirmNewPasswordError,
                isLoading: viewModel.isLoading,
                onSubmit: {
                    Task {
                        await viewModel.completePasswordRecovery()
                    }
                }
            )
        }
    }
}
