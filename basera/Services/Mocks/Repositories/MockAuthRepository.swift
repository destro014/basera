import Foundation

struct MockAuthRepository: AuthRepositoryProtocol {
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func restoreSession() async throws -> AppUser? {
        try await authService.currentUser()
    }

    func signIn(email: String, password: String) async throws -> AuthSignInResult {
        try await authService.signIn(email: email, password: password)
    }

    func startEmailRegistration(email: String) async throws -> AuthEmailVerificationChallenge {
        try await authService.startEmailRegistration(email: email)
    }

    func resendEmailRegistrationCode(for challengeID: String) async throws -> AuthEmailVerificationChallenge {
        try await authService.resendEmailRegistrationCode(for: challengeID)
    }

    func verifyEmailRegistrationCode(_ code: String, challengeID: String) async throws -> AuthenticatedEmailSession {
        try await authService.verifyEmailRegistrationCode(code, challengeID: challengeID)
    }

    func setRegistrationPassword(_ password: String, for session: AuthenticatedEmailSession) async throws -> AuthenticatedEmailSession {
        try await authService.setRegistrationPassword(password, for: session)
    }

    func completeProfileSetup(_ submission: AuthProfileSetupSubmission, for session: AuthenticatedEmailSession) async throws -> AppUser {
        let profilePhotoURL: URL?
        profilePhotoURL = nil
        return try await authService.completeProfileSetup(submission, for: session, profilePhotoURL: profilePhotoURL)
    }

    func startPasswordRecovery(email: String) async throws -> AuthPasswordRecoveryChallenge {
        try await authService.startPasswordRecovery(email: email)
    }

    func resendPasswordRecoveryCode(for challengeID: String) async throws -> AuthPasswordRecoveryChallenge {
        try await authService.resendPasswordRecoveryCode(for: challengeID)
    }

    func verifyPasswordRecoveryCode(_ code: String, challengeID: String) async throws -> AuthPasswordResetSession {
        try await authService.verifyPasswordRecoveryCode(code, challengeID: challengeID)
    }

    func completePasswordRecovery(newPassword: String, for session: AuthPasswordResetSession) async throws {
        try await authService.completePasswordRecovery(newPassword: newPassword, for: session)
    }

    func signOut() async throws {
        try await authService.signOut()
    }
}
