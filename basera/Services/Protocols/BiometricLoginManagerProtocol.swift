import Foundation

protocol BiometricLoginManagerProtocol {
    var biometryDisplayName: String { get }
    var biometrySystemImageName: String { get }
    var isBiometryAvailable: Bool { get }
    var isBiometricLoginEnabled: Bool { get }
    var enrolledBiometricEmail: String? { get }
    var canAttemptBiometricLogin: Bool { get }

    func hasPromptedForEnrollment(for email: String) -> Bool
    func markEnrollmentPromptShown(for email: String)
    func authenticateForEnrollment() async throws
    func enableBiometricLogin(with credentials: AuthCredentials) throws
    func disableBiometricLogin()
    func authenticateForLogin() async throws -> AuthCredentials
}
