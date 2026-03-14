import Foundation

actor MockTenancyRepository: TenancyRepositoryProtocol {
    private var tenancies: [TenancyRecord]
    private let signedAgreementIDs: Set<String>

    init(
        seed: [TenancyRecord] = PreviewData.mockTenancies,
        signedAgreementIDs: Set<String> = Set(PreviewData.mockAgreements.filter { $0.status == .fullySigned }.map(\.id))
    ) {
        self.tenancies = seed
        self.signedAgreementIDs = signedAgreementIDs
    }

    func fetchActiveTenancy(for renterID: String) async throws -> TenancyRecord? {
        tenancies.first { tenancy in
            tenancy.renterID == renterID &&
            signedAgreementIDs.contains(tenancy.agreementID) &&
            TenancyRecord.Status.activeLifecycleStatuses.contains(tenancy.status)
        }
    }

    func fetchActiveTenancies(ownerID: String) async throws -> [TenancyRecord] {
        tenancies
            .filter {
                $0.ownerID == ownerID &&
                signedAgreementIDs.contains($0.agreementID) &&
                TenancyRecord.Status.activeLifecycleStatuses.contains($0.status)
            }
            .sorted { $0.startDate > $1.startDate }
    }

    func fetchTenancy(id: String, userID: String) async throws -> TenancyRecord? {
        tenancies.first { $0.id == id && ($0.ownerID == userID || $0.renterID == userID) }
    }

    func fetchArchivedTenancies(for userID: String, party: AgreementRecord.Party) async throws -> [TenancyRecord] {
        switch party {
        case .owner:
            tenancies.filter { $0.ownerID == userID && $0.status == .archived }
        case .renter:
            tenancies.filter { $0.renterID == userID && $0.status == .archived }
        }
    }

    func updateMoveInChecklist(tenancyID: String, userID: String, items: [TenancyRecord.MoveInChecklistItem]) async throws -> TenancyRecord {
        guard let index = tenancies.firstIndex(where: { $0.id == tenancyID && ($0.ownerID == userID || $0.renterID == userID) }) else {
            throw AgreementRepositoryError.notFound
        }
        tenancies[index].moveInChecklist = items
        if tenancies[index].status == .moveInPending && items.allSatisfy(\.isCompleted) {
            tenancies[index].status = .active
        }
        return tenancies[index]
    }

    func submitMoveOutRequest(
        tenancyID: String,
        renterID: String,
        requestedDate: Date,
        reason: String,
        conditionNotes: String,
        photoPlaceholders: [String]
    ) async throws -> TenancyRecord {
        guard let index = tenancies.firstIndex(where: { $0.id == tenancyID }) else { throw AgreementRepositoryError.notFound }
        guard tenancies[index].renterID == renterID else { throw AgreementRepositoryError.forbidden }
        guard tenancies[index].status == .active else { throw AgreementRepositoryError.locked }

        tenancies[index].moveOutRequest = .init(
            requestedByRenterAt: .now,
            requestedMoveOutDate: requestedDate,
            reason: reason,
            conditionNotes: conditionNotes,
            photoPlaceholders: photoPlaceholders,
            ownerDecision: .pending
        )
        tenancies[index].closureState = .requestedByRenter(requestedAt: .now)
        tenancies[index].status = .moveOutRequested
        return tenancies[index]
    }

    func decideMoveOutRequest(tenancyID: String, ownerID: String, approve: Bool, note: String) async throws -> TenancyRecord {
        guard let index = tenancies.firstIndex(where: { $0.id == tenancyID }) else { throw AgreementRepositoryError.notFound }
        guard tenancies[index].ownerID == ownerID else { throw AgreementRepositoryError.forbidden }
        guard var request = tenancies[index].moveOutRequest else { throw AgreementRepositoryError.notFound }

        if approve {
            request.ownerDecision = .approved(approvedAt: .now, note: note)
            tenancies[index].closureState = .ownerApproved(approvedAt: .now)
            tenancies[index].status = .moveOutUnderReview
            if tenancies[index].moveOutChecklist.isEmpty {
                tenancies[index].moveOutChecklist = [
                    .init(id: "MOC-1", title: "Collect keys", isCompleted: false, notes: "", photoPlaceholders: ["Key handover photo"]),
                    .init(id: "MOC-2", title: "Inspect walls, floors, and fixtures", isCompleted: false, notes: "", photoPlaceholders: ["Living room photo", "Kitchen photo"]),
                    .init(id: "MOC-3", title: "Verify appliance condition", isCompleted: false, notes: "", photoPlaceholders: ["Appliance photo"])
                ]
            }
        } else {
            request.ownerDecision = .declined(declinedAt: .now, reason: note)
            tenancies[index].closureState = .none
            tenancies[index].status = .active
        }

        tenancies[index].moveOutRequest = request
        return tenancies[index]
    }

    func updateMoveOutChecklist(
        tenancyID: String,
        userID: String,
        items: [TenancyRecord.MoveOutChecklistItem],
        finalMeterReading: TenancyRecord.FinalMeterReading
    ) async throws -> TenancyRecord {
        guard let index = tenancies.firstIndex(where: { $0.id == tenancyID }) else { throw AgreementRepositoryError.notFound }
        guard tenancies[index].ownerID == userID || tenancies[index].renterID == userID else { throw AgreementRepositoryError.forbidden }
        guard case .approved = tenancies[index].moveOutRequest?.ownerDecision else { throw AgreementRepositoryError.locked }

        tenancies[index].moveOutChecklist = items
        tenancies[index].finalMeterReading = finalMeterReading
        tenancies[index].closureState = .checklistInProgress
        tenancies[index].status = .closureInProgress
        return tenancies[index]
    }

    func submitDepositSettlement(
        tenancyID: String,
        ownerID: String,
        settlement: TenancyRecord.DepositSettlement
    ) async throws -> TenancyRecord {
        guard let index = tenancies.firstIndex(where: { $0.id == tenancyID }) else { throw AgreementRepositoryError.notFound }
        guard tenancies[index].ownerID == ownerID else { throw AgreementRepositoryError.forbidden }
        guard tenancies[index].moveOutChecklist.allSatisfy(\.isCompleted), tenancies[index].moveOutChecklist.isEmpty == false else {
            throw AgreementRepositoryError.locked
        }

        tenancies[index].depositSettlement = settlement
        tenancies[index].depositSummary.plannedRefundAmount = settlement.refundAmount
        tenancies[index].depositSummary.heldAmount = settlement.refundAmount
        tenancies[index].depositSummary.deductionNotes = settlement.summaryNote
        tenancies[index].closureState = .refundPending
        tenancies[index].status = .closureInProgress
        return tenancies[index]
    }

    func closeTenancy(tenancyID: String, ownerID: String) async throws -> TenancyRecord {
        guard let index = tenancies.firstIndex(where: { $0.id == tenancyID }) else { throw AgreementRepositoryError.notFound }
        guard tenancies[index].ownerID == ownerID else { throw AgreementRepositoryError.forbidden }
        guard tenancies[index].canOwnerCloseTenancy else { throw AgreementRepositoryError.locked }

        tenancies[index].status = .archived
        tenancies[index].closureState = .closed(closedAt: .now)
        tenancies[index].historicalAccess = .init(agreementAvailable: true, invoicesAvailable: true, paymentsAvailable: true)
        tenancies[index].listingReactivation = .init(isReady: true, pendingItems: [])
        return tenancies[index]
    }
}

private extension TenancyRecord.Status {
    static let activeLifecycleStatuses: Set<TenancyRecord.Status> = [
        .active,
        .moveInPending,
        .moveOutRequested,
        .moveOutUnderReview,
        .closureInProgress
    ]
}
