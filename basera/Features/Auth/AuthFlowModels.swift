import Foundation

enum AuthFlowStep: Int, CaseIterable, Identifiable {
    case login
    case registration
    case emailVerification
    case registrationPassword
    case roleSelection
    case profileSetup
    case passwordRecoveryEmail
    case passwordRecoveryVerification
    case passwordRecoveryReset

    var id: Int { rawValue }
}

struct AuthEmailVerificationChallenge: Equatable {
    let id: String
    let email: String
    let maskedEmail: String
    let resendAvailableAt: Date
}

struct AuthenticatedEmailSession: Equatable {
    let id: String
    let userID: String
    let email: String
}

struct AuthPasswordRecoveryChallenge: Equatable {
    let id: String
    let email: String
    let maskedEmail: String
    let resendAvailableAt: Date
}

struct AuthPasswordResetSession: Equatable {
    let id: String
    let userID: String
    let email: String
}

enum AuthSignInResult: Equatable {
    case authenticated(AppUser)
    case requiresEmailVerification(AuthEmailVerificationChallenge)
    case requiresProfileSetup(AuthenticatedEmailSession)
}

struct AuthProfileSetupSubmission: Equatable {
    let fullName: String
    let phoneNumber: String
    let selectedRole: UserRole
    let acceptsTerms: Bool
    let acceptsPrivacy: Bool
}

struct AuthFlowCompletion {
    let user: AppUser
    let credentials: AuthCredentials?
}

struct AuthStepNotice: Equatable, Identifiable {
    enum Style: Equatable {
        case info
        case success
        case error
    }

    let style: Style
    let message: String

    var id: String {
        "\(style)-\(message)"
    }
}

enum AuthError: LocalizedError, Equatable {
    case emailRequired
    case invalidEmail
    case passwordRequired
    case passwordTooShort(minLength: Int)
    case confirmPasswordRequired
    case passwordsDoNotMatch
    case verificationCodeRequired
    case invalidVerificationCode
    case resendNotReady(secondsRemaining: Int)
    case fullNameRequired
    case phoneNumberRequired
    case invalidPassword
    case emailAlreadyInUse
    case accountNotFound
    case registrationSessionExpired
    case passwordRecoverySessionExpired
    case passwordResetSessionExpired
    case biometricUnavailable
    case biometricAuthenticationFailed
    case biometricCredentialsMissing
    case supabaseConfigurationMissing
    case unexpected

    var errorDescription: String? {
        switch self {
        case .emailRequired:
            "Enter your email address to continue."
        case .invalidEmail:
            "Enter a valid email address."
        case .passwordRequired:
            "Enter your password to continue."
        case .passwordTooShort(let minLength):
            "Password must be at least \(minLength) characters."
        case .confirmPasswordRequired:
            "Confirm your password to continue."
        case .passwordsDoNotMatch:
            "Passwords do not match."
        case .verificationCodeRequired:
            "Enter the 6-digit verification code."
        case .invalidVerificationCode:
            "That verification code did not match. Try again."
        case .resendNotReady(let secondsRemaining):
            "You can request another code in \(secondsRemaining) seconds."
        case .fullNameRequired:
            "Enter your full name to complete profile setup."
        case .phoneNumberRequired:
            "Enter your phone number to complete profile setup."
        case .invalidPassword:
            "The details you entered are not valid. Please try again."
        case .emailAlreadyInUse:
            "An account already exists. Please login to continue."
        case .accountNotFound:
            "No account was found for this request."
        case .registrationSessionExpired:
            "Your registration session expired. Start again from registration."
        case .passwordRecoverySessionExpired:
            "Your password recovery session expired. Start again."
        case .passwordResetSessionExpired:
            "Your password reset session expired. Start again."
        case .biometricUnavailable:
            "Biometric login is not available on this device."
        case .biometricAuthenticationFailed:
            "Biometric verification failed. Try again or use password login."
        case .biometricCredentialsMissing:
            "Saved credentials are missing. Login with email and password."
        case .supabaseConfigurationMissing:
            "Supabase is not configured. Set BASERA_SUPABASE_URL and BASERA_SUPABASE_ANON_KEY in your Xcode run scheme or Info.plist, then launch once to cache them on-device."
        case .unexpected:
            "Something went wrong. Please try again."
        }
    }
}
