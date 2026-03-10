import Foundation

actor MockAuthService: AuthServiceProtocol {
    private struct PendingChallenge {
        let id: String
        let phoneNumber: String
        let code: String
        let resendAvailableAt: Date
    }

    private var signedInUser: AppUser?
    private var registeredUsers: [String: AppUser] = [:]
    private var pendingChallenges: [String: PendingChallenge] = [:]
    private var verifiedSessions: [String: AuthenticatedPhoneSession] = [:]

    func currentUser() async throws -> AppUser? {
        signedInUser
    }

    func requestOTP(for phoneNumber: String) async throws -> AuthOTPChallenge {
        try await simulateNetworkDelay()
        return createChallenge(for: phoneNumber)
    }

    func resendOTP(for challengeID: String) async throws -> AuthOTPChallenge {
        guard let existingChallenge = pendingChallenges[challengeID] else {
            throw AuthError.onboardingSessionExpired
        }

        let secondsRemaining = max(0, Int(ceil(existingChallenge.resendAvailableAt.timeIntervalSinceNow)))
        guard secondsRemaining == 0 else {
            throw AuthError.resendNotReady(secondsRemaining: secondsRemaining)
        }

        try await simulateNetworkDelay()
        pendingChallenges[challengeID] = nil
        return createChallenge(for: existingChallenge.phoneNumber)
    }

    func verifyOTP(_ code: String, challengeID: String) async throws -> AuthVerificationResult {
        guard let challenge = pendingChallenges[challengeID] else {
            throw AuthError.onboardingSessionExpired
        }

        try await simulateNetworkDelay()

        guard challenge.code == code else {
            throw AuthError.invalidOTP
        }

        pendingChallenges[challengeID] = nil

        if let existingUser = registeredUsers[challenge.phoneNumber] {
            signedInUser = existingUser
            return .signedIn(existingUser)
        }

        let session = AuthenticatedPhoneSession(
            id: UUID().uuidString,
            userID: "user-\(UUID().uuidString.prefix(8))",
            phoneNumber: challenge.phoneNumber
        )
        verifiedSessions[session.id] = session
        return .requiresOnboarding(session)
    }

    func completeOnboarding(
        for session: AuthenticatedPhoneSession,
        roles: Set<UserRole>,
        acceptsTerms: Bool,
        acceptsPrivacy: Bool,
        profilePhotoURL: URL?
    ) async throws -> AppUser {
        guard verifiedSessions[session.id] != nil else {
            throw AuthError.onboardingSessionExpired
        }
        guard roles.isEmpty == false else {
            throw AuthError.roleSelectionRequired
        }
        guard acceptsTerms else {
            throw AuthError.termsConsentRequired
        }
        guard acceptsPrivacy else {
            throw AuthError.privacyConsentRequired
        }

        try await simulateNetworkDelay()

        let activeRole: UserRole = roles.contains(.renter) ? .renter : .owner
        let user = AppUser(
            id: session.userID,
            fullName: nil,
            phoneNumber: session.phoneNumber,
            availableRoles: roles,
            activeRole: activeRole,
            profilePhotoURL: profilePhotoURL
        )

        registeredUsers[session.phoneNumber] = user
        verifiedSessions[session.id] = nil
        signedInUser = user
        return user
    }

    func signOut() async throws {
        signedInUser = nil
    }

    private func createChallenge(for phoneNumber: String) -> AuthOTPChallenge {
        let challenge = PendingChallenge(
            id: UUID().uuidString,
            phoneNumber: phoneNumber,
            code: "246810",
            resendAvailableAt: Date().addingTimeInterval(30)
        )
        pendingChallenges[challenge.id] = challenge

        return AuthOTPChallenge(
            id: challenge.id,
            phoneNumber: phoneNumber,
            maskedPhoneNumber: NepalPhoneNumberFormatter.maskedPhoneNumber(from: phoneNumber),
            resendAvailableAt: challenge.resendAvailableAt
        )
    }

    private func simulateNetworkDelay() async throws {
        try await Task.sleep(nanoseconds: 700_000_000)
    }
}

struct MockFirestoreService: FirestoreServiceProtocol {
    func fetchDocument(path: String) async throws -> [String: Any] {
        ["path": path, "source": "mock"]
    }

    func setDocument(path: String, data: [String: Any]) async throws {}
}

struct MockStorageService: StorageServiceProtocol {
    func upload(data: Data, path: String) async throws -> URL {
        URL(string: "https://example.com/mock/\(path)")!
    }
}

struct MockNotificationsService: NotificationsServiceProtocol {
    func registerForPushNotifications() async {}
    func updateDeviceToken(_ token: String) async {}
}

final class MockRemoteConfigService: RemoteConfigServiceProtocol {
    private let values: [String: String] = [
        "home_banner_text": "Welcome to Basera"
    ]

    func refresh() async {}

    func value(for key: String) -> String? {
        values[key]
    }
}
