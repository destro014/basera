import Foundation

protocol AuthRepositoryProtocol {
    func restoreSession() async throws -> AppUser?
    func requestOTP(for phoneNumber: String) async throws -> AuthOTPChallenge
    func resendOTP(for challengeID: String) async throws -> AuthOTPChallenge
    func verifyOTP(_ code: String, challengeID: String) async throws -> AuthVerificationResult
    func completeOnboarding(_ submission: AuthOnboardingSubmission, for session: AuthenticatedPhoneSession) async throws -> AppUser
    func signOut() async throws
}
