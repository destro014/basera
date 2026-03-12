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
            let session = AuthenticatedPhoneSession(
                id: UUID().uuidString,
                userID: existingUser.id,
                phoneNumber: challenge.phoneNumber
            )
            verifiedSessions[session.id] = session
            return .requiresPassword(session)
        }

        let session = AuthenticatedPhoneSession(
            id: UUID().uuidString,
            userID: "user-\(UUID().uuidString.prefix(8))",
            phoneNumber: challenge.phoneNumber
        )
        verifiedSessions[session.id] = session
        return .requiresOnboarding(session)
    }

    func signIn(withPassword password: String, for session: AuthenticatedPhoneSession) async throws -> AppUser {
        guard verifiedSessions[session.id] != nil else {
            throw AuthError.onboardingSessionExpired
        }
        guard let existingUser = registeredUsers[session.phoneNumber] else {
            throw AuthError.unexpected
        }
        // In a real app we would hash and check the password.
        guard password == "password" || !password.isEmpty else {
            throw AuthError.invalidPassword
        }

        try await simulateNetworkDelay()
        
        verifiedSessions[session.id] = nil
        signedInUser = existingUser
        return existingUser
    }

    func completeOnboarding(
        for session: AuthenticatedPhoneSession,
        fullName: String,
        passwordHash: String,
        roles: Set<UserRole>,
        acceptsTerms: Bool,
        acceptsPrivacy: Bool,
        profilePhotoURL: URL?
    ) async throws -> AppUser {
        guard verifiedSessions[session.id] != nil else {
            throw AuthError.onboardingSessionExpired
        }
        guard fullName.isEmpty == false else {
            throw AuthError.nameRequired
        }
        guard passwordHash.isEmpty == false else {
            throw AuthError.passwordRequired
        }
        guard roles.isEmpty == false else {
            throw AuthError.roleSelectionRequired
        }

        try await simulateNetworkDelay()

        let activeRole: UserRole = roles.contains(.renter) ? .renter : .owner
        let user = AppUser(
            id: session.userID,
            fullName: fullName,
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

actor MockAgreementConfirmationService: AgreementConfirmationServiceProtocol {
    private var challenges: [String: String] = [:]

    func requestOTP(agreementID: String, party: AgreementRecord.Party) async throws -> AgreementOTPChallenge {
        let challengeID = UUID().uuidString
        challenges[challengeID] = "123456"
        return AgreementOTPChallenge(
            challengeID: challengeID,
            agreementID: agreementID,
            party: party,
            expiresAt: Date().addingTimeInterval(120)
        )
    }

    func verifyOTP(challengeID: String, code: String) async throws -> Bool {
        defer { challenges[challengeID] = nil }
        return challenges[challengeID] == code
    }
}

struct MockAgreementPDFService: AgreementPDFServiceProtocol {
    func generatePDF(for agreement: AgreementRecord) async throws -> URL {
        URL(string: "https://example.com/mock/agreement/\(agreement.id).pdf")!
    }

    func downloadPDF(agreementID: String) async throws -> URL {
        URL(string: "https://example.com/mock/agreement/\(agreementID).pdf")!
    }
}

struct MockPaymentGatewayService: PaymentGatewayServiceProtocol {
    func createIntent(paymentID: String, method: PaymentRecord.Method, amount: Decimal) async throws -> PaymentGatewayIntent {
        let amountString = NSDecimalNumber(decimal: amount).stringValue
        let route = method == .eSewa ? "esewa" : "fonepay"
        return PaymentGatewayIntent(
            paymentID: paymentID,
            method: method,
            gatewayDisplayMessage: "Redirect to \(method.title) sandbox placeholder for NPR \(amountString).",
            deeplinkPlaceholder: URL(string: "https://sandbox.basera.app/pay/\(route)?payment=\(paymentID)")
        )
    }
}
