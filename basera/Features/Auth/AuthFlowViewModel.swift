import Combine
import Foundation

@MainActor
final class AuthFlowViewModel: ObservableObject {
    @Published private(set) var rootStep: AuthFlowStep
    @Published var navigationPath: [AuthFlowStep] = [] {
        didSet {
            syncCurrentStepWithNavigation()
        }
    }
    @Published private(set) var step: AuthFlowStep

    @Published var loginEmail: String = ""
    @Published var loginPassword: String = ""

    @Published var registrationEmail: String = ""
    @Published var registrationPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var verificationCode: String = ""
    @Published var fullName: String = ""
    @Published var phoneNumber: String = ""
    @Published var selectedRole: UserRole = .renter

    @Published var passwordRecoveryEmail: String = ""
    @Published var passwordRecoveryCode: String = ""
    @Published var newPassword: String = ""
    @Published var confirmNewPassword: String = ""

    @Published private(set) var challenge: AuthEmailVerificationChallenge?
    @Published private(set) var verifiedSession: AuthenticatedEmailSession?
    @Published private(set) var passwordRecoveryChallenge: AuthPasswordRecoveryChallenge?
    @Published private(set) var passwordResetSession: AuthPasswordResetSession?
    @Published private(set) var passwordResetCompletedEmail: String?
    @Published private(set) var existingAccountEmailForSheet: String?
    @Published private(set) var passwordUpdatedEmailForSheet: String?
    @Published private(set) var notice: AuthStepNotice?
    @Published private(set) var isLoading = false
    @Published private(set) var resendSecondsRemaining = 0

    private enum Field: Hashable {
        case loginEmail
        case loginPassword
        case registrationEmail
        case registrationPassword
        case confirmPassword
        case verificationCode
        case fullName
        case phoneNumber
        case passwordRecoveryEmail
        case passwordRecoveryCode
        case newPassword
        case confirmNewPassword
    }

    @Published private var fieldErrors: [Field: String] = [:]

    private let authRepository: AuthRepositoryProtocol
    private let biometricLoginManager: BiometricLoginManagerProtocol
    private let minimumPasswordLength = 8
    private var resendCountdownTask: Task<Void, Never>?
    private var pendingCredentialsForCompletion: AuthCredentials?
    private var requiresRegistrationPasswordSetup = false
    private var knownExistingRegistrationEmail: String?
    private var passwordRecoveryUsesUnknownAccountChallenge = false

    init(
        authRepository: AuthRepositoryProtocol,
        biometricLoginManager: BiometricLoginManagerProtocol,
        initialStep: AuthFlowStep = .login
    ) {
        self.authRepository = authRepository
        self.biometricLoginManager = biometricLoginManager
        rootStep = initialStep
        step = initialStep
    }

    deinit {
        resendCountdownTask?.cancel()
    }

    var canResendCode: Bool {
        resendSecondsRemaining == 0
            && (challenge != nil || passwordRecoveryChallenge != nil)
            && isLoading == false
    }

    var resendButtonTitle: String {
        resendSecondsRemaining == 0 ? "Resend code" : "Resend in \(resendSecondsRemaining)s"
    }

    var canUseBiometricLogin: Bool {
        biometricLoginManager.canAttemptBiometricLogin && isLoading == false
    }

    var biometricLoginTitle: String {
        "Login with \(biometricLoginManager.biometryDisplayName)"
    }

    var loginEmailError: String? {
        fieldErrors[.loginEmail]
    }

    var loginPasswordError: String? {
        fieldErrors[.loginPassword]
    }

    var registrationEmailError: String? {
        fieldErrors[.registrationEmail]
    }

    var registrationPasswordError: String? {
        fieldErrors[.registrationPassword]
    }

    var confirmPasswordError: String? {
        fieldErrors[.confirmPassword]
    }

    var verificationCodeError: String? {
        fieldErrors[.verificationCode]
    }

    var fullNameError: String? {
        fieldErrors[.fullName]
    }

    var phoneNumberError: String? {
        fieldErrors[.phoneNumber]
    }

    var passwordRecoveryEmailError: String? {
        fieldErrors[.passwordRecoveryEmail]
    }

    var passwordRecoveryCodeError: String? {
        fieldErrors[.passwordRecoveryCode]
    }

    var newPasswordError: String? {
        fieldErrors[.newPassword]
    }

    var confirmNewPasswordError: String? {
        fieldErrors[.confirmNewPassword]
    }

    func moveToLogin() {
        stopResendCountdown()
        rootStep = .login
        navigationPath.removeAll()
        challenge = nil
        verifiedSession = nil
        registrationPassword = ""
        confirmPassword = ""
        requiresRegistrationPasswordSetup = false
        passwordRecoveryChallenge = nil
        passwordRecoveryUsesUnknownAccountChallenge = false
        passwordResetSession = nil
        passwordResetCompletedEmail = nil
        existingAccountEmailForSheet = nil
        knownExistingRegistrationEmail = nil
        passwordUpdatedEmailForSheet = nil
        selectedRole = .renter
        notice = nil
        clearFieldErrors()
        isLoading = false
    }

    func moveToRegistration() {
        stopResendCountdown()
        passwordRecoveryChallenge = nil
        passwordRecoveryUsesUnknownAccountChallenge = false
        passwordResetSession = nil
        passwordResetCompletedEmail = nil
        registrationPassword = ""
        confirmPassword = ""
        requiresRegistrationPasswordSetup = true
        selectedRole = .renter
        existingAccountEmailForSheet = nil
        passwordUpdatedEmailForSheet = nil
        notice = nil
        clearFieldErrors()

        if navigationPath.contains(.registration) == false {
            navigationPath.append(.registration)
        } else if let registrationIndex = navigationPath.firstIndex(of: .registration) {
            navigationPath = Array(navigationPath.prefix(registrationIndex + 1))
        }
    }

    func moveToPasswordRecovery() {
        stopResendCountdown()
        passwordRecoveryChallenge = nil
        passwordRecoveryUsesUnknownAccountChallenge = false
        passwordResetSession = nil
        passwordResetCompletedEmail = nil
        passwordRecoveryCode = ""
        newPassword = ""
        confirmNewPassword = ""
        if passwordRecoveryEmail.isEmpty {
            passwordRecoveryEmail = normalized(email: loginEmail)
        }

        existingAccountEmailForSheet = nil
        passwordUpdatedEmailForSheet = nil
        notice = nil
        clearFieldErrors()
        navigateToPasswordRecoveryEmail()
    }

    func dismissExistingAccountSheet() {
        existingAccountEmailForSheet = nil
    }

    func continueToLoginFromExistingAccountSheet() {
        let existingEmail = existingAccountEmailForSheet ?? normalized(email: registrationEmail)
        existingAccountEmailForSheet = nil
        loginEmail = existingEmail
        loginPassword = ""
        moveToLogin()
    }

    func dismissPasswordUpdatedSheet() {
        passwordUpdatedEmailForSheet = nil
    }

    func continueToLoginFromPasswordUpdatedSheet() {
        loginPassword = ""
        passwordUpdatedEmailForSheet = nil
    }

    func editRegistrationEmail() {
        stopResendCountdown()
        challenge = nil
        verifiedSession = nil
        verificationCode = ""
        registrationPassword = ""
        confirmPassword = ""
        pendingCredentialsForCompletion = nil
        requiresRegistrationPasswordSetup = true
        existingAccountEmailForSheet = nil
        notice = nil
        clearFieldErrors()

        if let registrationIndex = navigationPath.firstIndex(of: .registration) {
            navigationPath = Array(navigationPath.prefix(registrationIndex + 1))
        } else {
            moveToRegistration()
        }
    }

    func editPasswordRecoveryEmail() {
        stopResendCountdown()
        passwordRecoveryChallenge = nil
        passwordRecoveryUsesUnknownAccountChallenge = false
        passwordResetSession = nil
        passwordRecoveryCode = ""
        newPassword = ""
        confirmNewPassword = ""
        passwordResetCompletedEmail = nil
        notice = nil
        clearFieldErrors()
        navigateToPasswordRecoveryEmail()
    }

    func updateLoginEmail(_ value: String) {
        loginEmail = value
        clearFieldError(.loginEmail)
    }

    func updateLoginPassword(_ value: String) {
        loginPassword = value
        clearFieldError(.loginPassword)
    }

    func updateRegistrationEmail(_ value: String) {
        registrationEmail = value
        let normalizedInput = normalized(email: value)
        if let knownExistingRegistrationEmail, normalizedInput != knownExistingRegistrationEmail {
            self.knownExistingRegistrationEmail = nil
            existingAccountEmailForSheet = nil
        }
        clearFieldError(.registrationEmail)
    }

    func updateRegistrationPassword(_ value: String) {
        registrationPassword = value
        clearFieldError(.registrationPassword)
    }

    func updateConfirmPassword(_ value: String) {
        confirmPassword = value
        clearFieldError(.confirmPassword)
    }

    func updateVerificationCode(_ value: String) {
        verificationCode = String(value.filter(\.isNumber).prefix(6))
        clearFieldError(.verificationCode)
    }

    func updateFullName(_ value: String) {
        fullName = value
        clearFieldError(.fullName)
    }

    func updatePhoneNumber(_ value: String) {
        phoneNumber = value
        clearFieldError(.phoneNumber)
    }

    func updatePasswordRecoveryEmail(_ value: String) {
        passwordRecoveryEmail = value
        passwordRecoveryUsesUnknownAccountChallenge = false
        clearFieldError(.passwordRecoveryEmail)
    }

    func updatePasswordRecoveryCode(_ value: String) {
        passwordRecoveryCode = String(value.filter(\.isNumber).prefix(6))
        clearFieldError(.passwordRecoveryCode)
    }

    func updateNewPassword(_ value: String) {
        newPassword = value
        clearFieldError(.newPassword)
    }

    func updateConfirmNewPassword(_ value: String) {
        confirmNewPassword = value
        clearFieldError(.confirmNewPassword)
    }

    func signIn() async -> AuthFlowCompletion? {
        clearFieldErrors()
        notice = nil
        passwordUpdatedEmailForSheet = nil

        guard let credentials = validatedLoginCredentials() else {
            return nil
        }

        isLoading = true

        do {
            let result = try await authRepository.signIn(email: credentials.email, password: credentials.password)
            return handleSignInResult(result, credentials: credentials)
        } catch {
            handleSignInError(error, step: .login)
            return nil
        }
    }

    func signInWithBiometrics() async -> AuthFlowCompletion? {
        clearFieldErrors()
        notice = nil
        passwordUpdatedEmailForSheet = nil

        guard canUseBiometricLogin else {
            notice = AuthStepNotice(style: .error, message: AuthError.biometricUnavailable.userMessage)
            return nil
        }

        isLoading = true

        do {
            let credentials = try await biometricLoginManager.authenticateForLogin()
            let result = try await authRepository.signIn(email: credentials.email, password: credentials.password)
            return handleSignInResult(result, credentials: credentials, emitCredentialsOnSuccess: false)
        } catch {
            let authError = (error as? AuthError) ?? .unexpected
            if authError == .accountNotFound || authError == .invalidPassword || authError == .biometricCredentialsMissing {
                biometricLoginManager.disableBiometricLogin()
            }
            let noticeMessage = maskedCredentialFailureMessage(for: authError) ?? authError.userMessage
            notice = AuthStepNotice(style: .error, message: noticeMessage)
            isLoading = false
            return nil
        }
    }

    func startRegistration() async {
        clearFieldErrors()
        notice = nil
        existingAccountEmailForSheet = nil

        guard let email = validatedRegistrationEmail() else {
            return
        }

        if knownExistingRegistrationEmail == email {
            existingAccountEmailForSheet = email
            return
        }

        isLoading = true

        do {
            let challenge = try await authRepository.startEmailRegistration(email: email)
            self.challenge = challenge
            registrationEmail = email
            knownExistingRegistrationEmail = nil
            verificationCode = ""
            registrationPassword = ""
            confirmPassword = ""
            pendingCredentialsForCompletion = nil
            requiresRegistrationPasswordSetup = true
            navigateToVerification()
            notice = nil
            startResendCountdown(until: challenge.resendAvailableAt)
        } catch {
            let authError = (error as? AuthError) ?? .unexpected
            if authError == .emailAlreadyInUse {
                knownExistingRegistrationEmail = email
                existingAccountEmailForSheet = email
            } else {
                applyErrorState(error, for: .registration)
            }
        }

        isLoading = false
    }

    func verifyEmailCode() async {
        clearFieldError(.verificationCode)
        notice = nil

        if verifiedSession != nil {
            if requiresRegistrationPasswordSetup {
                navigateToRegistrationPassword()
            } else {
                navigateToRoleSelection()
            }
            return
        }

        let sanitizedCode = verificationCode.filter(\.isNumber)
        verificationCode = String(sanitizedCode.prefix(6))

        guard verificationCode.count == 6 else {
            setFieldError(.verificationCode, AuthError.verificationCodeRequired.userMessage)
            return
        }

        guard let challenge else {
            moveToRegistration()
            notice = AuthStepNotice(style: .error, message: AuthError.registrationSessionExpired.userMessage)
            return
        }

        isLoading = true

        do {
            let session = try await authRepository.verifyEmailRegistrationCode(verificationCode, challengeID: challenge.id)
            verifiedSession = session
            self.challenge = nil
            stopResendCountdown()
            if requiresRegistrationPasswordSetup {
                navigateToRegistrationPassword()
            } else {
                navigateToRoleSelection()
            }
            notice = nil
        } catch {
            applyErrorState(error, for: .emailVerification)
        }

        isLoading = false
    }

    func completeRegistrationPassword() async {
        clearFieldError(.registrationPassword)
        clearFieldError(.confirmPassword)
        notice = nil

        guard let session = verifiedSession else {
            moveToRegistration()
            notice = AuthStepNotice(style: .error, message: AuthError.registrationSessionExpired.userMessage)
            return
        }

        guard registrationPassword.isEmpty == false else {
            setFieldError(.registrationPassword, AuthError.passwordRequired.userMessage)
            return
        }
        guard registrationPassword.count >= minimumPasswordLength else {
            setFieldError(.registrationPassword, AuthError.passwordTooShort(minLength: minimumPasswordLength).userMessage)
            return
        }
        guard confirmPassword.isEmpty == false else {
            setFieldError(.confirmPassword, AuthError.confirmPasswordRequired.userMessage)
            return
        }
        guard registrationPassword == confirmPassword else {
            setFieldError(.confirmPassword, AuthError.passwordsDoNotMatch.userMessage)
            return
        }

        isLoading = true

        do {
            let updatedSession = try await authRepository.setRegistrationPassword(registrationPassword, for: session)
            verifiedSession = updatedSession
            pendingCredentialsForCompletion = AuthCredentials(
                email: updatedSession.email,
                password: registrationPassword
            )
            registrationPassword = ""
            confirmPassword = ""
            requiresRegistrationPasswordSetup = false
            navigateToRoleSelection()
            notice = nil
        } catch {
            applyErrorState(error, for: .registrationPassword)
        }

        isLoading = false
    }

    func resendEmailCode() async {
        guard let challenge else {
            moveToRegistration()
            notice = AuthStepNotice(style: .error, message: AuthError.registrationSessionExpired.userMessage)
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
            let updatedChallenge = try await authRepository.resendEmailRegistrationCode(for: challenge.id)
            self.challenge = updatedChallenge
            verificationCode = ""
            notice = AuthStepNotice(
                style: .success,
                message: "A new code was sent to \(updatedChallenge.maskedEmail)."
            )
            startResendCountdown(until: updatedChallenge.resendAvailableAt)
        } catch {
            notice = AuthStepNotice(style: .error, message: error.userMessage)
        }

        isLoading = false
    }

    func completeProfileSetup() async -> AuthFlowCompletion? {
        clearFieldErrors()

        guard let verifiedSession else {
            moveToRegistration()
            notice = AuthStepNotice(style: .error, message: AuthError.registrationSessionExpired.userMessage)
            return nil
        }

        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedName.isEmpty == false else {
            setFieldError(.fullName, AuthError.fullNameRequired.userMessage)
            return nil
        }
        guard trimmedPhone.isEmpty == false else {
            setFieldError(.phoneNumber, AuthError.phoneNumberRequired.userMessage)
            return nil
        }

        let submission = AuthProfileSetupSubmission(
            fullName: trimmedName,
            phoneNumber: trimmedPhone,
            selectedRole: selectedRole,
            acceptsTerms: true,
            acceptsPrivacy: true
        )

        isLoading = true
        notice = nil

        do {
            let user = try await authRepository.completeProfileSetup(submission, for: verifiedSession)
            isLoading = false
            let credentials = pendingCredentialsForCompletion
            pendingCredentialsForCompletion = nil
            return AuthFlowCompletion(user: user, credentials: credentials)
        } catch {
            notice = AuthStepNotice(style: .error, message: error.userMessage)
            isLoading = false
            return nil
        }
    }

    func continueToProfileSetupFromRoleSelection() {
        navigateToProfileSetup()
    }

    func startPasswordRecovery() async {
        clearFieldErrors()
        notice = nil

        guard let normalizedEmail = validatedPasswordRecoveryEmail() else {
            return
        }

        isLoading = true

        do {
            let challenge = try await authRepository.startPasswordRecovery(email: normalizedEmail)
            passwordRecoveryEmail = normalizedEmail
            passwordRecoveryChallenge = challenge
            passwordRecoveryUsesUnknownAccountChallenge = false
            passwordRecoveryCode = ""
            passwordResetSession = nil
            passwordResetCompletedEmail = nil
            navigateToPasswordRecoveryVerification()
            startResendCountdown(until: challenge.resendAvailableAt)
        } catch {
            let authError = (error as? AuthError) ?? .unexpected

            if authError == .accountNotFound {
                let placeholderChallenge = createUnknownAccountRecoveryChallenge(for: normalizedEmail)
                passwordRecoveryEmail = normalizedEmail
                passwordRecoveryChallenge = placeholderChallenge
                passwordRecoveryUsesUnknownAccountChallenge = true
                passwordRecoveryCode = ""
                passwordResetSession = nil
                passwordResetCompletedEmail = nil
                navigateToPasswordRecoveryVerification()
                startResendCountdown(until: placeholderChallenge.resendAvailableAt)
            } else {
                applyErrorState(error, for: .passwordRecoveryEmail)
            }
        }

        isLoading = false
    }

    func resendPasswordRecoveryCode() async {
        guard let challenge = passwordRecoveryChallenge else {
            editPasswordRecoveryEmail()
            notice = AuthStepNotice(style: .error, message: AuthError.passwordRecoverySessionExpired.userMessage)
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

        if passwordRecoveryUsesUnknownAccountChallenge {
            let placeholderChallenge = createUnknownAccountRecoveryChallenge(for: passwordRecoveryEmail)
            passwordRecoveryChallenge = placeholderChallenge
            passwordRecoveryCode = ""
            startResendCountdown(until: placeholderChallenge.resendAvailableAt)
            isLoading = false
            return
        }

        do {
            let updatedChallenge = try await authRepository.resendPasswordRecoveryCode(for: challenge.id)
            passwordRecoveryChallenge = updatedChallenge
            passwordRecoveryCode = ""
            startResendCountdown(until: updatedChallenge.resendAvailableAt)
        } catch {
            notice = AuthStepNotice(style: .error, message: error.userMessage)
        }

        isLoading = false
    }

    func verifyPasswordRecoveryCode() async {
        clearFieldError(.passwordRecoveryCode)
        notice = nil

        let sanitizedCode = passwordRecoveryCode.filter(\.isNumber)
        passwordRecoveryCode = String(sanitizedCode.prefix(6))

        guard passwordRecoveryCode.count == 6 else {
            setFieldError(.passwordRecoveryCode, AuthError.verificationCodeRequired.userMessage)
            return
        }

        guard let challenge = passwordRecoveryChallenge else {
            editPasswordRecoveryEmail()
            notice = AuthStepNotice(style: .error, message: AuthError.passwordRecoverySessionExpired.userMessage)
            return
        }

        isLoading = true

        if passwordRecoveryUsesUnknownAccountChallenge {
            isLoading = false
            setFieldError(.passwordRecoveryCode, AuthError.invalidVerificationCode.userMessage)
            return
        }

        do {
            let session = try await authRepository.verifyPasswordRecoveryCode(passwordRecoveryCode, challengeID: challenge.id)
            passwordResetSession = session
            passwordRecoveryChallenge = nil
            passwordRecoveryUsesUnknownAccountChallenge = false
            stopResendCountdown()
            navigateToPasswordRecoveryReset()
            notice = nil
        } catch {
            applyErrorState(error, for: .passwordRecoveryVerification)
        }

        isLoading = false
    }

    func completePasswordRecovery() async {
        clearFieldErrors()
        notice = nil

        guard let session = passwordResetSession else {
            editPasswordRecoveryEmail()
            notice = AuthStepNotice(style: .error, message: AuthError.passwordResetSessionExpired.userMessage)
            return
        }

        guard newPassword.isEmpty == false else {
            setFieldError(.newPassword, AuthError.passwordRequired.userMessage)
            return
        }
        guard newPassword.count >= minimumPasswordLength else {
            setFieldError(.newPassword, AuthError.passwordTooShort(minLength: minimumPasswordLength).userMessage)
            return
        }
        guard confirmNewPassword.isEmpty == false else {
            setFieldError(.confirmNewPassword, AuthError.confirmPasswordRequired.userMessage)
            return
        }
        guard newPassword == confirmNewPassword else {
            setFieldError(.confirmNewPassword, AuthError.passwordsDoNotMatch.userMessage)
            return
        }

        isLoading = true

        do {
            try await authRepository.completePasswordRecovery(newPassword: newPassword, for: session)
            passwordResetCompletedEmail = session.email
            passwordResetSession = nil
            passwordRecoveryCode = ""
            passwordRecoveryChallenge = nil
            passwordRecoveryUsesUnknownAccountChallenge = false
            newPassword = ""
            confirmNewPassword = ""
            loginEmail = session.email
            loginPassword = ""
            stopResendCountdown()
            moveToLogin()
            loginEmail = session.email
            passwordUpdatedEmailForSheet = session.email
            notice = nil
            isLoading = false
        } catch {
            applyErrorState(error, for: .passwordRecoveryReset)
            isLoading = false
        }
    }

    private func navigateToVerification() {
        var updatedPath = navigationPath

        if let registrationIndex = updatedPath.firstIndex(of: .registration) {
            updatedPath = Array(updatedPath.prefix(registrationIndex + 1))
        } else {
            updatedPath.append(.registration)
        }

        if updatedPath.last != .emailVerification {
            updatedPath.append(.emailVerification)
        }

        navigationPath = updatedPath
    }

    private func navigateToRegistrationPassword() {
        var updatedPath = navigationPath

        if let verificationIndex = updatedPath.firstIndex(of: .emailVerification) {
            updatedPath = Array(updatedPath.prefix(verificationIndex + 1))
        } else {
            navigateToVerification()
            updatedPath = navigationPath
        }

        if updatedPath.last != .registrationPassword {
            updatedPath.append(.registrationPassword)
        }

        navigationPath = updatedPath
    }

    private func navigateToPasswordRecoveryEmail() {
        var updatedPath = navigationPath

        if let recoveryIndex = updatedPath.firstIndex(of: .passwordRecoveryEmail) {
            updatedPath = Array(updatedPath.prefix(recoveryIndex + 1))
        } else {
            updatedPath.append(.passwordRecoveryEmail)
        }

        navigationPath = updatedPath
    }

    private func navigateToPasswordRecoveryVerification() {
        var updatedPath = navigationPath

        if let recoveryIndex = updatedPath.firstIndex(of: .passwordRecoveryEmail) {
            updatedPath = Array(updatedPath.prefix(recoveryIndex + 1))
        } else {
            updatedPath.append(.passwordRecoveryEmail)
        }

        if updatedPath.last != .passwordRecoveryVerification {
            updatedPath.append(.passwordRecoveryVerification)
        }

        navigationPath = updatedPath
    }

    private func navigateToPasswordRecoveryReset() {
        var updatedPath = navigationPath

        if let verificationIndex = updatedPath.firstIndex(of: .passwordRecoveryVerification) {
            updatedPath = Array(updatedPath.prefix(verificationIndex + 1))
        } else {
            navigateToPasswordRecoveryVerification()
            updatedPath = navigationPath
        }

        if updatedPath.last != .passwordRecoveryReset {
            updatedPath.append(.passwordRecoveryReset)
        }

        navigationPath = updatedPath
    }

    private func validatedLoginCredentials() -> AuthCredentials? {
        let normalizedEmail = normalized(email: loginEmail)
        guard normalizedEmail.isEmpty == false else {
            setFieldError(.loginEmail, AuthError.emailRequired.userMessage)
            return nil
        }
        guard isValidEmail(normalizedEmail) else {
            setFieldError(.loginEmail, AuthError.invalidEmail.userMessage)
            return nil
        }
        guard loginPassword.isEmpty == false else {
            setFieldError(.loginPassword, AuthError.passwordRequired.userMessage)
            return nil
        }

        return AuthCredentials(email: normalizedEmail, password: loginPassword)
    }

    private func validatedRegistrationEmail() -> String? {
        let normalizedEmail = normalized(email: registrationEmail)
        guard normalizedEmail.isEmpty == false else {
            setFieldError(.registrationEmail, AuthError.emailRequired.userMessage)
            return nil
        }
        guard isValidEmail(normalizedEmail) else {
            setFieldError(.registrationEmail, AuthError.invalidEmail.userMessage)
            return nil
        }

        return normalizedEmail
    }

    private func validatedPasswordRecoveryEmail() -> String? {
        let normalizedEmail = normalized(email: passwordRecoveryEmail)
        guard normalizedEmail.isEmpty == false else {
            setFieldError(.passwordRecoveryEmail, AuthError.emailRequired.userMessage)
            return nil
        }
        guard isValidEmail(normalizedEmail) else {
            setFieldError(.passwordRecoveryEmail, AuthError.invalidEmail.userMessage)
            return nil
        }

        return normalizedEmail
    }

    private func handleSignInResult(
        _ result: AuthSignInResult,
        credentials: AuthCredentials,
        emitCredentialsOnSuccess: Bool = true
    ) -> AuthFlowCompletion? {
        isLoading = false

        switch result {
        case .authenticated(let user):
            resetPostAuthenticationState()
            return AuthFlowCompletion(user: user, credentials: emitCredentialsOnSuccess ? credentials : nil)
        case .requiresEmailVerification(let challenge):
            challengeState(for: challenge, credentials: credentials)
            return nil
        case .requiresProfileSetup(let session):
            profileSetupState(for: session, credentials: credentials)
            return nil
        }
    }

    private func challengeState(for challenge: AuthEmailVerificationChallenge, credentials: AuthCredentials) {
        self.challenge = challenge
        verifiedSession = nil
        verificationCode = ""
        registrationEmail = credentials.email
        registrationPassword = credentials.password
        confirmPassword = credentials.password
        pendingCredentialsForCompletion = credentials
        requiresRegistrationPasswordSetup = false
        navigateToVerification()
        startResendCountdown(until: challenge.resendAvailableAt)
    }

    private func profileSetupState(for session: AuthenticatedEmailSession, credentials: AuthCredentials) {
        stopResendCountdown()
        challenge = nil
        verifiedSession = session
        pendingCredentialsForCompletion = credentials
        requiresRegistrationPasswordSetup = false
        navigateToRoleSelection()
    }

    private func resetPostAuthenticationState() {
        stopResendCountdown()
        challenge = nil
        verifiedSession = nil
        pendingCredentialsForCompletion = nil
        requiresRegistrationPasswordSetup = false
        knownExistingRegistrationEmail = nil
        passwordRecoveryChallenge = nil
        passwordRecoveryUsesUnknownAccountChallenge = false
        passwordResetSession = nil
        passwordResetCompletedEmail = nil
        existingAccountEmailForSheet = nil
        passwordUpdatedEmailForSheet = nil
        selectedRole = .renter
    }

    private func handleSignInError(_ error: Error, step: AuthFlowStep) {
        applyErrorState(error, for: step)
        isLoading = false
    }

    private func navigateToRoleSelection() {
        var updatedPath = navigationPath

        if let roleSelectionIndex = updatedPath.firstIndex(of: .roleSelection) {
            updatedPath = Array(updatedPath.prefix(roleSelectionIndex + 1))
            navigationPath = updatedPath
            return
        }

        if let registrationPasswordIndex = updatedPath.firstIndex(of: .registrationPassword) {
            updatedPath = Array(updatedPath.prefix(registrationPasswordIndex + 1))
        } else if let verificationIndex = updatedPath.firstIndex(of: .emailVerification) {
            updatedPath = Array(updatedPath.prefix(verificationIndex + 1))
        }

        if updatedPath.last != .roleSelection {
            updatedPath.append(.roleSelection)
        }

        navigationPath = updatedPath
    }

    private func navigateToProfileSetup() {
        var updatedPath = navigationPath

        if let profileIndex = updatedPath.firstIndex(of: .profileSetup) {
            updatedPath = Array(updatedPath.prefix(profileIndex + 1))
            navigationPath = updatedPath
            return
        }

        if let roleSelectionIndex = updatedPath.firstIndex(of: .roleSelection) {
            updatedPath = Array(updatedPath.prefix(roleSelectionIndex + 1))
        } else if let registrationPasswordIndex = updatedPath.firstIndex(of: .registrationPassword) {
            updatedPath = Array(updatedPath.prefix(registrationPasswordIndex + 1))
        } else if let verificationIndex = updatedPath.firstIndex(of: .emailVerification) {
            updatedPath = Array(updatedPath.prefix(verificationIndex + 1))
        }

        if updatedPath.last != .profileSetup {
            updatedPath.append(.profileSetup)
        }

        navigationPath = updatedPath
    }

    private func syncCurrentStepWithNavigation() {
        let resolvedStep = navigationPath.last ?? rootStep
        if step != resolvedStep {
            step = resolvedStep
            notice = nil
            clearFieldErrors()
        }
    }

    private func applyErrorState(_ error: Error, for step: AuthFlowStep) {
        let authError = (error as? AuthError) ?? .unexpected
        let noticeMessage = maskedCredentialFailureMessage(for: authError, step: step) ?? authError.userMessage
        notice = AuthStepNotice(style: .error, message: noticeMessage)

        switch (step, authError) {
        case (.login, .emailRequired), (.login, .invalidEmail):
            setFieldError(.loginEmail, authError.userMessage)
        case (.login, .passwordRequired):
            setFieldError(.loginPassword, authError.userMessage)

        case (.registration, .emailRequired), (.registration, .invalidEmail):
            setFieldError(.registrationEmail, authError.userMessage)
        case (.registrationPassword, .passwordRequired), (.registrationPassword, .passwordTooShort):
            setFieldError(.registrationPassword, authError.userMessage)
        case (.registrationPassword, .confirmPasswordRequired), (.registrationPassword, .passwordsDoNotMatch):
            setFieldError(.confirmPassword, authError.userMessage)

        case (.emailVerification, .verificationCodeRequired), (.emailVerification, .invalidVerificationCode):
            setFieldError(.verificationCode, authError.userMessage)

        case (.profileSetup, .fullNameRequired):
            setFieldError(.fullName, authError.userMessage)
        case (.profileSetup, .phoneNumberRequired):
            setFieldError(.phoneNumber, authError.userMessage)

        case (.passwordRecoveryEmail, .emailRequired),
             (.passwordRecoveryEmail, .invalidEmail):
            setFieldError(.passwordRecoveryEmail, authError.userMessage)

        case (.passwordRecoveryVerification, .verificationCodeRequired),
             (.passwordRecoveryVerification, .invalidVerificationCode):
            setFieldError(.passwordRecoveryCode, authError.userMessage)

        case (.passwordRecoveryReset, .passwordRequired),
             (.passwordRecoveryReset, .passwordTooShort):
            setFieldError(.newPassword, authError.userMessage)

        case (.passwordRecoveryReset, .confirmPasswordRequired),
             (.passwordRecoveryReset, .passwordsDoNotMatch):
            setFieldError(.confirmNewPassword, authError.userMessage)
        default:
            break
        }
    }

    private func maskedCredentialFailureMessage(for authError: AuthError, step: AuthFlowStep = .login) -> String? {
        guard step == .login else { return nil }
        guard authError == .accountNotFound || authError == .invalidPassword else { return nil }
        return "Please enter a valid email and password."
    }

    private func createUnknownAccountRecoveryChallenge(for email: String) -> AuthPasswordRecoveryChallenge {
        let normalizedEmail = normalized(email: email)
        return AuthPasswordRecoveryChallenge(
            id: "unknown-recovery-\(UUID().uuidString)",
            email: normalizedEmail,
            maskedEmail: maskedEmail(from: normalizedEmail),
            resendAvailableAt: Date().addingTimeInterval(30)
        )
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

    private func normalized(email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func maskedEmail(from email: String) -> String {
        let components = email.split(separator: "@", maxSplits: 1).map(String.init)
        guard components.count == 2 else { return email }

        let local = components[0]
        let domain = components[1]
        guard local.isEmpty == false else { return email }

        let firstCharacter = local.prefix(1)
        let maskedCount = max(2, local.count - 1)
        return "\(firstCharacter)\(String(repeating: "*", count: maskedCount))@\(domain)"
    }

    private func isValidEmail(_ value: String) -> Bool {
        let expression = #/^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/#
        return value.wholeMatch(of: expression) != nil
    }

    private func clearFieldErrors() {
        fieldErrors.removeAll()
    }

    private func clearFieldError(_ field: Field) {
        fieldErrors[field] = nil
    }

    private func setFieldError(_ field: Field, _ message: String) {
        fieldErrors[field] = message
        if notice?.style == .error {
            notice = nil
        }
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
