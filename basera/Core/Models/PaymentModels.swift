import Foundation

struct PaymentRecord: Identifiable, Equatable {
    enum Method: String, CaseIterable, Equatable {
        case eSewa
        case fonepay
        case cash

        var title: String {
            switch self {
            case .eSewa: "eSewa"
            case .fonepay: "Fonepay"
            case .cash: "Cash"
            }
        }
    }

    enum State: String, Equatable {
        case initiated
        case pendingVerification
        case completed
        case failed

        var title: String {
            switch self {
            case .initiated: "Initiated"
            case .pendingVerification: "Pending verification"
            case .completed: "Completed"
            case .failed: "Failed"
            }
        }
    }

    enum Kind: String, Equatable {
        case invoice
        case advance
        case depositRefund

        var title: String {
            switch self {
            case .invoice: "Invoice"
            case .advance: "Advance"
            case .depositRefund: "Deposit refund"
            }
        }
    }

    let id: String
    let tenancyID: String
    let invoiceID: String?
    let payerUserID: String
    let receiverUserID: String
    let method: Method
    var state: State
    let kind: Kind
    var amount: Decimal
    var offlineMarkedByOwner: Bool
    var note: String
    let createdAt: Date
    var updatedAt: Date
}

struct PaymentReceipt: Identifiable, Equatable {
    let id: String
    let paymentID: String
    let tenancyID: String
    let invoiceID: String?
    let amount: Decimal
    let method: PaymentRecord.Method
    let issuedToUserID: String
    let issuedByUserID: String
    let issuedAt: Date
    let lineItems: [String]
}

struct SecurityDepositLedger: Equatable {
    struct Deduction: Identifiable, Equatable {
        let id: String
        let title: String
        let amount: Decimal
        let note: String
    }

    let tenancyID: String
    var totalDeposit: Decimal
    var heldAmount: Decimal
    var deductions: [Deduction]
    var plannedRefundAmount: Decimal
    var refundPaidAmount: Decimal

    var remainingRefundAmount: Decimal {
        max(plannedRefundAmount - refundPaidAmount, 0)
    }
}

struct PaymentGatewayIntent: Equatable {
    let paymentID: String
    let method: PaymentRecord.Method
    let gatewayDisplayMessage: String
    let deeplinkPlaceholder: URL?
}
