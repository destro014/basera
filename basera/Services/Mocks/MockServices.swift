import Foundation

actor MockAuthService: AuthServiceProtocol {
    private enum PersistenceKeys {
        static let accounts = "mockAuth.registeredAccounts"
        static let currentUserEmail = "mockAuth.currentUserEmail"
    }

    private struct PendingChallenge {
        let id: String
        let userID: String
        let email: String
        let code: String
        let resendAvailableAt: Date
    }

    private struct PendingPasswordRecoveryChallenge {
        let id: String
        let userID: String
        let email: String
        let code: String
        let resendAvailableAt: Date
    }

    private struct RegisteredAccount {
        let id: String
        let email: String
        var password: String
        var fullName: String?
        var phoneNumber: String?
        var role: UserRole
        var profilePhotoURL: URL?
        var isEmailVerified: Bool
        var isProfileCompleted: Bool

        var appUser: AppUser {
            AppUser(
                id: id,
                fullName: fullName,
                phoneNumber: phoneNumber ?? "",
                email: email,
                role: role,
                profilePhotoURL: profilePhotoURL
            )
        }
    }

    private struct StoredAccount: Codable {
        let id: String
        let email: String
        let password: String
        let fullName: String?
        let phoneNumber: String?
        let role: String?
        let roles: [String]?
        let activeRole: String?
        let profilePhotoURL: String?
        let isEmailVerified: Bool?
        let isProfileCompleted: Bool?
    }

    private let defaults: UserDefaults
    private var signedInUser: AppUser?
    private var accountsByEmail: [String: RegisteredAccount] = [:]
    private var pendingChallenges: [String: PendingChallenge] = [:]
    private var verifiedSessions: [String: AuthenticatedEmailSession] = [:]
    private var pendingPasswordRecoveryChallenges: [String: PendingPasswordRecoveryChallenge] = [:]
    private var passwordResetSessions: [String: AuthPasswordResetSession] = [:]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.accountsByEmail = Self.loadAccounts(from: defaults)

        if let currentUserEmail = defaults.string(forKey: PersistenceKeys.currentUserEmail),
           let account = accountsByEmail[currentUserEmail],
           account.isEmailVerified,
           account.isProfileCompleted {
            self.signedInUser = account.appUser
        } else {
            self.signedInUser = nil
        }
    }

    func currentUser() async throws -> AppUser? {
        signedInUser
    }

    func signIn(email: String, password: String) async throws -> AuthSignInResult {
        try await simulateNetworkDelay()
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard let account = accountsByEmail[normalizedEmail] else {
            throw AuthError.accountNotFound
        }
        guard account.password == password else {
            throw AuthError.invalidPassword
        }

        if account.isEmailVerified == false {
            let challenge = createChallenge(for: account)
            return .requiresEmailVerification(challenge)
        }

        if account.isProfileCompleted == false {
            let session = AuthenticatedEmailSession(
                id: UUID().uuidString,
                userID: account.id,
                email: account.email
            )
            verifiedSessions[session.id] = session
            return .requiresProfileSetup(session)
        }

        signedInUser = account.appUser
        persistCurrentUserEmail()
        return .authenticated(account.appUser)
    }

    func startEmailRegistration(email: String) async throws -> AuthEmailVerificationChallenge {
        try await simulateNetworkDelay()

        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard accountsByEmail[normalizedEmail] == nil else {
            throw AuthError.emailAlreadyInUse
        }

        let account = RegisteredAccount(
            id: "user-\(UUID().uuidString.prefix(8))",
            email: normalizedEmail,
            password: "pending-\(UUID().uuidString)",
            fullName: nil,
            phoneNumber: nil,
            role: .renter,
            profilePhotoURL: nil,
            isEmailVerified: false,
            isProfileCompleted: false
        )
        accountsByEmail[normalizedEmail] = account
        persistAccounts()

        return createChallenge(for: account)
    }

    func resendEmailRegistrationCode(for challengeID: String) async throws -> AuthEmailVerificationChallenge {
        guard let existingChallenge = pendingChallenges[challengeID] else {
            throw AuthError.registrationSessionExpired
        }

        let secondsRemaining = max(0, Int(ceil(existingChallenge.resendAvailableAt.timeIntervalSinceNow)))
        guard secondsRemaining == 0 else {
            throw AuthError.resendNotReady(secondsRemaining: secondsRemaining)
        }

        guard let account = accountsByEmail[existingChallenge.email] else {
            throw AuthError.registrationSessionExpired
        }

        try await simulateNetworkDelay()
        pendingChallenges[challengeID] = nil
        return createChallenge(for: account)
    }

    func verifyEmailRegistrationCode(_ code: String, challengeID: String) async throws -> AuthenticatedEmailSession {
        guard let challenge = pendingChallenges[challengeID] else {
            throw AuthError.registrationSessionExpired
        }

        try await simulateNetworkDelay()

        guard challenge.code == code else {
            throw AuthError.invalidVerificationCode
        }

        pendingChallenges[challengeID] = nil

        guard var account = accountsByEmail[challenge.email], account.id == challenge.userID else {
            throw AuthError.registrationSessionExpired
        }

        account.isEmailVerified = true
        accountsByEmail[challenge.email] = account
        persistAccounts()

        let session = AuthenticatedEmailSession(
            id: UUID().uuidString,
            userID: challenge.userID,
            email: challenge.email
        )
        verifiedSessions[session.id] = session
        return session
    }

    func setRegistrationPassword(_ password: String, for session: AuthenticatedEmailSession) async throws -> AuthenticatedEmailSession {
        guard verifiedSessions[session.id] != nil else {
            throw AuthError.registrationSessionExpired
        }
        guard password.isEmpty == false else {
            throw AuthError.passwordRequired
        }
        guard password.count >= 8 else {
            throw AuthError.passwordTooShort(minLength: 8)
        }

        guard var account = accountsByEmail[session.email], account.id == session.userID else {
            throw AuthError.registrationSessionExpired
        }

        try await simulateNetworkDelay()
        account.password = password
        accountsByEmail[session.email] = account
        persistAccounts()
        return session
    }

    func completeProfileSetup(_ submission: AuthProfileSetupSubmission, for session: AuthenticatedEmailSession, profilePhotoURL: URL?) async throws -> AppUser {
        guard verifiedSessions[session.id] != nil else {
            throw AuthError.registrationSessionExpired
        }

        guard submission.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw AuthError.fullNameRequired
        }
        guard submission.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw AuthError.phoneNumberRequired
        }
        guard var account = accountsByEmail[session.email], account.id == session.userID else {
            throw AuthError.registrationSessionExpired
        }

        try await simulateNetworkDelay()

        account.fullName = submission.fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        account.phoneNumber = submission.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        account.role = submission.selectedRole
        account.profilePhotoURL = profilePhotoURL
        account.isProfileCompleted = true
        accountsByEmail[session.email] = account

        verifiedSessions[session.id] = nil
        persistAccounts()

        let user = account.appUser
        signedInUser = user
        persistCurrentUserEmail()
        return user
    }

    func startPasswordRecovery(email: String) async throws -> AuthPasswordRecoveryChallenge {
        try await simulateNetworkDelay()

        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let account = accountsByEmail[normalizedEmail] else {
            throw AuthError.accountNotFound
        }

        return createPasswordRecoveryChallenge(for: account)
    }

    func resendPasswordRecoveryCode(for challengeID: String) async throws -> AuthPasswordRecoveryChallenge {
        guard let existingChallenge = pendingPasswordRecoveryChallenges[challengeID] else {
            throw AuthError.passwordRecoverySessionExpired
        }

        let secondsRemaining = max(0, Int(ceil(existingChallenge.resendAvailableAt.timeIntervalSinceNow)))
        guard secondsRemaining == 0 else {
            throw AuthError.resendNotReady(secondsRemaining: secondsRemaining)
        }

        guard let account = accountsByEmail[existingChallenge.email], account.id == existingChallenge.userID else {
            throw AuthError.passwordRecoverySessionExpired
        }

        try await simulateNetworkDelay()
        pendingPasswordRecoveryChallenges[challengeID] = nil
        return createPasswordRecoveryChallenge(for: account)
    }

    func verifyPasswordRecoveryCode(_ code: String, challengeID: String) async throws -> AuthPasswordResetSession {
        guard let challenge = pendingPasswordRecoveryChallenges[challengeID] else {
            throw AuthError.passwordRecoverySessionExpired
        }

        try await simulateNetworkDelay()

        guard challenge.code == code else {
            throw AuthError.invalidVerificationCode
        }

        pendingPasswordRecoveryChallenges[challengeID] = nil

        guard let accountID = accountsByEmail[challenge.email]?.id, accountID == challenge.userID else {
            throw AuthError.passwordRecoverySessionExpired
        }

        let session = AuthPasswordResetSession(
            id: UUID().uuidString,
            userID: challenge.userID,
            email: challenge.email
        )
        passwordResetSessions[session.id] = session
        return session
    }

    func completePasswordRecovery(newPassword: String, for session: AuthPasswordResetSession) async throws {
        guard newPassword.isEmpty == false else {
            throw AuthError.passwordRequired
        }
        guard newPassword.count >= 8 else {
            throw AuthError.passwordTooShort(minLength: 8)
        }

        guard let storedSession = passwordResetSessions[session.id], storedSession == session else {
            throw AuthError.passwordResetSessionExpired
        }

        guard var account = accountsByEmail[session.email], account.id == session.userID else {
            throw AuthError.passwordResetSessionExpired
        }

        try await simulateNetworkDelay()
        account.password = newPassword
        accountsByEmail[session.email] = account
        passwordResetSessions[session.id] = nil
        persistAccounts()
    }

    func signOut() async throws {
        signedInUser = nil
        persistCurrentUserEmail()
    }

    private func createChallenge(for account: RegisteredAccount) -> AuthEmailVerificationChallenge {
        let challenge = PendingChallenge(
            id: UUID().uuidString,
            userID: account.id,
            email: account.email,
            code: "246810",
            resendAvailableAt: Date().addingTimeInterval(30)
        )
        pendingChallenges[challenge.id] = challenge

        return AuthEmailVerificationChallenge(
            id: challenge.id,
            email: account.email,
            maskedEmail: Self.maskedEmail(from: account.email),
            resendAvailableAt: challenge.resendAvailableAt
        )
    }

    private func createPasswordRecoveryChallenge(for account: RegisteredAccount) -> AuthPasswordRecoveryChallenge {
        let challenge = PendingPasswordRecoveryChallenge(
            id: UUID().uuidString,
            userID: account.id,
            email: account.email,
            code: "246810",
            resendAvailableAt: Date().addingTimeInterval(30)
        )
        pendingPasswordRecoveryChallenges[challenge.id] = challenge

        return AuthPasswordRecoveryChallenge(
            id: challenge.id,
            email: account.email,
            maskedEmail: Self.maskedEmail(from: account.email),
            resendAvailableAt: challenge.resendAvailableAt
        )
    }

    private static func maskedEmail(from email: String) -> String {
        let components = email.split(separator: "@", maxSplits: 1).map(String.init)
        guard components.count == 2 else { return email }

        let local = components[0]
        let domain = components[1]
        guard local.isEmpty == false else { return email }

        let firstCharacter = local.prefix(1)
        let maskedCount = max(2, local.count - 1)
        return "\(firstCharacter)\(String(repeating: "*", count: maskedCount))@\(domain)"
    }

    private func simulateNetworkDelay() async throws {
        try await Task.sleep(nanoseconds: 700_000_000)
    }

    private func persistAccounts() {
        let storedAccounts = accountsByEmail.values.map { account in
            StoredAccount(
                id: account.id,
                email: account.email,
                password: account.password,
                fullName: account.fullName,
                phoneNumber: account.phoneNumber,
                role: account.role.rawValue,
                roles: nil,
                activeRole: nil,
                profilePhotoURL: account.profilePhotoURL?.absoluteString,
                isEmailVerified: account.isEmailVerified,
                isProfileCompleted: account.isProfileCompleted
            )
        }

        if let data = try? JSONEncoder().encode(storedAccounts) {
            defaults.set(data, forKey: PersistenceKeys.accounts)
        }
    }

    private func persistCurrentUserEmail() {
        guard let signedInUser else {
            defaults.removeObject(forKey: PersistenceKeys.currentUserEmail)
            return
        }

        defaults.set(signedInUser.email, forKey: PersistenceKeys.currentUserEmail)
    }

    private static func loadAccounts(from defaults: UserDefaults) -> [String: RegisteredAccount] {
        guard let data = defaults.data(forKey: PersistenceKeys.accounts),
              let storedAccounts = try? JSONDecoder().decode([StoredAccount].self, from: data) else {
            return [:]
        }

        var accountsByEmail: [String: RegisteredAccount] = [:]

        for storedAccount in storedAccounts {
            let legacyRoles = Set((storedAccount.roles ?? []).compactMap(UserRole.init(rawValue:)))
            let resolvedRole =
                UserRole(rawValue: storedAccount.role ?? "")
                ?? UserRole(rawValue: storedAccount.activeRole ?? "")
                ?? legacyRoles.first
                ?? .renter
            let profileCompletedFromLegacy = (storedAccount.fullName?.isEmpty == false) && (storedAccount.phoneNumber?.isEmpty == false)

            accountsByEmail[storedAccount.email] = RegisteredAccount(
                id: storedAccount.id,
                email: storedAccount.email,
                password: storedAccount.password,
                fullName: storedAccount.fullName,
                phoneNumber: storedAccount.phoneNumber,
                role: resolvedRole,
                profilePhotoURL: storedAccount.profilePhotoURL.flatMap(URL.init(string:)),
                isEmailVerified: storedAccount.isEmailVerified ?? true,
                isProfileCompleted: storedAccount.isProfileCompleted ?? profileCompletedFromLegacy
            )
        }

        return accountsByEmail
    }
}

struct MockDatabaseService: DatabaseServiceProtocol {
    func fetchDocument(path: String) async throws -> [String: Any] {
        ["id": path.replacingOccurrences(of: "/", with: "-")]
    }

    func setDocument(path: String, data: [String: Any]) async throws {}

    func fetchCollection(path: String) async throws -> [[String: Any]] {
        _ = path
        return []
    }

    func queryCollection(path: String, field: String, isEqualTo value: Any) async throws -> [[String: Any]] {
        _ = (path, field, value)
        return []
    }
}

struct MockStorageService: StorageServiceProtocol {
    func upload(data: Data, path: String) async throws -> URL {
        URL(string: "https://example.com/mock/\(path)")!
    }
}

actor MockNotificationsService: NotificationsServiceProtocol {
    private var pendingPayloadsByUserID: [String: [PushNotificationPayload]]

    init(seedPayloadsByUserID: [String: [PushNotificationPayload]] = PreviewData.mockPushPayloadsByUserID) {
        self.pendingPayloadsByUserID = seedPayloadsByUserID
    }

    func registerForPushNotifications() async {}

    func updateDeviceToken(_ token: String) async {}

    func fetchPendingPayloads(for userID: String) async -> [PushNotificationPayload] {
        let payloads = pendingPayloadsByUserID[userID, default: []]
        pendingPayloadsByUserID[userID] = []
        return payloads
    }
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
