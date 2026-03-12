import Foundation

protocol AgreementConfirmationServiceProtocol: Sendable {
    func requestOTP(agreementID: String, party: AgreementRecord.Party) async throws -> AgreementOTPChallenge
    func verifyOTP(challengeID: String, code: String) async throws -> Bool
}
