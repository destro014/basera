import SwiftUI

struct AuthFlowView: View {
    @StateObject private var viewModel: AuthFlowViewModel

    let onAuthenticated: (AppUser) -> Void

    init(authRepository: AuthRepositoryProtocol, onAuthenticated: @escaping (AppUser) -> Void) {
        _viewModel = StateObject(wrappedValue: AuthFlowViewModel(authRepository: authRepository))
        self.onAuthenticated = onAuthenticated
    }

    var body: some View {
        Group {
            if viewModel.step == .introduction {
                AuthOnboardingContainerView(step: viewModel.step, notice: viewModel.notice) {
                    AuthIntroductionView(onContinue: viewModel.continueFromIntroduction)
                }
            } else {
                NavigationStack(path: $viewModel.navigationPath) {
                    AuthOnboardingContainerView(step: .phoneNumber, notice: viewModel.notice) {
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
                    }
                    .navigationDestination(for: AuthFlowStep.self) { step in
                        destinationView(for: step)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.24), value: viewModel.step)
    }

    @ViewBuilder
    private func destinationView(for step: AuthFlowStep) -> some View {
        switch step {
        case .otpVerification:
            AuthOnboardingContainerView(step: step, notice: viewModel.notice) {
                AuthOTPVerificationView(
                    otpCode: Binding(
                        get: { viewModel.otpCode },
                        set: { viewModel.updateOTPCode($0) }
                    ),
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
            }
        case .roleSelection:
            AuthOnboardingContainerView(step: step, notice: viewModel.notice) {
                AuthRoleSelectionView(
                    selectedOption: viewModel.selectedRoleOption,
                    onSelect: viewModel.selectRoleOption,
                    onContinue: viewModel.continueFromRoleSelection
                )
            }
        case .profilePhoto:
            AuthOnboardingContainerView(step: step, notice: viewModel.notice) {
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
        default:
            EmptyView()
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
