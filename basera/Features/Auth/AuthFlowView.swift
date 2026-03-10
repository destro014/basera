import SwiftUI

struct AuthFlowView: View {
    @StateObject private var viewModel: AuthFlowViewModel

    let onAuthenticated: (AppUser) -> Void

    init(authRepository: AuthRepositoryProtocol, onAuthenticated: @escaping (AppUser) -> Void) {
        _viewModel = StateObject(wrappedValue: AuthFlowViewModel(authRepository: authRepository))
        self.onAuthenticated = onAuthenticated
    }

    var body: some View {
        AuthOnboardingContainerView(
            step: viewModel.step,
            notice: viewModel.notice,
            canGoBack: viewModel.canGoBack,
            onBack: viewModel.goBack
        ) {
            content
        }
        .animation(.easeInOut(duration: 0.24), value: viewModel.step)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.step {
        case .introduction:
            AuthIntroductionView(onContinue: viewModel.continueFromIntroduction)
        case .phoneNumber:
            AuthPhoneEntryView(
                phoneNumber: Binding(
                    get: { viewModel.phoneNumber },
                    set: { viewModel.updatePhoneNumber($0) }
                ),
                validationMessage: viewModel.phoneFieldError,
                isLoading: viewModel.isLoading,
                onSubmit: {
                    Task {
                        await viewModel.submitPhoneNumber()
                    }
                }
            )
        case .otpVerification:
            AuthOTPVerificationView(
                otpCode: Binding(
                    get: { viewModel.otpCode },
                    set: { viewModel.updateOTPCode($0) }
                ),
                maskedPhoneNumber: viewModel.maskedPhoneNumber,
                validationMessage: viewModel.otpFieldError,
                isLoading: viewModel.isLoading,
                canResendCode: viewModel.canResendCode,
                resendButtonTitle: viewModel.resendButtonTitle,
                onVerify: {
                    Task {
                        if let user = await viewModel.verifyOTP() {
                            onAuthenticated(user)
                        }
                    }
                },
                onResend: {
                    Task {
                        await viewModel.resendOTP()
                    }
                }
            )
        case .roleSelection:
            AuthRoleSelectionView(
                selectedOption: viewModel.selectedRoleOption,
                onSelect: viewModel.selectRoleOption,
                onContinue: viewModel.continueFromRoleSelection
            )
        case .consent:
            AuthConsentView(
                acceptsTerms: Binding(
                    get: { viewModel.acceptsTerms },
                    set: { viewModel.setAcceptsTerms($0) }
                ),
                acceptsPrivacy: Binding(
                    get: { viewModel.acceptsPrivacy },
                    set: { viewModel.setAcceptsPrivacy($0) }
                ),
                onContinue: viewModel.continueFromConsent
            )
        case .profilePhoto:
            AuthProfilePhotoView(
                hasSelectedPhoto: viewModel.hasSelectedPhoto,
                isLoading: viewModel.isLoading,
                onPhotoSelected: viewModel.handleSelectedPhotoData,
                onPhotoSelectionFailure: viewModel.handlePhotoSelectionFailure,
                onComplete: {
                    Task {
                        if let user = await viewModel.completeOnboarding() {
                            onAuthenticated(user)
                        }
                    }
                },
                onSkip: {
                    Task {
                        if let user = await viewModel.skipPhotoAndComplete() {
                            onAuthenticated(user)
                        }
                    }
                }
            )
        }
    }
}

#Preview {
    AuthFlowView(
        authRepository: MockAuthRepository(
            authService: MockAuthService(),
            storageService: MockStorageService()
        ),
        onAuthenticated: { _ in }
    )
}
