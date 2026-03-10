import Foundation

enum AuthFlowStep: Int, CaseIterable, Identifiable {
    case introduction
    case phoneNumber
    case otpVerification
    case roleSelection
    case consent
    case profilePhoto

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .introduction:
            "Welcome to Basera"
        case .phoneNumber:
            "Sign in with your phone"
        case .otpVerification:
            "Verify your OTP"
        case .roleSelection:
            "Choose your role"
        case .consent:
            "Review terms and privacy"
        case .profilePhoto:
            "Add a profile photo"
        }
    }

    var subtitle: String {
        switch self {
        case .introduction:
            "Manage the rental journey in one place, from discovery and approvals to agreements, monthly invoices, and move-out records."
        case .phoneNumber:
            "Use the mobile number you want attached to listings, agreements, and monthly billing."
        case .otpVerification:
            "Enter the 6-digit code we sent to keep your Basera account secure."
        case .roleSelection:
            "Pick how you want to use Basera today. If you choose both, you can switch roles later."
        case .consent:
            "Basera needs your consent before unlocking chats, agreements, and billing history."
        case .profilePhoto:
            "Adding a photo is optional, but it helps renters and owners recognise each other faster."
        }
    }

    var shortLabel: String {
        switch self {
        case .introduction:
            "Intro"
        case .phoneNumber:
            "Phone"
        case .otpVerification:
            "OTP"
        case .roleSelection:
            "Role"
        case .consent:
            "Consent"
        case .profilePhoto:
            "Photo"
        }
    }

    var showsProductOverview: Bool {
        self == .introduction
    }

    var countsTowardsProgress: Bool {
        self != .introduction
    }

    var progressIndex: Int? {
        guard countsTowardsProgress else { return nil }
        return Self.progressSteps.firstIndex(of: self)
    }

    static var progressSteps: [AuthFlowStep] {
        allCases.filter(\.countsTowardsProgress)
    }
}

struct AuthOTPChallenge: Equatable {
    let id: String
    let phoneNumber: String
    let maskedPhoneNumber: String
    let resendAvailableAt: Date
}

struct AuthenticatedPhoneSession: Equatable {
    let id: String
    let userID: String
    let phoneNumber: String
}

enum AuthVerificationResult: Equatable {
    case signedIn(AppUser)
    case requiresOnboarding(AuthenticatedPhoneSession)
}

struct AuthOnboardingSubmission: Equatable {
    let selectedRoles: Set<UserRole>
    let acceptsTerms: Bool
    let acceptsPrivacy: Bool
    let profilePhotoData: Data?
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
    case invalidPhoneNumber
    case otpCodeRequired
    case invalidOTP
    case resendNotReady(secondsRemaining: Int)
    case roleSelectionRequired
    case termsConsentRequired
    case privacyConsentRequired
    case onboardingSessionExpired
    case photoSelectionFailed
    case unexpected

    var errorDescription: String? {
        switch self {
        case .invalidPhoneNumber:
            "Enter a valid Nepal mobile number. Example: +977 98XXXXXXXX."
        case .otpCodeRequired:
            "Enter the 6-digit OTP before continuing."
        case .invalidOTP:
            "That OTP did not match. Check the 6-digit code and try again."
        case .resendNotReady(let secondsRemaining):
            "You can request another OTP in \(secondsRemaining) seconds."
        case .roleSelectionRequired:
            "Choose renter, owner, or both before continuing."
        case .termsConsentRequired:
            "You need to accept the Basera Terms of Service to continue."
        case .privacyConsentRequired:
            "You need to accept the Basera Privacy Policy to continue."
        case .onboardingSessionExpired:
            "Your verification session expired. Start again with your phone number."
        case .photoSelectionFailed:
            "Basera could not read that photo. Choose another image and try again."
        case .unexpected:
            "Something went wrong. Please try again."
        }
    }
}
