import Foundation

struct TenancyRecord: Identifiable, Equatable {
    enum Status: String, Equatable {
        case moveInPending
        case active
        case moveOutRequested
        case archived

        var title: String {
            switch self {
            case .moveInPending: "Move-in pending"
            case .active: "Active"
            case .moveOutRequested: "Move-out requested"
            case .archived: "Archived"
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
        let heldAmount: Decimal
        let plannedRefundAmount: Decimal?
        let deductionNotes: String?
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
    var billSummary: BillSummary
    var depositSummary: DepositSummary
    var moveInChecklist: [MoveInChecklistItem]
    let ownerContact: Contact
    let renterContact: Contact

    func address(for party: AgreementRecord.Party) -> String {
        if party == .owner || exactAddressVisibleToRenter {
            return exactAddress
        }
        return "Exact address shared after owner approval"
    }
}
