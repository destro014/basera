import Foundation

struct InvoiceRecord: Identifiable, Equatable {
    enum Status: String, Equatable {
        case draft
        case pendingOwnerApproval
        case rejectedByOwner
        case pendingPayment
        case partiallyPaid
        case paid

        var title: String {
            switch self {
            case .draft: "Draft"
            case .pendingOwnerApproval: "Pending owner approval"
            case .rejectedByOwner: "Rejected"
            case .pendingPayment: "Pending payment"
            case .partiallyPaid: "Partially paid"
            case .paid: "Paid"
            }
        }
    }

    enum CreatedByRole: String, Equatable {
        case owner
        case renter
    }

    struct Header: Equatable {
        let tenancyID: String
        let listingTitle: String
        let billingMonth: Date
        let issueDate: Date
        let dueDate: Date
        let ownerID: String
        let renterID: String
    }

    struct Item: Identifiable, Equatable {
        enum Category: String, Equatable, CaseIterable {
            case rent
            case electricity
            case water
            case garbage
            case internet
            case parking
            case other
            case credit
            case deduction

            var title: String {
                switch self {
                case .rent: "Rent"
                case .electricity: "Electricity"
                case .water: "Water"
                case .garbage: "Garbage"
                case .internet: "Internet"
                case .parking: "Parking"
                case .other: "Other"
                case .credit: "Credit"
                case .deduction: "Deduction"
                }
            }

            var isDeduction: Bool {
                self == .credit || self == .deduction
            }
        }

        let id: String
        let category: Category
        let title: String
        let detail: String?
        let amount: Decimal
    }

    let id: String
    var header: Header
    var createdByRole: CreatedByRole
    var status: Status
    var items: [Item]
    var carryForwardBalance: Decimal
    var paidAmount: Decimal
    var note: String
    var rejectionReason: String?
    var createdAt: Date
    var updatedAt: Date

    var subtotal: Decimal {
        items.reduce(into: Decimal.zero) { partial, item in
            if item.category.isDeduction {
                partial -= item.amount
            } else {
                partial += item.amount
            }
        }
    }

    var totalAmount: Decimal {
        subtotal + carryForwardBalance
    }

    var amountRemaining: Decimal {
        max(totalAmount - paidAmount, 0)
    }
}

struct BillingTenancySettings: Equatable {
    var allowsRenterGeneratedBillDraft: Bool
    var allowsPartialPayment: Bool
    var allowsAdvancePayment: Bool
}

struct InvoiceDraftInput: Equatable {
    enum ElectricityMode: Equatable {
        case flatFee(amount: Decimal)
        case consumedUnits(units: Decimal, ratePerUnit: Decimal)
        case meterBased(previousReading: Decimal, currentReading: Decimal, ratePerUnit: Decimal)

        var computedAmount: Decimal {
            switch self {
            case .flatFee(let amount):
                amount
            case .consumedUnits(let units, let ratePerUnit):
                units * ratePerUnit
            case .meterBased(let previousReading, let currentReading, let ratePerUnit):
                max(currentReading - previousReading, 0) * ratePerUnit
            }
        }

        var detailText: String {
            switch self {
            case .flatFee:
                "Flat fee"
            case .consumedUnits(let units, let ratePerUnit):
                "\(NSDecimalNumber(decimal: units).stringValue) units × Rs. \(NSDecimalNumber(decimal: ratePerUnit).stringValue)"
            case .meterBased(let previous, let current, let ratePerUnit):
                "Meter \(NSDecimalNumber(decimal: previous).stringValue) → \(NSDecimalNumber(decimal: current).stringValue) × Rs. \(NSDecimalNumber(decimal: ratePerUnit).stringValue)"
            }
        }
    }

    struct UtilityCharge: Identifiable, Equatable {
        enum Mode: Equatable {
            case flat(amount: Decimal)
            case variable(quantity: Decimal, rate: Decimal)

            var computedAmount: Decimal {
                switch self {
                case .flat(let amount):
                    amount
                case .variable(let quantity, let rate):
                    quantity * rate
                }
            }

            var detailText: String {
                switch self {
                case .flat:
                    "Flat"
                case .variable(let quantity, let rate):
                    "\(NSDecimalNumber(decimal: quantity).stringValue) × Rs. \(NSDecimalNumber(decimal: rate).stringValue)"
                }
            }
        }

        let id: String
        let category: InvoiceRecord.Item.Category
        var mode: Mode
    }

    struct AmountNote: Identifiable, Equatable {
        let id: String
        var title: String
        var amount: Decimal
    }

    let tenancyID: String
    let ownerID: String
    let renterID: String
    let listingTitle: String
    let billingMonth: Date
    let dueDate: Date
    let createdByRole: InvoiceRecord.CreatedByRole
    let rentAmount: Decimal
    let electricityMode: ElectricityMode?
    let utilityCharges: [UtilityCharge]
    let otherCharges: [AmountNote]
    let deductions: [AmountNote]
    let credits: [AmountNote]
    let note: String
}
