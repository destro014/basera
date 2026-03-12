import Foundation

protocol TenancyRepositoryProtocol: Sendable {
    func fetchActiveTenancy(for renterID: String) async throws -> TenancyRecord?
    func fetchActiveTenancies(ownerID: String) async throws -> [TenancyRecord]
    func fetchTenancy(id: String, userID: String) async throws -> TenancyRecord?
    func fetchArchivedTenancies(for userID: String, party: AgreementRecord.Party) async throws -> [TenancyRecord]
    func updateMoveInChecklist(tenancyID: String, userID: String, items: [TenancyRecord.MoveInChecklistItem]) async throws -> TenancyRecord
}
