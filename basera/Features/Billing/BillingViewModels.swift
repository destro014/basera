import Combine
import Foundation

@MainActor
final class InvoiceListViewModel: ObservableObject {
    @Published private(set) var invoices: [InvoiceRecord] = []
    @Published private(set) var settings: BillingTenancySettings?
    @Published var errorMessage: String?

    func load(tenancyID: String, userID: String, repository: BillingRepositoryProtocol) async {
        do {
            invoices = try await repository.fetchInvoices(tenancyID: tenancyID, userID: userID)
            settings = try await repository.fetchSettings(tenancyID: tenancyID, userID: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@MainActor
final class InvoiceComposerViewModel: ObservableObject {
    enum ElectricityInputMode: String, CaseIterable {
        case flat
        case consumedUnits
        case meterBased
    }

    @Published var billMonth: Date
    @Published var dueDate: Date
    @Published var rentAmountText: String

    @Published var includesElectricity = true
    @Published var electricityInputMode: ElectricityInputMode = .flat
    @Published var electricityFlatAmountText = ""
    @Published var electricityUnitsText = ""
    @Published var electricityRateText = ""
    @Published var electricityPreviousReadingText = ""
    @Published var electricityCurrentReadingText = ""

    @Published var utilityCharges: [InvoiceDraftInput.UtilityCharge] = []
    @Published var otherCharges: [InvoiceDraftInput.AmountNote] = []
    @Published var deductions: [InvoiceDraftInput.AmountNote] = []
    @Published var credits: [InvoiceDraftInput.AmountNote] = []
    @Published var note = ""

    @Published private(set) var previewInvoice: InvoiceRecord?
    @Published var errorMessage: String?

    init(monthlyRent: Decimal) {
        let month = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: .now)) ?? .now
        billMonth = month
        dueDate = Calendar.current.date(byAdding: .day, value: 5, to: .now) ?? .now
        rentAmountText = NSDecimalNumber(decimal: monthlyRent).stringValue
        utilityCharges = [
            .init(id: "water", category: .water, mode: .flat(amount: 0)),
            .init(id: "garbage", category: .garbage, mode: .flat(amount: 0)),
            .init(id: "internet", category: .internet, mode: .flat(amount: 0)),
            .init(id: "parking", category: .parking, mode: .flat(amount: 0))
        ]
    }

    func loadPreview(tenancy: TenancyRecord, actor: InvoiceRecord.CreatedByRole, repository: BillingRepositoryProtocol, userID: String) async {
        do {
            let draft = draftInput(tenancy: tenancy, actor: actor)
            previewInvoice = try await repository.previewInvoice(from: draft, userID: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func submit(tenancy: TenancyRecord, actor: InvoiceRecord.CreatedByRole, repository: BillingRepositoryProtocol, userID: String) async -> InvoiceRecord? {
        do {
            let draft = draftInput(tenancy: tenancy, actor: actor)
            return try await repository.createInvoice(from: draft, userID: userID)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private func decimal(_ text: String) -> Decimal {
        Decimal(string: text) ?? 0
    }

    private func draftInput(tenancy: TenancyRecord, actor: InvoiceRecord.CreatedByRole) -> InvoiceDraftInput {
        let electricity: InvoiceDraftInput.ElectricityMode?
        if includesElectricity {
            switch electricityInputMode {
            case .flat:
                electricity = .flatFee(amount: decimal(electricityFlatAmountText))
            case .consumedUnits:
                electricity = .consumedUnits(units: decimal(electricityUnitsText), ratePerUnit: decimal(electricityRateText))
            case .meterBased:
                electricity = .meterBased(previousReading: decimal(electricityPreviousReadingText), currentReading: decimal(electricityCurrentReadingText), ratePerUnit: decimal(electricityRateText))
            }
        } else {
            electricity = nil
        }

        let normalizedMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: billMonth)) ?? billMonth

        return InvoiceDraftInput(
            tenancyID: tenancy.id,
            ownerID: tenancy.ownerID,
            renterID: tenancy.renterID,
            listingTitle: tenancy.listingTitle,
            billingMonth: normalizedMonth,
            dueDate: dueDate,
            createdByRole: actor,
            rentAmount: decimal(rentAmountText),
            electricityMode: electricity,
            utilityCharges: utilityCharges,
            otherCharges: otherCharges,
            deductions: deductions,
            credits: credits,
            note: note
        )
    }
}
