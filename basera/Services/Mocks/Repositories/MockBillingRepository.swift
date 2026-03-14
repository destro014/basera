import Foundation

actor MockBillingRepository: BillingRepositoryProtocol {
    private var tenancies: [TenancyRecord]
    private var settingsByTenancyID: [String: BillingTenancySettings]
    private var invoices: [InvoiceRecord]

    init(
        tenancies: [TenancyRecord] = PreviewData.mockTenancies,
        settingsByTenancyID: [String: BillingTenancySettings] = PreviewData.mockBillingSettingsByTenancyID,
        invoices: [InvoiceRecord] = PreviewData.mockInvoices
    ) {
        self.tenancies = tenancies
        self.settingsByTenancyID = settingsByTenancyID
        self.invoices = invoices
    }

    func fetchSettings(tenancyID: String, userID: String) async throws -> BillingTenancySettings? {
        guard let tenancy = tenancy(for: tenancyID) else { return nil }
        guard tenancy.ownerID == userID || tenancy.renterID == userID else { throw BillingRepositoryError.forbidden }
        return settingsByTenancyID[tenancyID] ?? .init(allowsRenterGeneratedBillDraft: false, allowsPartialPayment: true, allowsAdvancePayment: true)
    }

    func updateSettings(tenancyID: String, ownerID: String, settings: BillingTenancySettings) async throws -> BillingTenancySettings {
        guard let tenancy = tenancy(for: tenancyID) else { throw BillingRepositoryError.tenancyNotFound }
        guard tenancy.ownerID == ownerID else { throw BillingRepositoryError.forbidden }
        settingsByTenancyID[tenancyID] = settings
        return settings
    }

    func fetchInvoices(tenancyID: String, userID: String) async throws -> [InvoiceRecord] {
        guard let tenancy = tenancy(for: tenancyID) else { throw BillingRepositoryError.tenancyNotFound }
        guard tenancy.ownerID == userID || tenancy.renterID == userID else { throw BillingRepositoryError.forbidden }
        return invoices
            .filter { $0.header.tenancyID == tenancyID }
            .sorted { $0.header.billingMonth > $1.header.billingMonth }
    }

    func fetchInvoice(id: String, userID: String) async throws -> InvoiceRecord? {
        guard let invoice = invoices.first(where: { $0.id == id }) else { return nil }
        guard invoice.header.ownerID == userID || invoice.header.renterID == userID else { throw BillingRepositoryError.forbidden }
        return invoice
    }

    func previewInvoice(from draft: InvoiceDraftInput, userID: String) async throws -> InvoiceRecord {
        try validateMonthly(draft: draft)
        guard draft.ownerID == userID || draft.renterID == userID else { throw BillingRepositoryError.forbidden }
        let carryForward = currentCarryForward(tenancyID: draft.tenancyID)
        return buildInvoice(id: "PREVIEW", draft: draft, status: statusForDraftCreator(draft), carryForward: carryForward)
    }

    func createInvoice(from draft: InvoiceDraftInput, userID: String) async throws -> InvoiceRecord {
        try validateMonthly(draft: draft)
        guard let tenancy = tenancy(for: draft.tenancyID) else { throw BillingRepositoryError.tenancyNotFound }
        guard draft.ownerID == tenancy.ownerID, draft.renterID == tenancy.renterID else { throw BillingRepositoryError.forbidden }
        guard draft.ownerID == userID || draft.renterID == userID else { throw BillingRepositoryError.forbidden }
        if monthExists(tenancyID: draft.tenancyID, billingMonth: draft.billingMonth) { throw BillingRepositoryError.alreadyExistsForMonth }

        if userID == draft.renterID {
            let settings = settingsByTenancyID[draft.tenancyID] ?? .init(allowsRenterGeneratedBillDraft: false, allowsPartialPayment: true, allowsAdvancePayment: true)
            guard settings.allowsRenterGeneratedBillDraft else { throw BillingRepositoryError.renterDraftDisabled }
        }

        let invoice = buildInvoice(
            id: "INV-\(Int.random(in: 500...999))",
            draft: draft,
            status: statusForDraftCreator(draft),
            carryForward: currentCarryForward(tenancyID: draft.tenancyID)
        )
        invoices.append(invoice)
        return invoice
    }

    func approveInvoice(invoiceID: String, ownerID: String) async throws -> InvoiceRecord {
        guard let index = invoices.firstIndex(where: { $0.id == invoiceID }) else { throw BillingRepositoryError.invoiceNotFound }
        guard invoices[index].header.ownerID == ownerID else { throw BillingRepositoryError.forbidden }
        guard invoices[index].status == .pendingOwnerApproval else { throw BillingRepositoryError.invalidTransition }
        invoices[index].status = .pendingPayment
        invoices[index].updatedAt = .now
        return invoices[index]
    }

    func rejectInvoice(invoiceID: String, ownerID: String, reason: String) async throws -> InvoiceRecord {
        guard let index = invoices.firstIndex(where: { $0.id == invoiceID }) else { throw BillingRepositoryError.invoiceNotFound }
        guard invoices[index].header.ownerID == ownerID else { throw BillingRepositoryError.forbidden }
        guard invoices[index].status == .pendingOwnerApproval else { throw BillingRepositoryError.invalidTransition }
        invoices[index].status = .rejectedByOwner
        invoices[index].rejectionReason = reason
        invoices[index].updatedAt = .now
        return invoices[index]
    }

    func applyPayment(invoiceID: String, amount: Decimal, recordedBy userID: String) async throws -> InvoiceRecord {
        guard amount > 0 else { throw PaymentsRepositoryError.invalidAmount }
        guard let index = invoices.firstIndex(where: { $0.id == invoiceID }) else { throw BillingRepositoryError.invoiceNotFound }
        guard invoices[index].header.ownerID == userID || invoices[index].header.renterID == userID else { throw BillingRepositoryError.forbidden }
        guard invoices[index].status == .pendingPayment || invoices[index].status == .partiallyPaid else { throw BillingRepositoryError.invalidTransition }

        let remainingBefore = invoices[index].amountRemaining
        guard amount <= remainingBefore else { throw PaymentsRepositoryError.invalidAmount }

        invoices[index].paidAmount += amount
        invoices[index].status = invoices[index].amountRemaining == 0 ? .paid : .partiallyPaid
        invoices[index].updatedAt = .now
        return invoices[index]
    }

    private func tenancy(for tenancyID: String) -> TenancyRecord? {
        tenancies.first(where: { $0.id == tenancyID })
    }

    private func monthExists(tenancyID: String, billingMonth: Date) -> Bool {
        let components = Calendar.current.dateComponents([.year, .month], from: billingMonth)
        return invoices.contains { invoice in
            guard invoice.header.tenancyID == tenancyID else { return false }
            let invoiceMonth = Calendar.current.dateComponents([.year, .month], from: invoice.header.billingMonth)
            return invoiceMonth.year == components.year && invoiceMonth.month == components.month
        }
    }

    private func validateMonthly(draft: InvoiceDraftInput) throws {
        let comps = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: draft.billingMonth)
        if (comps.day ?? 1) != 1 || (comps.hour ?? 0) != 0 || (comps.minute ?? 0) != 0 {
            throw BillingRepositoryError.invalidMonth
        }
    }

    private func currentCarryForward(tenancyID: String) -> Decimal {
        invoices
            .filter { $0.header.tenancyID == tenancyID }
            .reduce(Decimal.zero) { partial, invoice in
                partial + invoice.amountRemaining
            }
    }

    private func statusForDraftCreator(_ draft: InvoiceDraftInput) -> InvoiceRecord.Status {
        draft.createdByRole == .owner ? .pendingPayment : .pendingOwnerApproval
    }

    private func buildInvoice(id: String, draft: InvoiceDraftInput, status: InvoiceRecord.Status, carryForward: Decimal) -> InvoiceRecord {
        var items: [InvoiceRecord.Item] = [
            .init(id: UUID().uuidString, category: .rent, title: "Monthly rent", detail: nil, amount: draft.rentAmount)
        ]

        if let electricity = draft.electricityMode {
            items.append(.init(
                id: UUID().uuidString,
                category: .electricity,
                title: "Electricity",
                detail: electricity.detailText,
                amount: electricity.computedAmount
            ))
        }

        items.append(contentsOf: draft.utilityCharges.map {
            .init(
                id: $0.id,
                category: $0.category,
                title: $0.category.title,
                detail: $0.mode.detailText,
                amount: $0.mode.computedAmount
            )
        })

        items.append(contentsOf: draft.otherCharges.map {
            .init(id: $0.id, category: .other, title: $0.title, detail: nil, amount: $0.amount)
        })

        items.append(contentsOf: draft.deductions.map {
            .init(id: $0.id, category: .deduction, title: $0.title, detail: nil, amount: $0.amount)
        })

        items.append(contentsOf: draft.credits.map {
            .init(id: $0.id, category: .credit, title: $0.title, detail: nil, amount: $0.amount)
        })

        return InvoiceRecord(
            id: id,
            header: .init(
                tenancyID: draft.tenancyID,
                listingTitle: draft.listingTitle,
                billingMonth: draft.billingMonth,
                issueDate: .now,
                dueDate: draft.dueDate,
                ownerID: draft.ownerID,
                renterID: draft.renterID
            ),
            createdByRole: draft.createdByRole,
            status: status,
            items: items,
            carryForwardBalance: carryForward,
            paidAmount: 0,
            note: draft.note,
            rejectionReason: nil,
            createdAt: .now,
            updatedAt: .now
        )
    }
}
