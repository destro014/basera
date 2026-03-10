import Foundation

protocol AuthServiceProtocol {
    func currentUser() async throws -> AppUser?
    func requestOTP(for phoneNumber: String) async throws -> AuthOTPChallenge
    func resendOTP(for challengeID: String) async throws -> AuthOTPChallenge
    func verifyOTP(_ code: String, challengeID: String) async throws -> AuthVerificationResult
    func completeOnboarding(
        for session: AuthenticatedPhoneSession,
        roles: Set<UserRole>,
        acceptsTerms: Bool,
        acceptsPrivacy: Bool,
        profilePhotoURL: URL?
    ) async throws -> AppUser
    func signOut() async throws
}
