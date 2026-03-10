import Combine
import Foundation

@MainActor
final class AuthFlowViewModel: ObservableObject {
    @Published private(set) var step: AuthFlowStep = .introduction
    @Published var phoneNumber: String = ""
    @Published var otpCode: String = ""
    @Published var selectedRoles: Set<UserRole> = []
    @Published var acceptsTerms: Bool = false
    @Published var acceptsPrivacy: Bool = false
    @Published private(set) var selectedPhotoData: Data?
    @Published private(set) var challenge: AuthOTPChallenge?
    @Published private(set) var notice: AuthStepNotice?
    @Published private(set) var isLoading = false
    @Published private(set) var resendSecondsRemaining = 0

    private let authRepository: AuthRepositoryProtocol
    private var verifiedSession: AuthenticatedPhoneSession?
    private var resendCountdownTask: Task<Void, Never>?

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    deinit {
        resendCountdownTask?.cancel()
    }

    var canGoBack: Bool {
        step != .introduction && isLoading == false
    }

    var maskedPhoneNumber: String {
        challenge?.maskedPhoneNumber ?? NepalPhoneNumberFormatter.maskedPhoneNumber(from: challenge?.phoneNumber ?? phoneNumber)
    }

    var canResendCode: Bool {
        resendSecondsRemaining == 0 && challenge != nil && isLoading == false
    }

    var resendButtonTitle: String {
        resendSecondsRemaining == 0 ? "Resend code" : "Resend in \(resendSecondsRemaining)s"
    }

    var selectedRoleOption: UserRoleSelectionOption? {
        UserRoleSelectionOption.option(for: selectedRoles)
    }

    var hasSelectedPhoto: Bool {
        selectedPhotoData != nil
    }

    var phoneFieldError: String? {
        step == .phoneNumber && notice?.style == .error ? notice?.message : nil
    }

    var otpFieldError: String? {
        step == .otpVerification && notice?.style == .error ? notice?.message : nil
    }

    func continueFromIntroduction() {
        notice = nil
        step = .phoneNumber
    }

    func updatePhoneNumber(_ value: String) {
        phoneNumber = value
        clearErrorNotice(for: .phoneNumber)
    }

    func updateOTPCode(_ value: String) {
        otpCode = NepalPhoneNumberFormatter.sanitizedOTPCode(from: value)
        clearErrorNotice(for: .otpVerification)
    }

    func selectRoleOption(_ option: UserRoleSelectionOption) {
        selectedRoles = option.roles
        clearErrorNotice(for: .roleSelection)
    }

    func setAcceptsTerms(_ acceptsTerms: Bool) {
        self.acceptsTerms = acceptsTerms
        clearErrorNotice(for: .consent)
    }

    func setAcceptsPrivacy(_ acceptsPrivacy: Bool) {
        self.acceptsPrivacy = acceptsPrivacy
        clearErrorNotice(for: .consent)
    }

    func handleSelectedPhotoData(_ data: Data) {
        selectedPhotoData = data
        notice = AuthStepNotice(
            style: .success,
            message: "Profile photo selected. Basera will upload it when you finish onboarding."
        )
    }

    func handlePhotoSelectionFailure() {
        notice = AuthStepNotice(style: .error, message: AuthError.photoSelectionFailed.userMessage)
    }

    func submitPhoneNumber() async {
        guard let normalizedPhoneNumber = NepalPhoneNumberFormatter.normalizedPhoneNumber(from: phoneNumber) else {
            notice = AuthStepNotice(style: .error, message: AuthError.invalidPhoneNumber.userMessage)
            return
        }

        isLoading = true
        notice = nil

        do {
            let challenge = try await authRepository.requestOTP(for: normalizedPhoneNumber)
            self.challenge = challenge
            phoneNumber = NepalPhoneNumberFormatter.formattedDisplayString(from: normalizedPhoneNumber)
            otpCode = ""
            step = .otpVerification
            notice = AuthStepNotice(
                style: .info,
                message: "We sent a 6-digit OTP to \(challenge.maskedPhoneNumber)."
            )
            startResendCountdown(until: challenge.resendAvailableAt)
        } catch {
            notice = AuthStepNotice(style: .error, message: error.userMessage)
        }

        isLoading = false
    }

    func verifyOTP() async -> AppUser? {
        otpCode = NepalPhoneNumberFormatter.sanitizedOTPCode(from: otpCode)

        guard otpCode.count == 6 else {
            notice = AuthStepNotice(style: .error, message: AuthError.otpCodeRequired.userMessage)
            return nil
        }

        guard let challenge else {
            moveToPhoneNumberStep()
            notice = AuthStepNotice(style: .error, message: AuthError.onboardingSessionExpired.userMessage)
            return nil
        }

        isLoading = true
        notice = nil

        do {
            let result = try await authRepository.verifyOTP(otpCode, challengeID: challenge.id)
            switch result {
            case .signedIn(let user):
                stopResendCountdown()
                isLoading = false
                return user
            case .requiresOnboarding(let session):
                verifiedSession = session
                step = .roleSelection
                notice = AuthStepNotice(
                    style: .success,
                    message: "Phone verified. Finish a few onboarding steps to unlock Basera."
                )
            }
        } catch {
            notice = AuthStepNotice(style: .error, message: error.userMessage)
        }

        isLoading = false
        return nil
    }

    func resendOTP() async {
        guard let challenge else {
            moveToPhoneNumberStep()
            notice = AuthStepNotice(style: .error, message: AuthError.onboardingSessionExpired.userMessage)
            return
        }

        guard canResendCode else {
            notice = AuthStepNotice(
                style: .error,
                message: AuthError.resendNotReady(secondsRemaining: resendSecondsRemaining).userMessage
            )
            return
        }

        isLoading = true
        notice = nil

        do {
            let updatedChallenge = try await authRepository.resendOTP(for: challenge.id)
            self.challenge = updatedChallenge
            otpCode = ""
            notice = AuthStepNotice(
                style: .success,
                message: "A fresh OTP is on its way to \(updatedChallenge.maskedPhoneNumber)."
            )
            startResendCountdown(until: updatedChallenge.resendAvailableAt)
        } catch {
            notice = AuthStepNotice(style: .error, message: error.userMessage)
        }

        isLoading = false
    }

    func continueFromRoleSelection() {
        guard selectedRoles.isEmpty == false else {
            notice = AuthStepNotice(style: .error, message: AuthError.roleSelectionRequired.userMessage)
            return
        }

        step = .consent
        notice = nil
    }

    func continueFromConsent() {
        guard acceptsTerms else {
            notice = AuthStepNotice(style: .error, message: AuthError.termsConsentRequired.userMessage)
            return
        }
        guard acceptsPrivacy else {
            notice = AuthStepNotice(style: .error, message: AuthError.privacyConsentRequired.userMessage)
            return
        }

        step = .profilePhoto
        notice = AuthStepNotice(
            style: .info,
            message: "You can skip the photo for now and update it later from your profile."
        )
    }

    func completeOnboarding() async -> AppUser? {
        guard let verifiedSession else {
            moveToPhoneNumberStep()
            notice = AuthStepNotice(style: .error, message: AuthError.onboardingSessionExpired.userMessage)
            return nil
        }

        let submission = AuthOnboardingSubmission(
            selectedRoles: selectedRoles,
            acceptsTerms: acceptsTerms,
            acceptsPrivacy: acceptsPrivacy,
            profilePhotoData: selectedPhotoData
        )

        isLoading = true
        notice = nil

        do {
            let user = try await authRepository.completeOnboarding(submission, for: verifiedSession)
            isLoading = false
            return user
        } catch {
            notice = AuthStepNotice(style: .error, message: error.userMessage)
            isLoading = false
            return nil
        }
    }

    func skipPhotoAndComplete() async -> AppUser? {
        selectedPhotoData = nil
        return await completeOnboarding()
    }

    func goBack() {
        guard canGoBack else { return }

        notice = nil

        switch step {
        case .introduction:
            break
        case .phoneNumber:
            step = .introduction
        case .otpVerification:
            step = .phoneNumber
        case .roleSelection:
            step = .otpVerification
        case .consent:
            step = .roleSelection
        case .profilePhoto:
            step = .consent
        }
    }

    private func moveToPhoneNumberStep() {
        verifiedSession = nil
        stopResendCountdown()
        challenge = nil
        otpCode = ""
        step = .phoneNumber
    }

    private func startResendCountdown(until resendAvailableAt: Date) {
        stopResendCountdown()
        updateResendCountdown(until: resendAvailableAt)

        resendCountdownTask = Task { [weak self] in
            while let self, Task.isCancelled == false {
                self.updateResendCountdown(until: resendAvailableAt)

                if self.resendSecondsRemaining == 0 {
                    break
                }

                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    private func updateResendCountdown(until resendAvailableAt: Date) {
        resendSecondsRemaining = max(0, Int(ceil(resendAvailableAt.timeIntervalSinceNow)))
    }

    private func stopResendCountdown() {
        resendCountdownTask?.cancel()
        resendCountdownTask = nil
        resendSecondsRemaining = 0
    }

    private func clearErrorNotice(for step: AuthFlowStep) {
        guard self.step == step, notice?.style == .error else { return }
        notice = nil
    }
}

private extension Error {
    var userMessage: String {
        (self as? LocalizedError)?.errorDescription ?? AuthError.unexpected.errorDescription ?? "Something went wrong."
    }
}

private extension AuthError {
    var userMessage: String {
        errorDescription ?? "Something went wrong."
    }
}
