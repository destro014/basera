import Foundation

struct TenancyRecord: Identifiable, Equatable {
    enum Status: String, Equatable {
        case moveInPending
        case active
        case moveOutRequested
        case moveOutUnderReview
        case closureInProgress
        case archived

        var title: String {
            switch self {
            case .moveInPending: "Move-in pending"
            case .active: "Active"
            case .moveOutRequested: "Move-out requested"
            case .moveOutUnderReview: "Move-out under review"
            case .closureInProgress: "Closure in progress"
            case .archived: "Archived"
            }
        }
    }

    enum ClosureState: Equatable {
        case none
        case requestedByRenter(requestedAt: Date)
        case ownerApproved(approvedAt: Date)
        case checklistInProgress
        case refundPending
        case closed(closedAt: Date)

        var title: String {
            switch self {
            case .none: "No move-out in progress"
            case .requestedByRenter: "Move-out requested"
            case .ownerApproved: "Move-out approved"
            case .checklistInProgress: "Checklist in progress"
            case .refundPending: "Deposit settlement pending"
            case .closed: "Tenancy closed"
            }
        }
    }

    struct BillSummary: Equatable {
        let currentInvoiceID: String
        let dueDate: Date
        let amountDue: Decimal
        let carryForward: Decimal
        let allowsPartialPayment: Bool
        let allowsAdvancePayment: Bool
    }

    struct DepositSummary: Equatable {
        let totalDeposit: Decimal
        var heldAmount: Decimal
        var plannedRefundAmount: Decimal?
        var deductionNotes: String?
    }

    struct MoveInChecklistItem: Identifiable, Equatable {
        enum Category: String, Equatable {
            case roomCondition
            case furniture
            case appliance
            case meterReading
            case safety

            var title: String {
                switch self {
                case .roomCondition: "Room condition"
                case .furniture: "Furniture"
                case .appliance: "Appliance"
                case .meterReading: "Meter reading"
                case .safety: "Safety"
                }
            }
        }

        let id: String
        let title: String
        let category: Category
        var isCompleted: Bool
        var note: String
        var photoPlaceholders: [String]
    }

    struct Contact: Equatable {
        let fullName: String
        let phoneNumber: String
    }

    struct MoveOutRequest: Equatable {
        var requestedByRenterAt: Date
        var requestedMoveOutDate: Date
        var reason: String
        var conditionNotes: String
        var photoPlaceholders: [String]
        var ownerDecision: OwnerDecision

        enum OwnerDecision: Equatable {
            case pending
            case approved(approvedAt: Date, note: String)
            case declined(declinedAt: Date, reason: String)
        }
    }

    struct MoveOutChecklistItem: Identifiable, Equatable {
        let id: String
        let title: String
        var isCompleted: Bool
        var notes: String
        var photoPlaceholders: [String]
    }

    struct FinalMeterReading: Equatable {
        var electricity: String
        var water: String
        var internet: String
        var capturedAt: Date?
    }

    struct DepositSettlement: Equatable {
        enum RefundType: String, CaseIterable, Equatable, Identifiable {
            case full
            case partial

            var id: String { rawValue }

            var title: String {
                switch self {
                case .full: "Full refund"
                case .partial: "Partial refund"
                }
            }
        }

        struct Deduction: Identifiable, Equatable {
            let id: String
            var title: String
            var amount: Decimal
            var note: String
        }

        var refundType: RefundType
        var deductions: [Deduction]
        var refundAmount: Decimal
        var summaryNote: String
    }

    struct ArchivedHistoryAccess: Equatable {
        var agreementAvailable: Bool
        var invoicesAvailable: Bool
        var paymentsAvailable: Bool
    }

    struct ListingReactivationReadiness: Equatable {
        var isReady: Bool
        var pendingItems: [String]
    }

    let id: String
    let listingID: String
    let agreementID: String
    let ownerID: String
    let renterID: String
    let listingTitle: String
    let approximateLocation: String
    let exactAddress: String
    let exactAddressVisibleToRenter: Bool
    let monthlyRent: Decimal
    let startDate: Date
    let endDate: Date
    var status: Status
    var closureState: ClosureState
    var billSummary: BillSummary
    var depositSummary: DepositSummary
    var moveInChecklist: [MoveInChecklistItem]
    var moveOutRequest: MoveOutRequest?
    var moveOutChecklist: [MoveOutChecklistItem]
    var finalMeterReading: FinalMeterReading?
    var depositSettlement: DepositSettlement?
    var historicalAccess: ArchivedHistoryAccess
    var listingReactivation: ListingReactivationReadiness
    let ownerContact: Contact
    let renterContact: Contact

    var canOwnerCloseTenancy: Bool {
        guard case .approved = moveOutRequest?.ownerDecision else { return false }
        let checklistCompleted = moveOutChecklist.isEmpty == false && moveOutChecklist.allSatisfy(\.isCompleted)
        return checklistCompleted && finalMeterReading != nil && depositSettlement != nil
    }

    func address(for party: AgreementRecord.Party) -> String {
        if party == .owner || exactAddressVisibleToRenter {
            return exactAddress
        }
        return "Exact address shared after owner approval"
    }
}
