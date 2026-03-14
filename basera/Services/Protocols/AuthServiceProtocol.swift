import Foundation

protocol AuthServiceProtocol {
    func currentUser() async throws -> AppUser?
    func signIn(email: String, password: String) async throws -> AuthSignInResult
    func startEmailRegistration(email: String) async throws -> AuthEmailVerificationChallenge
    func resendEmailRegistrationCode(for challengeID: String) async throws -> AuthEmailVerificationChallenge
    func verifyEmailRegistrationCode(_ code: String, challengeID: String) async throws -> AuthenticatedEmailSession
    func setRegistrationPassword(_ password: String, for session: AuthenticatedEmailSession) async throws -> AuthenticatedEmailSession
    func completeProfileSetup(_ submission: AuthProfileSetupSubmission, for session: AuthenticatedEmailSession, profilePhotoURL: URL?) async throws -> AppUser
    func startPasswordRecovery(email: String) async throws -> AuthPasswordRecoveryChallenge
    func resendPasswordRecoveryCode(for challengeID: String) async throws -> AuthPasswordRecoveryChallenge
    func verifyPasswordRecoveryCode(_ code: String, challengeID: String) async throws -> AuthPasswordResetSession
    func completePasswordRecovery(newPassword: String, for session: AuthPasswordResetSession) async throws
    func signOut() async throws
}
