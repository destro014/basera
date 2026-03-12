import Foundation

protocol PaymentsRepositoryProtocol: Sendable {
    func fetchPaymentMethods(tenancyID: String, userID: String) async throws -> [PaymentRecord.Method]
    func fetchPayments(tenancyID: String, userID: String) async throws -> [PaymentRecord]
    func fetchReceipts(tenancyID: String, userID: String) async throws -> [PaymentReceipt]
    func fetchDepositLedger(tenancyID: String, userID: String) async throws -> SecurityDepositLedger
    func makeGatewayPayment(
        tenancyID: String,
        invoiceID: String,
        payerUserID: String,
        method: PaymentRecord.Method,
        amount: Decimal,
        note: String
    ) async throws -> PaymentGatewayIntent
    func completeGatewayPayment(paymentID: String, userID: String) async throws -> PaymentRecord
    func markCashPayment(
        tenancyID: String,
        invoiceID: String,
        ownerID: String,
        amount: Decimal,
        note: String,
        happenedOffline: Bool
    ) async throws -> PaymentRecord
    func createAdvancePayment(tenancyID: String, payerUserID: String, method: PaymentRecord.Method, amount: Decimal, note: String) async throws -> PaymentRecord
    func recordDepositDeductionsAndRefund(
        tenancyID: String,
        ownerID: String,
        deductions: [SecurityDepositLedger.Deduction],
        refundAmount: Decimal,
        note: String
    ) async throws -> SecurityDepositLedger
}

enum PaymentsRepositoryError: LocalizedError {
    case tenancyNotFound
    case invoiceNotFound
    case forbidden
    case invalidAmount
    case invalidMethod
    case paymentNotFound
    case invalidPaymentState

    var errorDescription: String? {
        switch self {
        case .tenancyNotFound: "Tenancy not found."
        case .invoiceNotFound: "Invoice not found."
        case .forbidden: "You are not allowed to perform this action."
        case .invalidAmount: "Payment amount must be greater than zero and valid for the selected flow."
        case .invalidMethod: "Selected payment method is not available for this action."
        case .paymentNotFound: "Payment not found."
        case .invalidPaymentState: "Payment state transition is invalid."
        }
    }
}
