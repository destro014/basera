import Foundation

@MainActor
final class MoveOutFlowViewModel: ObservableObject {
    @Published private(set) var tenancy: TenancyRecord
    @Published var requestDate: Date
    @Published var requestReason: String
    @Published var conditionNotes: String
    @Published var photoPlaceholderInput: String
    @Published var ownerNote: String
    @Published var checklistItems: [TenancyRecord.MoveOutChecklistItem]
    @Published var electricityReading: String
    @Published var waterReading: String
    @Published var internetReading: String
    @Published var refundType: TenancyRecord.DepositSettlement.RefundType
    @Published var deductionTitle: String
    @Published var deductionAmount: String
    @Published var deductionNote: String
    @Published var refundAmount: String
    @Published var settlementSummary: String
    @Published var errorMessage: String?

    init(tenancy: TenancyRecord) {
        self.tenancy = tenancy
        requestDate = .now
        requestReason = ""
        conditionNotes = ""
        photoPlaceholderInput = "Bedroom wall photo"
        ownerNote = ""
        checklistItems = tenancy.moveOutChecklist
        electricityReading = tenancy.finalMeterReading?.electricity ?? ""
        waterReading = tenancy.finalMeterReading?.water ?? ""
        internetReading = tenancy.finalMeterReading?.internet ?? ""
        refundType = tenancy.depositSettlement?.refundType ?? .full
        deductionTitle = "Cleaning"
        deductionAmount = ""
        deductionNote = ""
        refundAmount = tenancy.depositSettlement.map { NSDecimalNumber(decimal: $0.refundAmount).stringValue } ?? ""
        settlementSummary = tenancy.depositSettlement?.summaryNote ?? ""
    }

    func submitRenterMoveOutRequest(userID: String, repository: TenancyRepositoryProtocol) async {
        do {
            let placeholders = photoPlaceholderInput
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { $0.isEmpty == false }
            tenancy = try await repository.submitMoveOutRequest(
                tenancyID: tenancy.id,
                renterID: userID,
                requestedDate: requestDate,
                reason: requestReason,
                conditionNotes: conditionNotes,
                photoPlaceholders: placeholders
            )
            checklistItems = tenancy.moveOutChecklist
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func ownerDecision(userID: String, approve: Bool, repository: TenancyRepositoryProtocol) async {
        do {
            tenancy = try await repository.decideMoveOutRequest(tenancyID: tenancy.id, ownerID: userID, approve: approve, note: ownerNote)
            checklistItems = tenancy.moveOutChecklist
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveChecklistAndMeter(userID: String, repository: TenancyRepositoryProtocol) async {
        let reading = TenancyRecord.FinalMeterReading(
            electricity: electricityReading,
            water: waterReading,
            internet: internetReading,
            capturedAt: .now
        )

        do {
            tenancy = try await repository.updateMoveOutChecklist(
                tenancyID: tenancy.id,
                userID: userID,
                items: checklistItems,
                finalMeterReading: reading
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func submitSettlement(userID: String, repository: TenancyRepositoryProtocol) async {
        let deductionDecimal = Decimal(string: deductionAmount) ?? 0
        let refundDecimal = Decimal(string: refundAmount) ?? 0
        let deductions: [TenancyRecord.DepositSettlement.Deduction] = deductionTitle.isEmpty ? [] : [
            .init(id: UUID().uuidString, title: deductionTitle, amount: deductionDecimal, note: deductionNote)
        ]

        let settlement = TenancyRecord.DepositSettlement(
            refundType: refundType,
            deductions: deductions,
            refundAmount: refundDecimal,
            summaryNote: settlementSummary
        )

        do {
            tenancy = try await repository.submitDepositSettlement(tenancyID: tenancy.id, ownerID: userID, settlement: settlement)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func closeTenancy(userID: String, repository: TenancyRepositoryProtocol) async {
        do {
            tenancy = try await repository.closeTenancy(tenancyID: tenancy.id, ownerID: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
