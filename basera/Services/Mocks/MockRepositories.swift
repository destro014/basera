import Foundation

struct MockAuthRepository: AuthRepositoryProtocol {
    private let authService: AuthServiceProtocol
    private let storageService: StorageServiceProtocol

    init(authService: AuthServiceProtocol, storageService: StorageServiceProtocol) {
        self.authService = authService
        self.storageService = storageService
    }

    func restoreSession() async throws -> AppUser? {
        try await authService.currentUser()
    }

    func requestOTP(for phoneNumber: String) async throws -> AuthOTPChallenge {
        try await authService.requestOTP(for: phoneNumber)
    }

    func resendOTP(for challengeID: String) async throws -> AuthOTPChallenge {
        try await authService.resendOTP(for: challengeID)
    }

    func verifyOTP(_ code: String, challengeID: String) async throws -> AuthVerificationResult {
        try await authService.verifyOTP(code, challengeID: challengeID)
    }

    func completeOnboarding(_ submission: AuthOnboardingSubmission, for session: AuthenticatedPhoneSession) async throws -> AppUser {
        let profilePhotoURL: URL?
        if let profilePhotoData = submission.profilePhotoData {
            profilePhotoURL = try await storageService.upload(
                data: profilePhotoData,
                path: "profile-photos/\(session.userID).jpg"
            )
        } else {
            profilePhotoURL = nil
        }

        return try await authService.completeOnboarding(
            for: session,
            roles: submission.selectedRoles,
            acceptsTerms: submission.acceptsTerms,
            acceptsPrivacy: submission.acceptsPrivacy,
            profilePhotoURL: profilePhotoURL
        )
    }

    func signOut() async throws {
        try await authService.signOut()
    }
}

struct MockListingsRepository: ListingsRepositoryProtocol {
    func fetchExploreListings() async throws -> [Listing] {
        PreviewData.featuredListings
    }
}

actor MockProfileRepository: ProfileRepositoryProtocol {
    private var bundlesByUserID: [String: UserProfileBundle]

    init(seedData: [String: UserProfileBundle] = PreviewData.profileBundles) {
        self.bundlesByUserID = seedData
    }

    func fetchProfiles(for userID: String) async throws -> UserProfileBundle {
        bundlesByUserID[userID, default: .init(renterProfile: nil, ownerProfile: nil)]
    }

    func saveRenterProfile(_ profile: RenterProfile, for userID: String) async throws {
        let current = bundlesByUserID[userID, default: .init(renterProfile: nil, ownerProfile: nil)]
        bundlesByUserID[userID] = UserProfileBundle(renterProfile: profile, ownerProfile: current.ownerProfile)
    }

    func saveOwnerProfile(_ profile: OwnerProfile, for userID: String) async throws {
        let current = bundlesByUserID[userID, default: .init(renterProfile: nil, ownerProfile: nil)]
        bundlesByUserID[userID] = UserProfileBundle(renterProfile: current.renterProfile, ownerProfile: profile)
    }
}
