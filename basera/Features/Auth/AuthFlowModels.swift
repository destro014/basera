import Foundation

enum AuthFlowStep: Int, CaseIterable, Identifiable {
    case login
    case registration
    case emailVerification
    case registrationPassword
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
    let selectedRoles: Set<UserRole>
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

enum UserRoleSelectionOption: String, CaseIterable, Identifiable {
    case renter
    case owner
    case both

    var id: String { rawValue }

    var title: String {
        switch self {
        case .renter:
            "I'm renting"
        case .owner:
            "I manage properties"
        case .both:
            "I do both"
        }
    }

    var subtitle: String {
        switch self {
        case .renter:
            "Browse listings, request visits, sign agreements, and pay monthly invoices."
        case .owner:
            "Publish listings, approve renters, create agreements, and track billing."
        case .both:
            "Use one account for renter and owner work, then switch roles from Settings."
        }
    }

    var iconName: String {
        switch self {
        case .renter:
            "person.fill"
        case .owner:
            "building.2.fill"
        case .both:
            "arrow.left.arrow.right.circle.fill"
        }
    }

    var roles: Set<UserRole> {
        switch self {
        case .renter:
            [.renter]
        case .owner:
            [.owner]
        case .both:
            [.renter, .owner]
        }
    }

    static func option(for roles: Set<UserRole>) -> UserRoleSelectionOption? {
        allCases.first { $0.roles == roles }
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
        case .unexpected:
            "Something went wrong. Please try again."
        }
    }
}
