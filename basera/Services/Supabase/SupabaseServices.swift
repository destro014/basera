import Foundation

enum SupabaseServiceError: LocalizedError {
    case missingConfiguration(String)
    case invalidPath(String)
    case missingDocument(String)
    case invalidDocument(String)
    case invalidResponse
    case requestFailed(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .missingConfiguration(let key):
            return "Missing Supabase configuration for \(key)."
        case .invalidPath(let path):
            return "Invalid document path: \(path)."
        case .missingDocument(let path):
            return "No document found at path: \(path)."
        case .invalidDocument(let reason):
            return "Document mapping failed: \(reason)."
        case .invalidResponse:
            return "Supabase returned an invalid response."
        case .requestFailed(let statusCode, let message):
            return "Supabase request failed (\(statusCode)): \(message)"
        }
    }
}

private struct SupabaseConfiguration {
    let baseURL: URL
    let anonKey: String
    let documentsTable: String
    let storageBucket: String

    static func load() throws -> SupabaseConfiguration {
        let environment = ProcessInfo.processInfo.environment
        let info = Bundle.main.infoDictionary ?? [:]

        func read(_ envKey: String, _ infoKey: String? = nil) -> String? {
            if let envValue = environment[envKey], envValue.isEmpty == false {
                return envValue
            }
            if let infoKey,
               let value = info[infoKey] as? String,
               value.isEmpty == false {
                return value
            }
            return nil
        }

        guard let baseURLString = read("BASERA_SUPABASE_URL", "BASERA_SUPABASE_URL"),
              let baseURL = URL(string: baseURLString) else {
            throw SupabaseServiceError.missingConfiguration("BASERA_SUPABASE_URL")
        }

        guard let anonKey = read("BASERA_SUPABASE_ANON_KEY", "BASERA_SUPABASE_ANON_KEY") else {
            throw SupabaseServiceError.missingConfiguration("BASERA_SUPABASE_ANON_KEY")
        }

        let documentsTable = read("BASERA_SUPABASE_DOCUMENTS_TABLE", "BASERA_SUPABASE_DOCUMENTS_TABLE") ?? "app_documents"
        let storageBucket = read("BASERA_SUPABASE_STORAGE_BUCKET", "BASERA_SUPABASE_STORAGE_BUCKET") ?? "basera-media"

        return SupabaseConfiguration(
            baseURL: baseURL,
            anonKey: anonKey,
            documentsTable: documentsTable,
            storageBucket: storageBucket
        )
    }
}

private enum SupabaseJSON {
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static func sanitize(_ value: Any) -> Any {
        switch value {
        case let string as String:
            return string
        case let number as NSNumber:
            return number
        case let bool as Bool:
            return bool
        case let int as Int:
            return int
        case let double as Double:
            return double
        case let decimal as Decimal:
            return NSDecimalNumber(decimal: decimal)
        case let date as Date:
            return dateFormatter.string(from: date)
        case let url as URL:
            return url.absoluteString
        case let dictionary as [String: Any]:
            return sanitize(dictionary)
        case let array as [Any]:
            return array.map(sanitize)
        case _ as NSNull:
            return NSNull()
        default:
            return String(describing: value)
        }
    }

    static func sanitize(_ dictionary: [String: Any]) -> [String: Any] {
        var output: [String: Any] = [:]
        output.reserveCapacity(dictionary.count)

        for (key, value) in dictionary {
            output[key] = sanitize(value)
        }

        return output
    }
}

struct SupabaseDatabaseService: DatabaseServiceProtocol {
    func fetchDocument(path: String) async throws -> [String: Any] {
        let (collection, documentID) = try parseDocumentPath(path)
        let endpoint = try documentsEndpoint([
            "select": "payload",
            "collection": "eq.\(collection)",
            "id": "eq.\(documentID)",
            "limit": "1"
        ])

        let request = try makeRequest(url: endpoint)
        let data = try await perform(request)
        guard
            let rows = try parseJSONArray(data) as? [[String: Any]],
            let payload = rows.first?["payload"] as? [String: Any]
        else {
            throw SupabaseServiceError.missingDocument(path)
        }

        return payload
    }

    func setDocument(path: String, data: [String: Any]) async throws {
        let (collection, documentID) = try parseDocumentPath(path)
        let endpoint = try documentsEndpoint([:])

        var request = try makeRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("resolution=merge-duplicates,return=minimal", forHTTPHeaderField: "Prefer")

        let body: [[String: Any]] = [[
            "id": documentID,
            "collection": collection,
            "payload": SupabaseJSON.sanitize(data),
            "updated_at": ISO8601DateFormatter().string(from: .now)
        ]]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        _ = try await perform(request)
    }

    func fetchCollection(path: String) async throws -> [[String: Any]] {
        let collection = try parseCollectionPath(path)
        let endpoint = try documentsEndpoint([
            "select": "payload",
            "collection": "eq.\(collection)"
        ])

        let request = try makeRequest(url: endpoint)
        let data = try await perform(request)
        guard let rows = try parseJSONArray(data) as? [[String: Any]] else {
            throw SupabaseServiceError.invalidResponse
        }

        return rows.compactMap { $0["payload"] as? [String: Any] }
    }

    func queryCollection(path: String, field: String, isEqualTo value: Any) async throws -> [[String: Any]] {
        let rows = try await fetchCollection(path: path)
        return rows.filter { payload in
            valuesEqual(payload[field], value)
        }
    }

    private func valuesEqual(_ lhs: Any?, _ rhs: Any) -> Bool {
        guard let lhs else { return false }

        switch (lhs, rhs) {
        case let (left as String, right as String):
            return left == right
        case let (left as NSNumber, right as NSNumber):
            return left == right
        case let (left as Bool, right as Bool):
            return left == right
        case let (left as Int, right as Int):
            return left == right
        case let (left as Double, right as Double):
            return left == right
        case let (left as String, right as CustomStringConvertible):
            return left == right.description
        case let (left as CustomStringConvertible, right as String):
            return left.description == right
        default:
            return String(describing: lhs) == String(describing: rhs)
        }
    }

    private func parseDocumentPath(_ path: String) throws -> (collection: String, documentID: String) {
        let components = path.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
        guard components.count == 2 else {
            throw SupabaseServiceError.invalidPath(path)
        }
        return (components[0], components[1])
    }

    private func parseCollectionPath(_ path: String) throws -> String {
        let components = path.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
        guard components.count == 1 else {
            throw SupabaseServiceError.invalidPath(path)
        }
        return components[0]
    }

    private func documentsEndpoint(_ query: [String: String]) throws -> URL {
        let configuration = try SupabaseConfiguration.load()
        let endpoint = configuration.baseURL
            .appendingPathComponent("rest")
            .appendingPathComponent("v1")
            .appendingPathComponent(configuration.documentsTable)

        guard var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false) else {
            throw SupabaseServiceError.invalidResponse
        }

        if query.isEmpty == false {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else {
            throw SupabaseServiceError.invalidResponse
        }

        return url
    }

    private func makeRequest(url: URL) throws -> URLRequest {
        let configuration = try SupabaseConfiguration.load()

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        request.setValue(configuration.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(configuration.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }

    private func perform(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw SupabaseServiceError.requestFailed(statusCode: httpResponse.statusCode, message: message)
        }

        return data
    }

    private func parseJSONArray(_ data: Data) throws -> Any {
        if data.isEmpty {
            return []
        }

        return try JSONSerialization.jsonObject(with: data, options: [])
    }
}

struct SupabaseStorageService: StorageServiceProtocol {
    func upload(data: Data, path: String) async throws -> URL {
        let configuration = try SupabaseConfiguration.load()
        let pathComponents = path.split(separator: "/", omittingEmptySubsequences: true).map(String.init)

        var uploadURL = configuration.baseURL
            .appendingPathComponent("storage")
            .appendingPathComponent("v1")
            .appendingPathComponent("object")
            .appendingPathComponent(configuration.storageBucket)

        for component in pathComponents {
            uploadURL.appendPathComponent(component)
        }

        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.httpBody = data
        request.setValue(configuration.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(configuration.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("true", forHTTPHeaderField: "x-upsert")

        let (responseData, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: responseData, encoding: .utf8) ?? "Unknown error"
            throw SupabaseServiceError.requestFailed(statusCode: httpResponse.statusCode, message: message)
        }

        var publicURL = configuration.baseURL
            .appendingPathComponent("storage")
            .appendingPathComponent("v1")
            .appendingPathComponent("object")
            .appendingPathComponent("public")
            .appendingPathComponent(configuration.storageBucket)

        for component in pathComponents {
            publicURL.appendPathComponent(component)
        }

        return publicURL
    }
}

actor SupabaseNotificationsService: NotificationsServiceProtocol {
    func registerForPushNotifications() async {}

    func updateDeviceToken(_ token: String) async {
        _ = token
    }

    func fetchPendingPayloads(for userID: String) async -> [PushNotificationPayload] {
        _ = userID
        return []
    }
}

final class SupabaseRemoteConfigService: RemoteConfigServiceProtocol {
    private let databaseService: DatabaseServiceProtocol
    private var cachedValues: [String: String] = [
        "home_banner_text": "Welcome to Basera"
    ]

    init(databaseService: DatabaseServiceProtocol) {
        self.databaseService = databaseService
    }

    func refresh() async {
        do {
            let payload = try await databaseService.fetchDocument(path: "remote_config/default")
            if let values = payload["values"] as? [String: String] {
                cachedValues = values
            }
        } catch {
            return
        }
    }

    func value(for key: String) -> String? {
        cachedValues[key]
    }
}

actor SupabaseAuthService: AuthServiceProtocol {
    private enum PersistenceKeys {
        static let accessToken = "supabaseAuth.accessToken"
        static let refreshToken = "supabaseAuth.refreshToken"
        static let currentUserEmail = "supabaseAuth.currentUserEmail"
    }

    private struct PendingChallenge {
        let id: String
        let email: String
        let resendAvailableAt: Date
    }

    private struct VerifiedSessionContext {
        let accessToken: String
        let refreshToken: String?
    }

    private struct PasswordResetContext {
        let accessToken: String
        let refreshToken: String?
    }

    private struct SupabaseSession {
        let accessToken: String
        let refreshToken: String?
        let userID: String
        let email: String
    }

    private struct ProfileDocument {
        let id: String
        let email: String
        let fullName: String?
        let phoneNumber: String
        let role: UserRole
        let profilePhotoURL: URL?

        var appUser: AppUser {
            AppUser(
                id: id,
                fullName: fullName,
                phoneNumber: phoneNumber,
                email: email,
                role: role,
                profilePhotoURL: profilePhotoURL
            )
        }

        var payload: [String: Any] {
            [
                "id": id,
                "email": email,
                "fullName": fullName as Any,
                "phoneNumber": phoneNumber,
                "role": role.rawValue,
                "profilePhotoURL": profilePhotoURL?.absoluteString as Any,
                "isProfileCompleted": true,
                "updatedAt": Date()
            ]
        }

        static func from(payload: [String: Any]) -> ProfileDocument? {
            guard
                let id = payload["id"] as? String,
                let email = payload["email"] as? String,
                let phoneNumber = payload["phoneNumber"] as? String,
                let roleRaw = payload["role"] as? String,
                let role = UserRole(rawValue: roleRaw)
            else {
                return nil
            }

            return ProfileDocument(
                id: id,
                email: email,
                fullName: payload["fullName"] as? String,
                phoneNumber: phoneNumber,
                role: role,
                profilePhotoURL: (payload["profilePhotoURL"] as? String).flatMap(URL.init(string:))
            )
        }
    }

    private let databaseService: DatabaseServiceProtocol
    private let defaults: UserDefaults

    private var signedInUser: AppUser?
    private var pendingChallenges: [String: PendingChallenge] = [:]
    private var verifiedSessions: [String: VerifiedSessionContext] = [:]
    private var pendingPasswordRecoveryChallenges: [String: PendingChallenge] = [:]
    private var passwordResetSessions: [String: PasswordResetContext] = [:]

    init(databaseService: DatabaseServiceProtocol, defaults: UserDefaults = .standard) {
        self.databaseService = databaseService
        self.defaults = defaults
    }

    func currentUser() async throws -> AppUser? {
        if let signedInUser {
            return signedInUser
        }

        guard let storedAccessToken = defaults.string(forKey: PersistenceKeys.accessToken) else {
            return nil
        }

        var activeSession = SupabaseSession(
            accessToken: storedAccessToken,
            refreshToken: defaults.string(forKey: PersistenceKeys.refreshToken),
            userID: "",
            email: defaults.string(forKey: PersistenceKeys.currentUserEmail) ?? ""
        )

        let authUser: (id: String, email: String)
        do {
            authUser = try await fetchAuthUser(accessToken: activeSession.accessToken)
        } catch {
            if isUnauthorized(error), let refreshToken = activeSession.refreshToken {
                activeSession = try await refreshAuthSession(
                    refreshToken: refreshToken,
                    fallbackEmail: defaults.string(forKey: PersistenceKeys.currentUserEmail)
                )
                persistSession(activeSession)
                authUser = try await fetchAuthUser(accessToken: activeSession.accessToken)
            } else {
                clearPersistedSession()
                return nil
            }
        }

        guard let profile = try await fetchProfileDocument(for: authUser.id) else {
            clearPersistedSession()
            return nil
        }

        let user = profile.appUser
        signedInUser = user
        defaults.set(user.email, forKey: PersistenceKeys.currentUserEmail)
        return user
    }

    func signIn(email: String, password: String) async throws -> AuthSignInResult {
        let normalizedEmail = normalized(email: email)

        let supabaseSession: SupabaseSession
        do {
            supabaseSession = try await signInWithPassword(email: normalizedEmail, password: password)
        } catch {
            if isEmailNotConfirmedError(error) {
                let challenge = try await issueEmailChallenge(for: normalizedEmail, createUserIfNeeded: false)
                return .requiresEmailVerification(challenge)
            }
            throw mappedAuthError(for: error, fallback: .invalidPassword)
        }

        guard let profile = try await fetchProfileDocument(for: supabaseSession.userID) else {
            let session = AuthenticatedEmailSession(
                id: UUID().uuidString,
                userID: supabaseSession.userID,
                email: supabaseSession.email
            )
            verifiedSessions[session.id] = VerifiedSessionContext(
                accessToken: supabaseSession.accessToken,
                refreshToken: supabaseSession.refreshToken
            )
            return .requiresProfileSetup(session)
        }

        let user = profile.appUser
        signedInUser = user
        persistSession(supabaseSession)
        return .authenticated(user)
    }

    func startEmailRegistration(email: String) async throws -> AuthEmailVerificationChallenge {
        let normalizedEmail = normalized(email: email)
        return try await issueEmailChallenge(for: normalizedEmail, createUserIfNeeded: true)
    }

    func resendEmailRegistrationCode(for challengeID: String) async throws -> AuthEmailVerificationChallenge {
        guard let challenge = pendingChallenges[challengeID] else {
            throw AuthError.registrationSessionExpired
        }

        let secondsRemaining = max(0, Int(ceil(challenge.resendAvailableAt.timeIntervalSinceNow)))
        guard secondsRemaining == 0 else {
            throw AuthError.resendNotReady(secondsRemaining: secondsRemaining)
        }

        pendingChallenges[challengeID] = nil
        return try await issueEmailChallenge(for: challenge.email, createUserIfNeeded: true)
    }

    func verifyEmailRegistrationCode(_ code: String, challengeID: String) async throws -> AuthenticatedEmailSession {
        guard let challenge = pendingChallenges[challengeID] else {
            throw AuthError.registrationSessionExpired
        }

        let verifiedSession: SupabaseSession
        do {
            verifiedSession = try await verifyOTP(
                email: challenge.email,
                token: code,
                types: ["signup", "email"]
            )
        } catch {
            throw mappedAuthError(for: error, fallback: .invalidVerificationCode)
        }

        pendingChallenges[challengeID] = nil

        let session = AuthenticatedEmailSession(
            id: UUID().uuidString,
            userID: verifiedSession.userID,
            email: verifiedSession.email
        )
        verifiedSessions[session.id] = VerifiedSessionContext(
            accessToken: verifiedSession.accessToken,
            refreshToken: verifiedSession.refreshToken
        )
        return session
    }

    func setRegistrationPassword(_ password: String, for session: AuthenticatedEmailSession) async throws -> AuthenticatedEmailSession {
        guard let context = verifiedSessions[session.id] else {
            throw AuthError.registrationSessionExpired
        }
        guard password.isEmpty == false else {
            throw AuthError.passwordRequired
        }
        guard password.count >= 8 else {
            throw AuthError.passwordTooShort(minLength: 8)
        }

        do {
            try await updateUserPassword(password, accessToken: context.accessToken)
        } catch {
            throw mappedAuthError(for: error, fallback: .registrationSessionExpired)
        }
        return session
    }

    func completeProfileSetup(_ submission: AuthProfileSetupSubmission, for session: AuthenticatedEmailSession, profilePhotoURL: URL?) async throws -> AppUser {
        guard let context = verifiedSessions[session.id] else {
            throw AuthError.registrationSessionExpired
        }

        let fullName = submission.fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneNumber = submission.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)

        guard fullName.isEmpty == false else {
            throw AuthError.fullNameRequired
        }
        guard phoneNumber.isEmpty == false else {
            throw AuthError.phoneNumberRequired
        }

        do {
            try await updateUserMetadata(
                [
                    "full_name": fullName,
                    "phone_number": phoneNumber,
                    "role": submission.selectedRole.rawValue,
                    "profile_completed": true
                ],
                accessToken: context.accessToken
            )
        } catch {
            throw mappedAuthError(for: error, fallback: .unexpected)
        }

        let profile = ProfileDocument(
            id: session.userID,
            email: session.email,
            fullName: fullName,
            phoneNumber: phoneNumber,
            role: submission.selectedRole,
            profilePhotoURL: profilePhotoURL
        )
        try await databaseService.setDocument(path: "user_profiles/\(profile.id)", data: profile.payload)

        verifiedSessions[session.id] = nil

        let user = profile.appUser
        signedInUser = user
        persistSession(
            SupabaseSession(
                accessToken: context.accessToken,
                refreshToken: context.refreshToken,
                userID: session.userID,
                email: session.email
            )
        )
        return user
    }

    func startPasswordRecovery(email: String) async throws -> AuthPasswordRecoveryChallenge {
        let normalizedEmail = normalized(email: email)
        return try await issuePasswordRecoveryChallenge(for: normalizedEmail)
    }

    func resendPasswordRecoveryCode(for challengeID: String) async throws -> AuthPasswordRecoveryChallenge {
        guard let challenge = pendingPasswordRecoveryChallenges[challengeID] else {
            throw AuthError.passwordRecoverySessionExpired
        }

        let secondsRemaining = max(0, Int(ceil(challenge.resendAvailableAt.timeIntervalSinceNow)))
        guard secondsRemaining == 0 else {
            throw AuthError.resendNotReady(secondsRemaining: secondsRemaining)
        }

        pendingPasswordRecoveryChallenges[challengeID] = nil
        return try await issuePasswordRecoveryChallenge(for: challenge.email)
    }

    func verifyPasswordRecoveryCode(_ code: String, challengeID: String) async throws -> AuthPasswordResetSession {
        guard let challenge = pendingPasswordRecoveryChallenges[challengeID] else {
            throw AuthError.passwordRecoverySessionExpired
        }

        let verifiedSession: SupabaseSession
        do {
            verifiedSession = try await verifyOTP(
                email: challenge.email,
                token: code,
                types: ["recovery", "email"]
            )
        } catch {
            throw mappedAuthError(for: error, fallback: .invalidVerificationCode)
        }

        pendingPasswordRecoveryChallenges[challengeID] = nil

        let session = AuthPasswordResetSession(
            id: UUID().uuidString,
            userID: verifiedSession.userID,
            email: verifiedSession.email
        )
        passwordResetSessions[session.id] = PasswordResetContext(
            accessToken: verifiedSession.accessToken,
            refreshToken: verifiedSession.refreshToken
        )
        return session
    }

    func completePasswordRecovery(newPassword: String, for session: AuthPasswordResetSession) async throws {
        guard newPassword.isEmpty == false else {
            throw AuthError.passwordRequired
        }
        guard newPassword.count >= 8 else {
            throw AuthError.passwordTooShort(minLength: 8)
        }

        guard let context = passwordResetSessions[session.id] else {
            throw AuthError.passwordResetSessionExpired
        }

        do {
            try await updateUserPassword(newPassword, accessToken: context.accessToken)
        } catch {
            throw mappedAuthError(for: error, fallback: .passwordResetSessionExpired)
        }

        passwordResetSessions[session.id] = nil
    }

    func signOut() async throws {
        if let accessToken = defaults.string(forKey: PersistenceKeys.accessToken) {
            try? await signOutRemote(accessToken: accessToken)
        }
        signedInUser = nil
        clearPersistedSession()
    }

    private func issueEmailChallenge(for email: String, createUserIfNeeded: Bool) async throws -> AuthEmailVerificationChallenge {
        do {
            try await sendEmailOTP(email: email, createUser: createUserIfNeeded)
        } catch {
            throw mappedAuthError(for: error, fallback: .unexpected)
        }

        let pending = PendingChallenge(
            id: UUID().uuidString,
            email: email,
            resendAvailableAt: Date().addingTimeInterval(30)
        )
        pendingChallenges[pending.id] = pending

        return AuthEmailVerificationChallenge(
            id: pending.id,
            email: email,
            maskedEmail: Self.maskedEmail(from: email),
            resendAvailableAt: pending.resendAvailableAt
        )
    }

    private func issuePasswordRecoveryChallenge(for email: String) async throws -> AuthPasswordRecoveryChallenge {
        do {
            try await sendEmailOTP(email: email, createUser: false)
        } catch {
            throw mappedAuthError(for: error, fallback: .accountNotFound)
        }

        let pending = PendingChallenge(
            id: UUID().uuidString,
            email: email,
            resendAvailableAt: Date().addingTimeInterval(30)
        )
        pendingPasswordRecoveryChallenges[pending.id] = pending

        return AuthPasswordRecoveryChallenge(
            id: pending.id,
            email: email,
            maskedEmail: Self.maskedEmail(from: email),
            resendAvailableAt: pending.resendAvailableAt
        )
    }

    private func fetchProfileDocument(for userID: String) async throws -> ProfileDocument? {
        do {
            let payload = try await databaseService.fetchDocument(path: "user_profiles/\(userID)")
            return ProfileDocument.from(payload: payload)
        } catch SupabaseServiceError.missingDocument {
            return nil
        }
    }

    private func signInWithPassword(email: String, password: String) async throws -> SupabaseSession {
        let request = try makeAuthRequest(
            path: "token",
            method: "POST",
            queryItems: [URLQueryItem(name: "grant_type", value: "password")],
            body: [
                "email": email,
                "password": password
            ]
        )
        let data = try await performAuthRequest(request)
        return try parseSession(from: data, fallbackEmail: email)
    }

    private func fetchAuthUser(accessToken: String) async throws -> (id: String, email: String) {
        let request = try makeAuthRequest(
            path: "user",
            method: "GET",
            accessToken: accessToken
        )
        let data = try await performAuthRequest(request)
        let object = try parseJSONObject(data)
        guard
            let userID = object["id"] as? String,
            let email = (object["email"] as? String)?.lowercased(),
            email.isEmpty == false
        else {
            throw SupabaseServiceError.invalidResponse
        }
        return (id: userID, email: email)
    }

    private func refreshAuthSession(refreshToken: String, fallbackEmail: String?) async throws -> SupabaseSession {
        let request = try makeAuthRequest(
            path: "token",
            method: "POST",
            queryItems: [URLQueryItem(name: "grant_type", value: "refresh_token")],
            body: [
                "refresh_token": refreshToken
            ]
        )
        let data = try await performAuthRequest(request)
        return try parseSession(from: data, fallbackEmail: fallbackEmail)
    }

    private func sendEmailOTP(email: String, createUser: Bool) async throws {
        let request = try makeAuthRequest(
            path: "otp",
            method: "POST",
            body: [
                "email": email,
                "create_user": createUser
            ]
        )
        _ = try await performAuthRequest(request)
    }

    private func verifyOTP(email: String, token: String, types: [String]) async throws -> SupabaseSession {
        var lastError: Error?

        for type in types {
            do {
                let request = try makeAuthRequest(
                    path: "verify",
                    method: "POST",
                    body: [
                        "email": email,
                        "token": token,
                        "type": type
                    ]
                )
                let data = try await performAuthRequest(request)
                return try parseSession(from: data, fallbackEmail: email)
            } catch {
                lastError = error
            }
        }

        throw lastError ?? SupabaseServiceError.invalidResponse
    }

    private func updateUserPassword(_ password: String, accessToken: String) async throws {
        let request = try makeAuthRequest(
            path: "user",
            method: "PUT",
            accessToken: accessToken,
            body: [
                "password": password
            ]
        )
        _ = try await performAuthRequest(request)
    }

    private func updateUserMetadata(_ metadata: [String: Any], accessToken: String) async throws {
        let request = try makeAuthRequest(
            path: "user",
            method: "PUT",
            accessToken: accessToken,
            body: [
                "data": metadata
            ]
        )
        _ = try await performAuthRequest(request)
    }

    private func signOutRemote(accessToken: String) async throws {
        let request = try makeAuthRequest(
            path: "logout",
            method: "POST",
            accessToken: accessToken
        )
        _ = try await performAuthRequest(request)
    }

    private func makeAuthRequest(
        path: String,
        method: String,
        queryItems: [URLQueryItem] = [],
        accessToken: String? = nil,
        body: [String: Any]? = nil
    ) throws -> URLRequest {
        let configuration = try SupabaseConfiguration.load()
        var endpoint = configuration.baseURL
            .appendingPathComponent("auth")
            .appendingPathComponent("v1")
            .appendingPathComponent(path)

        if queryItems.isEmpty == false {
            guard var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false) else {
                throw SupabaseServiceError.invalidResponse
            }
            components.queryItems = queryItems
            guard let url = components.url else {
                throw SupabaseServiceError.invalidResponse
            }
            endpoint = url
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = method
        request.timeoutInterval = 30
        request.setValue(configuration.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(accessToken ?? configuration.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body {
            request.httpBody = try JSONSerialization.data(withJSONObject: SupabaseJSON.sanitize(body))
        }

        return request
    }

    private func performAuthRequest(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseServiceError.invalidResponse
        }

        if AppRuntimeConfiguration.shouldEnableSupabaseDebugLogs {
            let path = request.url?.path ?? "-"
            print("[SupabaseAuth] \(request.httpMethod ?? "GET") \(path) -> \(httpResponse.statusCode)")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw SupabaseServiceError.requestFailed(
                statusCode: httpResponse.statusCode,
                message: parseErrorMessage(from: data)
            )
        }

        return data
    }

    private func parseErrorMessage(from data: Data) -> String {
        guard data.isEmpty == false else {
            return "Unknown error"
        }

        if let object = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            for key in ["msg", "message", "error_description", "error"] {
                if let value = object[key] as? String, value.isEmpty == false {
                    return value
                }
            }
        }

        return String(data: data, encoding: .utf8) ?? "Unknown error"
    }

    private func parseJSONObject(_ data: Data) throws -> [String: Any] {
        guard data.isEmpty == false else {
            throw SupabaseServiceError.invalidResponse
        }

        guard let object = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw SupabaseServiceError.invalidResponse
        }

        return object
    }

    private func parseSession(from data: Data, fallbackEmail: String?) throws -> SupabaseSession {
        let object = try parseJSONObject(data)
        let sessionObject = (object["session"] as? [String: Any]) ?? object
        let userObject = (object["user"] as? [String: Any]) ?? (sessionObject["user"] as? [String: Any]) ?? [:]

        guard
            let accessToken = sessionObject["access_token"] as? String,
            accessToken.isEmpty == false,
            let userID = userObject["id"] as? String,
            userID.isEmpty == false
        else {
            throw SupabaseServiceError.invalidResponse
        }

        let parsedEmail = (userObject["email"] as? String)?.lowercased()
        guard let resolvedEmail = parsedEmail ?? fallbackEmail, resolvedEmail.isEmpty == false else {
            throw SupabaseServiceError.invalidResponse
        }

        return SupabaseSession(
            accessToken: accessToken,
            refreshToken: sessionObject["refresh_token"] as? String,
            userID: userID,
            email: resolvedEmail
        )
    }

    private func persistSession(_ session: SupabaseSession) {
        defaults.set(session.accessToken, forKey: PersistenceKeys.accessToken)
        if let refreshToken = session.refreshToken, refreshToken.isEmpty == false {
            defaults.set(refreshToken, forKey: PersistenceKeys.refreshToken)
        } else {
            defaults.removeObject(forKey: PersistenceKeys.refreshToken)
        }
        defaults.set(session.email, forKey: PersistenceKeys.currentUserEmail)
    }

    private func clearPersistedSession() {
        defaults.removeObject(forKey: PersistenceKeys.accessToken)
        defaults.removeObject(forKey: PersistenceKeys.refreshToken)
        defaults.removeObject(forKey: PersistenceKeys.currentUserEmail)
    }

    private func isUnauthorized(_ error: Error) -> Bool {
        guard case let SupabaseServiceError.requestFailed(statusCode, _) = error else {
            return false
        }
        return statusCode == 401 || statusCode == 403
    }

    private func isEmailNotConfirmedError(_ error: Error) -> Bool {
        guard case let SupabaseServiceError.requestFailed(_, message) = error else {
            return false
        }
        let normalizedMessage = message.lowercased()
        return normalizedMessage.contains("email not confirmed")
            || normalizedMessage.contains("email_not_confirmed")
    }

    private func mappedAuthError(for error: Error, fallback: AuthError) -> AuthError {
        if let authError = error as? AuthError {
            return authError
        }

        guard case let SupabaseServiceError.requestFailed(_, message) = error else {
            return fallback
        }

        let normalizedMessage = message.lowercased()
        if normalizedMessage.contains("already registered")
            || normalizedMessage.contains("user already exists")
            || normalizedMessage.contains("email address already")
        {
            return .emailAlreadyInUse
        }
        if normalizedMessage.contains("invalid login credentials")
            || normalizedMessage.contains("invalid credentials")
            || normalizedMessage.contains("wrong password")
        {
            return .invalidPassword
        }
        if normalizedMessage.contains("invalid token")
            || normalizedMessage.contains("token has expired")
            || normalizedMessage.contains("otp")
            || normalizedMessage.contains("verification code")
        {
            return .invalidVerificationCode
        }
        if normalizedMessage.contains("not found")
            || normalizedMessage.contains("user does not exist")
            || normalizedMessage.contains("no rows")
        {
            return .accountNotFound
        }

        return fallback
    }

    private func normalized(email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
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
}
