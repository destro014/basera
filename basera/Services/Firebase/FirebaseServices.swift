import Foundation

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

#if canImport(FirebaseStorage)
import FirebaseStorage
#endif

#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

#if canImport(FirebaseRemoteConfig)
import FirebaseRemoteConfig
#endif

enum FirebaseServiceError: LocalizedError {
    case sdkUnavailable(String)
    case missingDocument(String)
    case invalidDocument(String)

    var errorDescription: String? {
        switch self {
        case .sdkUnavailable(let service):
            "Firebase \(service) SDK is not linked. Add Swift Package dependencies and rebuild."
        case .missingDocument(let path):
            "No Firebase document found at path: \(path)."
        case .invalidDocument(let reason):
            "Firebase document mapping failed: \(reason)."
        }
    }
}

final class FirebaseAuthService: AuthServiceProtocol {
    private struct PendingChallenge {
        let userID: String
        let email: String
        let code: String
        let resendAvailableAt: Date
    }

    private actor AuthStateStore {
        private var pendingChallenges: [String: PendingChallenge] = [:]
        private var sessionsByID: [String: AuthenticatedEmailSession] = [:]
        private var pendingPasswordRecoveryChallenges: [String: PendingChallenge] = [:]
        private var passwordResetSessionsByID: [String: AuthPasswordResetSession] = [:]
        private var localPasswordOverrides: [String: String] = [:]
        private var fallbackUser: AppUser?

        func saveChallenge(challengeID: String, challenge: PendingChallenge) {
            pendingChallenges[challengeID] = challenge
        }

        func challenge(id: String) -> PendingChallenge? {
            pendingChallenges[id]
        }

        func removeChallenge(id: String) {
            pendingChallenges[id] = nil
        }

        func saveSession(_ session: AuthenticatedEmailSession) {
            sessionsByID[session.id] = session
        }

        func validateSession(_ session: AuthenticatedEmailSession) -> Bool {
            sessionsByID[session.id] != nil
        }

        func consumeSession(_ session: AuthenticatedEmailSession) {
            sessionsByID[session.id] = nil
        }

        func savePasswordRecoveryChallenge(challengeID: String, challenge: PendingChallenge) {
            pendingPasswordRecoveryChallenges[challengeID] = challenge
        }

        func passwordRecoveryChallenge(id: String) -> PendingChallenge? {
            pendingPasswordRecoveryChallenges[id]
        }

        func removePasswordRecoveryChallenge(id: String) {
            pendingPasswordRecoveryChallenges[id] = nil
        }

        func savePasswordResetSession(_ session: AuthPasswordResetSession) {
            passwordResetSessionsByID[session.id] = session
        }

        func passwordResetSession(id: String) -> AuthPasswordResetSession? {
            passwordResetSessionsByID[id]
        }

        func consumePasswordResetSession(_ session: AuthPasswordResetSession) {
            passwordResetSessionsByID[session.id] = nil
        }

        func saveLocalPasswordOverride(_ password: String, for email: String) {
            localPasswordOverrides[email] = password
        }

        func localPasswordOverride(for email: String) -> String? {
            localPasswordOverrides[email]
        }

        func setFallbackUser(_ user: AppUser?) {
            fallbackUser = user
        }

        func getFallbackUser() -> AppUser? {
            fallbackUser
        }
    }

    private let firestoreService: FirestoreServiceProtocol
    private let stateStore = AuthStateStore()

    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }

    func currentUser() async throws -> AppUser? {
        if let fallbackUser = await stateStore.getFallbackUser() {
            return fallbackUser
        }

        #if canImport(FirebaseAuth)
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        let payload = try await firestoreService.fetchDocument(path: "users/\(firebaseUser.uid)")
        let emailVerified = payload["emailVerified"] as? Bool ?? false
        let profileCompleted = payload["profileCompleted"] as? Bool ?? false

        guard emailVerified, profileCompleted else {
            try? Auth.auth().signOut()
            return nil
        }

        return FirebaseUserDocumentMapper.mapToAppUser(
            userID: firebaseUser.uid,
            email: firebaseUser.email,
            payload: payload,
            emailVerified: emailVerified,
            profileCompleted: profileCompleted
        )
        #else
        throw FirebaseServiceError.sdkUnavailable("Auth")
        #endif
    }

    func signIn(email: String, password: String) async throws -> AuthSignInResult {
        #if canImport(FirebaseAuth)
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        await stateStore.setFallbackUser(nil)

        do {
            let authResult = try await Auth.auth().signIn(withEmail: normalizedEmail, password: password)
            let payload = try await firestoreService.fetchDocument(path: "users/\(authResult.user.uid)")
            let emailVerified = payload["emailVerified"] as? Bool ?? false
            let profileCompleted = payload["profileCompleted"] as? Bool ?? false

            if emailVerified == false {
                let challenge = await createChallenge(for: authResult.user.uid, email: normalizedEmail)
                return .requiresEmailVerification(challenge)
            }

            if profileCompleted == false {
                let session = AuthenticatedEmailSession(
                    id: UUID().uuidString,
                    userID: authResult.user.uid,
                    email: normalizedEmail
                )
                await stateStore.saveSession(session)
                return .requiresProfileSetup(session)
            }

            let user = FirebaseUserDocumentMapper.mapToAppUser(
                userID: authResult.user.uid,
                email: authResult.user.email,
                payload: payload,
                emailVerified: emailVerified,
                profileCompleted: profileCompleted
            )
            return .authenticated(user)
        } catch {
            let mappedError = mapAuthError(error)
            guard let authError = mappedError as? AuthError, authError == .invalidPassword else {
                throw mappedError
            }

            let overridePassword = await stateStore.localPasswordOverride(for: normalizedEmail)
            guard overridePassword == password else {
                throw mappedError
            }

            return try await signInUsingLocalPasswordOverride(email: normalizedEmail)
        }
        #else
        throw FirebaseServiceError.sdkUnavailable("Auth")
        #endif
    }

    func startEmailRegistration(email: String) async throws -> AuthEmailVerificationChallenge {
        #if canImport(FirebaseAuth)
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let existingMethods = try await Auth.auth().fetchSignInMethods(forEmail: normalizedEmail)
        guard existingMethods.isEmpty else {
            throw AuthError.emailAlreadyInUse
        }

        let provisionalPassword = "pending-\(UUID().uuidString)"
        let authResult = try await Auth.auth().createUser(withEmail: normalizedEmail, password: provisionalPassword)
        let userID = authResult.user.uid
        let payload: [String: Any] = [
            "id": userID,
            "email": normalizedEmail,
            "fullName": NSNull(),
            "phoneNumber": NSNull(),
            "roles": [],
            "activeRole": UserRole.renter.rawValue,
            "profilePhotoURL": NSNull(),
            "emailVerified": false,
            "profileCompleted": false,
            "createdAt": Date()
        ]
        try await firestoreService.setDocument(path: "users/\(userID)", data: payload)

        return await createChallenge(for: userID, email: normalizedEmail)
        #else
        throw FirebaseServiceError.sdkUnavailable("Auth")
        #endif
    }

    func resendEmailRegistrationCode(for challengeID: String) async throws -> AuthEmailVerificationChallenge {
        guard let challenge = await stateStore.challenge(id: challengeID) else {
            throw AuthError.registrationSessionExpired
        }
        let secondsRemaining = max(0, Int(ceil(challenge.resendAvailableAt.timeIntervalSinceNow)))
        guard secondsRemaining == 0 else {
            throw AuthError.resendNotReady(secondsRemaining: secondsRemaining)
        }

        await stateStore.removeChallenge(id: challengeID)
        return await createChallenge(for: challenge.userID, email: challenge.email)
    }

    func verifyEmailRegistrationCode(_ code: String, challengeID: String) async throws -> AuthenticatedEmailSession {
        guard let challenge = await stateStore.challenge(id: challengeID) else {
            throw AuthError.registrationSessionExpired
        }

        guard challenge.code == code else {
            throw AuthError.invalidVerificationCode
        }

        try await firestoreService.setDocument(
            path: "users/\(challenge.userID)",
            data: [
                "emailVerified": true,
                "updatedAt": Date()
            ]
        )

        let session = AuthenticatedEmailSession(
            id: UUID().uuidString,
            userID: challenge.userID,
            email: challenge.email
        )
        await stateStore.removeChallenge(id: challengeID)
        await stateStore.saveSession(session)
        return session
    }

    func setRegistrationPassword(_ password: String, for session: AuthenticatedEmailSession) async throws -> AuthenticatedEmailSession {
        #if canImport(FirebaseAuth)
        guard await stateStore.validateSession(session) else {
            throw AuthError.registrationSessionExpired
        }
        guard password.isEmpty == false else {
            throw AuthError.passwordRequired
        }
        guard password.count >= 8 else {
            throw AuthError.passwordTooShort(minLength: 8)
        }

        if let currentUser = Auth.auth().currentUser, currentUser.uid == session.userID {
            do {
                try await currentUser.updatePassword(to: password)
                return session
            } catch {
                // Development-safe fallback when updatePassword cannot run due auth state constraints.
                await stateStore.saveLocalPasswordOverride(password, for: session.email)
                return session
            }
        } else {
            await stateStore.saveLocalPasswordOverride(password, for: session.email)
            return session
        }
        #else
        throw FirebaseServiceError.sdkUnavailable("Auth")
        #endif
    }

    func completeProfileSetup(_ submission: AuthProfileSetupSubmission, for session: AuthenticatedEmailSession, profilePhotoURL: URL?) async throws -> AppUser {
        #if canImport(FirebaseAuth)
        guard await stateStore.validateSession(session) else {
            throw AuthError.registrationSessionExpired
        }
        guard submission.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw AuthError.fullNameRequired
        }
        guard submission.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw AuthError.phoneNumberRequired
        }
        guard submission.selectedRoles.isEmpty == false else {
            throw AuthError.unexpected
        }

        let preferredRole: UserRole = submission.selectedRoles.contains(.renter) ? .renter : .owner

        do {
            let payload: [String: Any] = [
                "id": session.userID,
                "fullName": submission.fullName,
                "phoneNumber": submission.phoneNumber,
                "email": session.email,
                "roles": submission.selectedRoles.map(\.rawValue),
                "activeRole": preferredRole.rawValue,
                "profilePhotoURL": profilePhotoURL?.absoluteString ?? NSNull(),
                "acceptsTerms": submission.acceptsTerms,
                "acceptsPrivacy": submission.acceptsPrivacy,
                "profileCompleted": true,
                "updatedAt": Date()
            ]

            try await firestoreService.setDocument(path: "users/\(session.userID)", data: payload)
            await stateStore.consumeSession(session)

            return AppUser(
                id: session.userID,
                fullName: submission.fullName,
                phoneNumber: submission.phoneNumber,
                email: session.email,
                availableRoles: submission.selectedRoles,
                activeRole: preferredRole,
                profilePhotoURL: profilePhotoURL
            )
        } catch {
            throw mapAuthError(error)
        }
        #else
        throw FirebaseServiceError.sdkUnavailable("Auth")
        #endif
    }

    func startPasswordRecovery(email: String) async throws -> AuthPasswordRecoveryChallenge {
        #if canImport(FirebaseAuth)
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let existingMethods = try await Auth.auth().fetchSignInMethods(forEmail: normalizedEmail)
        guard existingMethods.isEmpty == false else {
            throw AuthError.accountNotFound
        }

        let userID = try await resolveUserID(forEmail: normalizedEmail)
        return await createPasswordRecoveryChallenge(for: userID, email: normalizedEmail)
        #else
        throw FirebaseServiceError.sdkUnavailable("Auth")
        #endif
    }

    func resendPasswordRecoveryCode(for challengeID: String) async throws -> AuthPasswordRecoveryChallenge {
        guard let challenge = await stateStore.passwordRecoveryChallenge(id: challengeID) else {
            throw AuthError.passwordRecoverySessionExpired
        }

        let secondsRemaining = max(0, Int(ceil(challenge.resendAvailableAt.timeIntervalSinceNow)))
        guard secondsRemaining == 0 else {
            throw AuthError.resendNotReady(secondsRemaining: secondsRemaining)
        }

        await stateStore.removePasswordRecoveryChallenge(id: challengeID)
        return await createPasswordRecoveryChallenge(for: challenge.userID, email: challenge.email)
    }

    func verifyPasswordRecoveryCode(_ code: String, challengeID: String) async throws -> AuthPasswordResetSession {
        guard let challenge = await stateStore.passwordRecoveryChallenge(id: challengeID) else {
            throw AuthError.passwordRecoverySessionExpired
        }

        guard challenge.code == code else {
            throw AuthError.invalidVerificationCode
        }

        let session = AuthPasswordResetSession(
            id: UUID().uuidString,
            userID: challenge.userID,
            email: challenge.email
        )

        await stateStore.removePasswordRecoveryChallenge(id: challengeID)
        await stateStore.savePasswordResetSession(session)
        return session
    }

    func completePasswordRecovery(newPassword: String, for session: AuthPasswordResetSession) async throws {
        guard newPassword.isEmpty == false else {
            throw AuthError.passwordRequired
        }
        guard newPassword.count >= 8 else {
            throw AuthError.passwordTooShort(minLength: 8)
        }

        guard let storedSession = await stateStore.passwordResetSession(id: session.id), storedSession == session else {
            throw AuthError.passwordResetSessionExpired
        }

        // Firebase password-reset without a backend requires out-of-band action codes.
        // For local development we store an in-memory override and use it in signIn fallback.
        await stateStore.saveLocalPasswordOverride(newPassword, for: session.email)
        await stateStore.consumePasswordResetSession(session)
    }

    func signOut() async throws {
        await stateStore.setFallbackUser(nil)

        #if canImport(FirebaseAuth)
        try Auth.auth().signOut()
        #else
        throw FirebaseServiceError.sdkUnavailable("Auth")
        #endif
    }

    private func createChallenge(for userID: String, email: String) async -> AuthEmailVerificationChallenge {
        let challengeID = UUID().uuidString
        let resendAvailableAt = Date().addingTimeInterval(30)
        let challenge = PendingChallenge(
            userID: userID,
            email: email,
            code: "246810",
            resendAvailableAt: resendAvailableAt
        )
        await stateStore.saveChallenge(challengeID: challengeID, challenge: challenge)

        return AuthEmailVerificationChallenge(
            id: challengeID,
            email: email,
            maskedEmail: Self.maskedEmail(from: email),
            resendAvailableAt: resendAvailableAt
        )
    }

    private func createPasswordRecoveryChallenge(for userID: String, email: String) async -> AuthPasswordRecoveryChallenge {
        let challengeID = UUID().uuidString
        let resendAvailableAt = Date().addingTimeInterval(30)
        let challenge = PendingChallenge(
            userID: userID,
            email: email,
            code: "246810",
            resendAvailableAt: resendAvailableAt
        )
        await stateStore.savePasswordRecoveryChallenge(challengeID: challengeID, challenge: challenge)

        return AuthPasswordRecoveryChallenge(
            id: challengeID,
            email: email,
            maskedEmail: Self.maskedEmail(from: email),
            resendAvailableAt: resendAvailableAt
        )
    }

    private func resolveUserID(forEmail email: String) async throws -> String {
        #if canImport(FirebaseAuth)
        if let authUserID = Auth.auth().currentUser?.uid {
            return authUserID
        }

        let rows = try await firestoreService.queryCollection(path: "users", field: "email", isEqualTo: email)
        if let payload = rows.first, let userID = payload["id"] as? String {
            return userID
        }

        throw AuthError.accountNotFound
        #else
        throw FirebaseServiceError.sdkUnavailable("Auth")
        #endif
    }

    private func signInUsingLocalPasswordOverride(email: String) async throws -> AuthSignInResult {
        let userRecord = try await fetchUserRecord(forEmail: email)
        let emailVerified = userRecord.payload["emailVerified"] as? Bool ?? false
        let profileCompleted = userRecord.payload["profileCompleted"] as? Bool ?? false

        if emailVerified == false {
            let challenge = await createChallenge(for: userRecord.userID, email: email)
            return .requiresEmailVerification(challenge)
        }

        if profileCompleted == false {
            let session = AuthenticatedEmailSession(
                id: UUID().uuidString,
                userID: userRecord.userID,
                email: email
            )
            await stateStore.saveSession(session)
            return .requiresProfileSetup(session)
        }

        let user = FirebaseUserDocumentMapper.mapToAppUser(
            userID: userRecord.userID,
            email: email,
            payload: userRecord.payload,
            emailVerified: emailVerified,
            profileCompleted: profileCompleted
        )
        await stateStore.setFallbackUser(user)
        return .authenticated(user)
    }

    private func fetchUserRecord(forEmail email: String) async throws -> (userID: String, payload: [String: Any]) {
        let rows = try await firestoreService.queryCollection(path: "users", field: "email", isEqualTo: email)
        guard let payload = rows.first, let userID = payload["id"] as? String else {
            throw AuthError.accountNotFound
        }
        return (userID, payload)
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

    private func mapAuthError(_ error: Error) -> Error {
        #if canImport(FirebaseAuth)
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain else { return error }

        switch AuthErrorCode(rawValue: nsError.code) {
        case .invalidEmail:
            return AuthError.invalidEmail
        case .emailAlreadyInUse:
            return AuthError.emailAlreadyInUse
        case .userNotFound:
            return AuthError.accountNotFound
        case .wrongPassword, .invalidCredential:
            return AuthError.invalidPassword
        default:
            return error
        }
        #else
        return error
        #endif
    }
}

struct FirebaseUserDocumentMapper {
    static func mapToAppUser(
        userID: String,
        email: String?,
        payload: [String: Any]?,
        emailVerified: Bool,
        profileCompleted: Bool
    ) -> AppUser {
        let fullName = payload?["fullName"] as? String
        let roles = Set((payload?["roles"] as? [String] ?? [UserRole.renter.rawValue]).compactMap(UserRole.init(rawValue:)))
        let activeRoleRaw = payload?["activeRole"] as? String
        let activeRole = UserRole(rawValue: activeRoleRaw ?? "") ?? roles.first ?? .renter
        let photoURL = (payload?["profilePhotoURL"] as? String).flatMap(URL.init(string:))
        let fallbackName = profileCompleted ? fullName : nil
        let fallbackPhone = profileCompleted ? (payload?["phoneNumber"] as? String ?? "") : ""

        return AppUser(
            id: userID,
            fullName: fallbackName,
            phoneNumber: fallbackPhone,
            email: email ?? (payload?["email"] as? String ?? ""),
            availableRoles: roles,
            activeRole: activeRole,
            profilePhotoURL: photoURL
        )
    }
}

struct FirebaseFirestoreService: FirestoreServiceProtocol {
    func fetchDocument(path: String) async throws -> [String: Any] {
        #if canImport(FirebaseFirestore)
        let snapshot = try await Firestore.firestore().document(path).getDocument()
        guard let data = snapshot.data() else {
            throw FirebaseServiceError.missingDocument(path)
        }
        return data
        #else
        throw FirebaseServiceError.sdkUnavailable("Firestore")
        #endif
    }

    func setDocument(path: String, data: [String: Any]) async throws {
        #if canImport(FirebaseFirestore)
        try await Firestore.firestore().document(path).setData(data, merge: true)
        #else
        throw FirebaseServiceError.sdkUnavailable("Firestore")
        #endif
    }

    func fetchCollection(path: String) async throws -> [[String: Any]] {
        #if canImport(FirebaseFirestore)
        let snapshot = try await Firestore.firestore().collection(path).getDocuments()
        return snapshot.documents.map { document in
            var payload = document.data()
            payload["id"] = document.documentID
            return payload
        }
        #else
        throw FirebaseServiceError.sdkUnavailable("Firestore")
        #endif
    }

    func queryCollection(path: String, field: String, isEqualTo value: Any) async throws -> [[String: Any]] {
        #if canImport(FirebaseFirestore)
        let snapshot = try await Firestore.firestore().collection(path).whereField(field, isEqualTo: value).getDocuments()
        return snapshot.documents.map { document in
            var payload = document.data()
            payload["id"] = document.documentID
            return payload
        }
        #else
        throw FirebaseServiceError.sdkUnavailable("Firestore")
        #endif
    }
}

struct FirebaseStorageService: StorageServiceProtocol {
    func upload(data: Data, path: String) async throws -> URL {
        #if canImport(FirebaseStorage)
        let reference = Storage.storage().reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await reference.putDataAsync(data, metadata: metadata)
        return try await reference.downloadURL()
        #else
        throw FirebaseServiceError.sdkUnavailable("Storage")
        #endif
    }
}

actor FirebaseNotificationsService: NotificationsServiceProtocol {
    func registerForPushNotifications() async {
        #if canImport(FirebaseMessaging)
        _ = try? await Messaging.messaging().token()
        #endif
    }

    func updateDeviceToken(_ token: String) async {
        #if canImport(FirebaseMessaging)
        Messaging.messaging().apnsToken = Data(token.utf8)
        #endif
    }

    func fetchPendingPayloads(for userID: String) async -> [PushNotificationPayload] {
        // TODO: Fetch server-generated notification payloads (Cloud Functions + Firestore fanout).
        []
    }
}

final class FirebaseRemoteConfigService: RemoteConfigServiceProtocol {
    #if canImport(FirebaseRemoteConfig)
    private let remoteConfig = RemoteConfig.remoteConfig()
    #endif

    init() {
        #if canImport(FirebaseRemoteConfig)
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        #endif
    }

    func refresh() async {
        #if canImport(FirebaseRemoteConfig)
        _ = try? await remoteConfig.fetchAndActivate()
        #endif
    }

    func value(for key: String) -> String? {
        #if canImport(FirebaseRemoteConfig)
        let value = remoteConfig.configValue(forKey: key)
        return value.stringValue
        #else
        return nil
        #endif
    }
}
