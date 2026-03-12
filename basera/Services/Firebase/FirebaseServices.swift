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
        let verificationID: String
        let phoneNumber: String
        let resendAvailableAt: Date
    }

    private actor AuthStateStore {
        private var pendingChallenges: [String: PendingChallenge] = [:]
        private var sessionsByID: [String: AuthenticatedPhoneSession] = [:]

        func saveChallenge(challengeID: String, challenge: PendingChallenge) {
            pendingChallenges[challengeID] = challenge
        }

        func challenge(id: String) -> PendingChallenge? {
            pendingChallenges[id]
        }

        func removeChallenge(id: String) {
            pendingChallenges[id] = nil
        }

        func saveSession(_ session: AuthenticatedPhoneSession) {
            sessionsByID[session.id] = session
        }

        func validateSession(_ session: AuthenticatedPhoneSession) -> Bool {
            sessionsByID[session.id] != nil
        }

        func consumeSession(_ session: AuthenticatedPhoneSession) {
            sessionsByID[session.id] = nil
        }
    }

    private let firestoreService: FirestoreServiceProtocol
    private let stateStore = AuthStateStore()

    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }

    func currentUser() async throws -> AppUser? {
        #if canImport(FirebaseAuth)
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        let payload = try? await firestoreService.fetchDocument(path: "users/\(firebaseUser.uid)")
        return FirebaseUserDocumentMapper.mapToAppUser(
            userID: firebaseUser.uid,
            phoneNumber: firebaseUser.phoneNumber,
            payload: payload
        )
        #else
        throw FirebaseServiceError.sdkUnavailable("Auth")
        #endif
    }

    func requestOTP(for phoneNumber: String) async throws -> AuthOTPChallenge {
        #if canImport(FirebaseAuth)
        let verificationID = try await withCheckedThrowingContinuation { continuation in
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let verificationID else {
                    continuation.resume(throwing: AuthError.unexpected)
                    return
                }

                continuation.resume(returning: verificationID)
            }
        }

        let challengeID = UUID().uuidString
        let resendAvailableAt = Date().addingTimeInterval(30)
        await stateStore.saveChallenge(
            challengeID: challengeID,
            challenge: PendingChallenge(
                verificationID: verificationID,
                phoneNumber: phoneNumber,
                resendAvailableAt: resendAvailableAt
            )
        )

        return AuthOTPChallenge(
            id: challengeID,
            phoneNumber: phoneNumber,
            maskedPhoneNumber: NepalPhoneNumberFormatter.maskedPhoneNumber(from: phoneNumber),
            resendAvailableAt: resendAvailableAt
        )
        #else
        throw FirebaseServiceError.sdkUnavailable("Auth")
        #endif
    }

    func resendOTP(for challengeID: String) async throws -> AuthOTPChallenge {
        guard let challenge = await stateStore.challenge(id: challengeID) else {
            throw AuthError.onboardingSessionExpired
        }
        let secondsRemaining = max(0, Int(ceil(challenge.resendAvailableAt.timeIntervalSinceNow)))
        guard secondsRemaining == 0 else {
            throw AuthError.resendNotReady(secondsRemaining: secondsRemaining)
        }

        await stateStore.removeChallenge(id: challengeID)
        return try await requestOTP(for: challenge.phoneNumber)
    }

    func verifyOTP(_ code: String, challengeID: String) async throws -> AuthVerificationResult {
        #if canImport(FirebaseAuth)
        guard let challenge = await stateStore.challenge(id: challengeID) else {
            throw AuthError.onboardingSessionExpired
        }

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: challenge.verificationID,
            verificationCode: code
        )

        let authResult = try await Auth.auth().signIn(with: credential)
        await stateStore.removeChallenge(id: challengeID)

        let userID = authResult.user.uid
        let session = AuthenticatedPhoneSession(id: UUID().uuidString, userID: userID, phoneNumber: challenge.phoneNumber)
        await stateStore.saveSession(session)

        do {
            let userDoc = try await firestoreService.fetchDocument(path: "users/\(userID)")
            let hasPassword = (userDoc["passwordHash"] as? String)?.isEmpty == false
            return hasPassword ? .requiresPassword(session) : .requiresOnboarding(session)
        } catch {
            return .requiresOnboarding(session)
        }
        #else
        throw FirebaseServiceError.sdkUnavailable("Auth")
        #endif
    }

    func signIn(withPassword password: String, for session: AuthenticatedPhoneSession) async throws -> AppUser {
        guard await stateStore.validateSession(session) else {
            throw AuthError.onboardingSessionExpired
        }
        let userDoc = try await firestoreService.fetchDocument(path: "users/\(session.userID)")
        let savedHash = userDoc["passwordHash"] as? String ?? ""
        guard savedHash.isEmpty == false, savedHash == password else {
            throw AuthError.invalidPassword
        }

        let user = FirebaseUserDocumentMapper.mapToAppUser(userID: session.userID, phoneNumber: session.phoneNumber, payload: userDoc)
        await stateStore.consumeSession(session)
        return user
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
        guard await stateStore.validateSession(session) else {
            throw AuthError.onboardingSessionExpired
        }

        let preferredRole: UserRole = roles.contains(.renter) ? .renter : .owner
        let payload: [String: Any] = [
            "id": session.userID,
            "fullName": fullName,
            "phoneNumber": session.phoneNumber,
            "roles": roles.map(\.rawValue),
            "activeRole": preferredRole.rawValue,
            "profilePhotoURL": profilePhotoURL?.absoluteString ?? NSNull(),
            "passwordHash": passwordHash,
            "acceptsTerms": acceptsTerms,
            "acceptsPrivacy": acceptsPrivacy,
            "createdAt": Date()
        ]

        try await firestoreService.setDocument(path: "users/\(session.userID)", data: payload)
        await stateStore.consumeSession(session)

        return AppUser(
            id: session.userID,
            fullName: fullName,
            phoneNumber: session.phoneNumber,
            availableRoles: roles,
            activeRole: preferredRole,
            profilePhotoURL: profilePhotoURL
        )
    }

    func signOut() async throws {
        #if canImport(FirebaseAuth)
        try Auth.auth().signOut()
        #else
        throw FirebaseServiceError.sdkUnavailable("Auth")
        #endif
    }
}

struct FirebaseUserDocumentMapper {
    static func mapToAppUser(userID: String, phoneNumber: String?, payload: [String: Any]?) -> AppUser {
        let fullName = payload?["fullName"] as? String
        let roles = Set((payload?["roles"] as? [String] ?? [UserRole.renter.rawValue]).compactMap(UserRole.init(rawValue:)))
        let activeRoleRaw = payload?["activeRole"] as? String
        let activeRole = UserRole(rawValue: activeRoleRaw ?? "") ?? roles.first ?? .renter
        let photoURL = (payload?["profilePhotoURL"] as? String).flatMap(URL.init(string:))

        return AppUser(
            id: userID,
            fullName: fullName,
            phoneNumber: phoneNumber ?? (payload?["phoneNumber"] as? String ?? ""),
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
        _ = await Messaging.messaging().token()
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
