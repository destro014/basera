import Foundation

protocol BillingRepositoryProtocol: Sendable {
    func fetchSettings(tenancyID: String, userID: String) async throws -> BillingTenancySettings?
    func updateSettings(tenancyID: String, ownerID: String, settings: BillingTenancySettings) async throws -> BillingTenancySettings
    func fetchInvoices(tenancyID: String, userID: String) async throws -> [InvoiceRecord]
    func fetchInvoice(id: String, userID: String) async throws -> InvoiceRecord?
    func previewInvoice(from draft: InvoiceDraftInput, userID: String) async throws -> InvoiceRecord
    func createInvoice(from draft: InvoiceDraftInput, userID: String) async throws -> InvoiceRecord
    func approveInvoice(invoiceID: String, ownerID: String) async throws -> InvoiceRecord
    func rejectInvoice(invoiceID: String, ownerID: String, reason: String) async throws -> InvoiceRecord
}

enum BillingRepositoryError: LocalizedError {
    case tenancyNotFound
    case forbidden
    case renterDraftDisabled
    case invalidMonth
    case alreadyExistsForMonth
    case invoiceNotFound
    case invalidTransition

    var errorDescription: String? {
        switch self {
        case .tenancyNotFound: "Tenancy not found."
        case .forbidden: "You are not allowed to do this action."
        case .renterDraftDisabled: "Renter-generated bill drafts are disabled by owner."
        case .invalidMonth: "Billing is monthly only."
        case .alreadyExistsForMonth: "An invoice already exists for this tenancy and month."
        case .invoiceNotFound: "Invoice not found."
        case .invalidTransition: "Invoice status transition is invalid."
        }
    }
}
