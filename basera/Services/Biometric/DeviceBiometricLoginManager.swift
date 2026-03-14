import Foundation
import LocalAuthentication
import Security

final class DeviceBiometricLoginManager: BiometricLoginManagerProtocol {
    private enum Keys {
        static let enabled = "biometricLoginEnabled"
        static let promptedEmails = "biometricLoginPromptedEmails"
        static let keychainService = "com.basera.biometric-login"
        static let keychainAccount = "login-credentials"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var biometryDisplayName: String {
        switch biometryType {
        case .faceID:
            "Face ID"
        case .touchID:
            "Touch ID"
        default:
            "Biometrics"
        }
    }

    var biometrySystemImageName: String {
        switch biometryType {
        case .faceID:
            "faceid"
        case .touchID:
            "touchid"
        default:
            "lock.shield"
        }
    }

    var isBiometryAvailable: Bool {
        canEvaluateBiometrics
    }

    var isBiometricLoginEnabled: Bool {
        defaults.bool(forKey: Keys.enabled)
    }

    var enrolledBiometricEmail: String? {
        guard isBiometricLoginEnabled else { return nil }
        guard let credentials = loadCredentialsFromKeychain() else { return nil }
        return normalized(email: credentials.email)
    }

    var canAttemptBiometricLogin: Bool {
        guard isBiometryAvailable, isBiometricLoginEnabled, let credentials = loadCredentialsFromKeychain() else {
            return false
        }

        return credentials.email.isEmpty == false && credentials.password.isEmpty == false
    }

    func hasPromptedForEnrollment(for email: String) -> Bool {
        promptedEnrollmentEmails.contains(normalized(email: email))
    }

    func markEnrollmentPromptShown(for email: String) {
        var prompted = promptedEnrollmentEmails
        prompted.insert(normalized(email: email))
        defaults.set(Array(prompted), forKey: Keys.promptedEmails)
    }

    func authenticateForEnrollment() async throws {
        guard isBiometryAvailable else {
            throw AuthError.biometricUnavailable
        }

        let context = LAContext()
        let reason = "Confirm \(biometryDisplayName) to enable biometric login for Basera"

        let isAuthorized: Bool
        do {
            isAuthorized = try await evaluateBiometricPolicy(context: context, reason: reason)
        } catch {
            throw AuthError.biometricAuthenticationFailed
        }
        guard isAuthorized else {
            throw AuthError.biometricAuthenticationFailed
        }
    }

    func enableBiometricLogin(with credentials: AuthCredentials) throws {
        try saveCredentialsToKeychain(credentials)
        defaults.set(true, forKey: Keys.enabled)
        markEnrollmentPromptShown(for: credentials.email)
    }

    func disableBiometricLogin() {
        deleteCredentialsFromKeychain()
        defaults.set(false, forKey: Keys.enabled)
    }

    func authenticateForLogin() async throws -> AuthCredentials {
        guard isBiometryAvailable else {
            throw AuthError.biometricUnavailable
        }

        let context = LAContext()
        let reason = "Use \(biometryDisplayName) to login to Basera"

        let isAuthorized: Bool
        do {
            isAuthorized = try await evaluateBiometricPolicy(context: context, reason: reason)
        } catch {
            throw AuthError.biometricAuthenticationFailed
        }
        guard isAuthorized else {
            throw AuthError.biometricAuthenticationFailed
        }

        guard let credentials = loadCredentialsFromKeychain() else {
            throw AuthError.biometricCredentialsMissing
        }

        return credentials
    }

    private var canEvaluateBiometrics: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    private var biometryType: LABiometryType {
        let context = LAContext()
        var error: NSError?
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return context.biometryType
    }

    private func evaluateBiometricPolicy(context: LAContext, reason: String) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: success)
            }
        }
    }

    private func saveCredentialsToKeychain(_ credentials: AuthCredentials) throws {
        let data = try JSONEncoder().encode(credentials)
        let baseQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Keys.keychainService,
            kSecAttrAccount as String: Keys.keychainAccount
        ]

        var addQuery = baseQuery
        addQuery.merge([
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecValueData as String: data
        ]) { _, new in
            new
        }

        SecItemDelete(baseQuery as CFDictionary)
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw AuthError.unexpected
        }
    }

    private func loadCredentialsFromKeychain() -> AuthCredentials? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Keys.keychainService,
            kSecAttrAccount as String: Keys.keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        guard let data = item as? Data else { return nil }
        return try? JSONDecoder().decode(AuthCredentials.self, from: data)
    }

    private func deleteCredentialsFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Keys.keychainService,
            kSecAttrAccount as String: Keys.keychainAccount
        ]
        SecItemDelete(query as CFDictionary)
    }

    private var promptedEnrollmentEmails: Set<String> {
        let stored = defaults.stringArray(forKey: Keys.promptedEmails) ?? []
        return Set(stored.map { normalized(email: $0) })
    }

    private func normalized(email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
