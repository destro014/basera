import Foundation

protocol AgreementPDFServiceProtocol: Sendable {
    func generatePDF(for agreement: AgreementRecord) async throws -> URL
    func downloadPDF(agreementID: String) async throws -> URL
}
