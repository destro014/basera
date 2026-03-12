import Foundation

protocol AgreementsRepositoryProtocol: Sendable {
    func fetchAgreements(for userID: String, as party: AgreementRecord.Party) async throws -> [AgreementRecord]
    func fetchAgreement(id: String, userID: String) async throws -> AgreementRecord?
    func createAgreementDraft(_ draft: AgreementDraftInput) async throws -> AgreementRecord
    func updateAgreementTerms(agreementID: String, editorID: String, terms: AgreementRecord.Terms) async throws -> AgreementRecord
    func submitForSignature(agreementID: String, ownerID: String) async throws -> AgreementRecord
    func confirmTypedName(agreementID: String, userID: String, typedName: String) async throws -> AgreementRecord.Party
    func requestAgreementOTP(agreementID: String, userID: String, party: AgreementRecord.Party) async throws -> AgreementOTPChallenge
    func verifyAgreementOTP(agreementID: String, userID: String, challengeID: String, code: String) async throws -> AgreementRecord
    func createRenewalDraft(from agreementID: String, ownerID: String) async throws -> AgreementRecord
}

struct AgreementDraftInput: Equatable, Sendable {
    let tenancyID: String
    let listingID: String
    let owner: AgreementRecord.Participant
    let renter: AgreementRecord.Participant
    let property: AgreementRecord.PropertySummary
    let terms: AgreementRecord.Terms
}
