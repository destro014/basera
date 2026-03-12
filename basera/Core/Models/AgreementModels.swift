import Foundation

struct AgreementRecord: Identifiable, Equatable {
    enum Status: String, CaseIterable, Equatable {
        case draft
        case pendingOwnerSignature
        case pendingRenterSignature
        case fullySigned
        case renewalOffered
        case expired

        var title: String {
            switch self {
            case .draft: "Draft"
            case .pendingOwnerSignature: "Pending owner signature"
            case .pendingRenterSignature: "Pending renter signature"
            case .fullySigned: "Signed"
            case .renewalOffered: "Renewal offered"
            case .expired: "Expired"
            }
        }
    }

    enum Party: String, CaseIterable, Identifiable {
        case owner
        case renter

        var id: String { rawValue }
        var title: String { rawValue.capitalized }
    }

    struct Participant: Equatable {
        let userID: String
        let fullName: String
        let phoneNumber: String
        let email: String
    }

    struct PropertySummary: Equatable {
        let listingID: String
        let listingTitle: String
        let approximateLocation: String
        let exactAddress: String
        let exactAddressVisibleToRenter: Bool
    }

    struct Terms: Equatable {
        var monthlyRent: Decimal
        var securityDeposit: Decimal
        var utilityTerms: String
        var rulesAndRegulations: String
        var startDate: Date
        var endDate: Date
        var noticePeriodDays: Int
        var lateFeeText: String
        var repairResponsibility: String
        var guestRules: String
        var petRules: String

        static let placeholder = Terms(
            monthlyRent: 0,
            securityDeposit: 0,
            utilityTerms: "",
            rulesAndRegulations: "",
            startDate: .now,
            endDate: Calendar.current.date(byAdding: .month, value: 11, to: .now) ?? .now,
            noticePeriodDays: 30,
            lateFeeText: "",
            repairResponsibility: "",
            guestRules: "",
            petRules: ""
        )
    }

    struct Signature: Equatable {
        let typedName: String
        let signedAt: Date
    }

    struct SignatureRequirement: Equatable {
        var owner: Signature?
        var renter: Signature?

        var isFullySigned: Bool {
            owner != nil && renter != nil
        }
    }

    struct StatusEvent: Identifiable, Equatable {
        let id: String
        let title: String
        let happenedAt: Date
        let detail: String
    }

    let id: String
    let tenancyID: String
    let previousAgreementID: String?
    let version: Int
    let owner: Participant
    let renter: Participant
    let property: PropertySummary
    var terms: Terms
    var status: Status
    var signatures: SignatureRequirement
    var statusHistory: [StatusEvent]
    let createdAt: Date
    var updatedAt: Date

    var isLocked: Bool {
        status == .fullySigned || status == .expired
    }

    func previewAddress(for party: Party) -> String {
        if party == .owner || property.exactAddressVisibleToRenter {
            return property.exactAddress
        }
        return "Exact address visible after owner approval"
    }
}

struct AgreementOTPChallenge: Equatable {
    let challengeID: String
    let agreementID: String
    let party: AgreementRecord.Party
    let expiresAt: Date
}
