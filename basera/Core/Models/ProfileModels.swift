import Foundation

enum SmokingStatus: String, CaseIterable, Codable, Identifiable {
    case nonSmoker
    case occasional
    case smoker

    var id: String { rawValue }

    var title: String {
        switch self {
        case .nonSmoker: "Non-smoker"
        case .occasional: "Occasional"
        case .smoker: "Smoker"
        }
    }
}

struct RenterProfile: Equatable, Codable {
    var fullName: String
    var phoneNumber: String
    var email: String
    var profilePhotoURL: URL?
    var occupation: String
    var familySize: Int
    var hasPets: Bool
    var smokingStatus: SmokingStatus

    static let empty = RenterProfile(
        fullName: "",
        phoneNumber: "",
        email: "",
        profilePhotoURL: nil,
        occupation: "",
        familySize: 1,
        hasPets: false,
        smokingStatus: .nonSmoker
    )
}

enum VerificationDocumentSide: String, Codable {
    case front
    case back
}

struct DocumentUploadState: Equatable, Codable {
    var frontUploaded: Bool
    var backUploaded: Bool

    static let empty = DocumentUploadState(frontUploaded: false, backUploaded: false)

    var isComplete: Bool {
        frontUploaded && backUploaded
    }
}

struct OwnerPaymentDetails: Equatable, Codable {
    var bankName: String
    var accountName: String
    var accountNumber: String
    var esewaID: String
    var fonepayNumber: String

    static let empty = OwnerPaymentDetails(
        bankName: "",
        accountName: "",
        accountNumber: "",
        esewaID: "",
        fonepayNumber: ""
    )

    var isComplete: Bool {
        bankName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
        accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
        accountNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}

struct OwnerProfile: Equatable, Codable {
    var fullName: String
    var phoneNumber: String
    var email: String
    var profilePhotoURL: URL?
    var address: String
    var idDocumentState: DocumentUploadState
    var paymentDetails: OwnerPaymentDetails

    static let empty = OwnerProfile(
        fullName: "",
        phoneNumber: "",
        email: "",
        profilePhotoURL: nil,
        address: "",
        idDocumentState: .empty,
        paymentDetails: .empty
    )
}

struct ProfileCompletionStatus: Equatable {
    let role: UserRole
    let requiredFields: Int
    let completedFields: Int
    let missingFields: [String]

    var isComplete: Bool { requiredFields == completedFields }

    var progressValue: Double {
        guard requiredFields > 0 else { return 0 }
        return Double(completedFields) / Double(requiredFields)
    }

    var summaryText: String {
        "\(completedFields)/\(requiredFields) required fields"
    }
}

struct UserProfileBundle: Equatable {
    var renterProfile: RenterProfile?
    var ownerProfile: OwnerProfile?

    func completionStatus(for role: UserRole) -> ProfileCompletionStatus {
        switch role {
        case .renter:
            let profile = renterProfile ?? .empty
            var completed = 0
            var missing: [String] = []

            let checks: [(Bool, String)] = [
                (!profile.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Full name"),
                (!profile.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Phone"),
                (!profile.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Email"),
                (!profile.occupation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Occupation")
            ]

            for check in checks {
                if check.0 { completed += 1 } else { missing.append(check.1) }
            }

            if profile.familySize > 0 { completed += 1 } else { missing.append("Family size") }
            completed += 1 // pets is always answered by boolean
            completed += 1 // smoking status always has a value

            return ProfileCompletionStatus(role: .renter, requiredFields: 7, completedFields: completed, missingFields: missing)

        case .owner:
            let profile = ownerProfile ?? .empty
            var completed = 0
            var missing: [String] = []

            let checks: [(Bool, String)] = [
                (!profile.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Full name"),
                (!profile.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Phone"),
                (!profile.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Email"),
                (!profile.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Address")
            ]

            for check in checks {
                if check.0 { completed += 1 } else { missing.append(check.1) }
            }

            if profile.idDocumentState.isComplete {
                completed += 1
            } else {
                missing.append("National ID upload")
            }

            if profile.paymentDetails.isComplete {
                completed += 1
            } else {
                missing.append("Bank/payment details")
            }

            return ProfileCompletionStatus(role: .owner, requiredFields: 6, completedFields: completed, missingFields: missing)
        }
    }
}
