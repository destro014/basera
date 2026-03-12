import Foundation

protocol TenancyRepositoryProtocol: Sendable {
    func fetchActiveTenancy(for renterID: String) async throws -> TenancyRecord?
    func fetchActiveTenancies(ownerID: String) async throws -> [TenancyRecord]
    func fetchTenancy(id: String, userID: String) async throws -> TenancyRecord?
    func fetchArchivedTenancies(for userID: String, party: AgreementRecord.Party) async throws -> [TenancyRecord]
    func updateMoveInChecklist(tenancyID: String, userID: String, items: [TenancyRecord.MoveInChecklistItem]) async throws -> TenancyRecord
    func submitMoveOutRequest(
        tenancyID: String,
        renterID: String,
        requestedDate: Date,
        reason: String,
        conditionNotes: String,
        photoPlaceholders: [String]
    ) async throws -> TenancyRecord
    func decideMoveOutRequest(tenancyID: String, ownerID: String, approve: Bool, note: String) async throws -> TenancyRecord
    func updateMoveOutChecklist(
        tenancyID: String,
        userID: String,
        items: [TenancyRecord.MoveOutChecklistItem],
        finalMeterReading: TenancyRecord.FinalMeterReading
    ) async throws -> TenancyRecord
    func submitDepositSettlement(
        tenancyID: String,
        ownerID: String,
        settlement: TenancyRecord.DepositSettlement
    ) async throws -> TenancyRecord
    func closeTenancy(tenancyID: String, ownerID: String) async throws -> TenancyRecord
}
