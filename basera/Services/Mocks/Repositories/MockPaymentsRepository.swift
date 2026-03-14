import Foundation

actor MockPaymentsRepository: PaymentsRepositoryProtocol {
    private let billingRepository: BillingRepositoryProtocol
    private let gatewayService: PaymentGatewayServiceProtocol
    private let tenancies: [TenancyRecord]
    private var paymentMethodsByTenancyID: [String: [PaymentRecord.Method]]
    private var payments: [PaymentRecord]
    private var receipts: [PaymentReceipt]
    private var ledgers: [String: SecurityDepositLedger]

    init(
        billingRepository: BillingRepositoryProtocol,
        gatewayService: PaymentGatewayServiceProtocol,
        tenancies: [TenancyRecord] = PreviewData.mockTenancies,
        paymentMethodsByTenancyID: [String: [PaymentRecord.Method]] = PreviewData.mockPaymentMethodsByTenancyID,
        payments: [PaymentRecord] = PreviewData.mockPayments,
        receipts: [PaymentReceipt] = PreviewData.mockPaymentReceipts,
        ledgers: [String: SecurityDepositLedger] = PreviewData.mockDepositLedgersByTenancyID
    ) {
        self.billingRepository = billingRepository
        self.gatewayService = gatewayService
        self.tenancies = tenancies
        self.paymentMethodsByTenancyID = paymentMethodsByTenancyID
        self.payments = payments
        self.receipts = receipts
        self.ledgers = ledgers
    }

    func fetchPaymentMethods(tenancyID: String, userID: String) async throws -> [PaymentRecord.Method] {
        let tenancy = try authorizedTenancy(tenancyID: tenancyID, userID: userID)
        let _ = tenancy
        return paymentMethodsByTenancyID[tenancyID] ?? PaymentRecord.Method.allCases
    }

    func fetchPayments(tenancyID: String, userID: String) async throws -> [PaymentRecord] {
        let tenancy = try authorizedTenancy(tenancyID: tenancyID, userID: userID)
        let _ = tenancy
        return payments
            .filter { $0.tenancyID == tenancyID }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func fetchReceipts(tenancyID: String, userID: String) async throws -> [PaymentReceipt] {
        let tenancy = try authorizedTenancy(tenancyID: tenancyID, userID: userID)
        let _ = tenancy
        return receipts
            .filter { $0.tenancyID == tenancyID }
            .sorted { $0.issuedAt > $1.issuedAt }
    }

    func fetchDepositLedger(tenancyID: String, userID: String) async throws -> SecurityDepositLedger {
        let tenancy = try authorizedTenancy(tenancyID: tenancyID, userID: userID)
        guard let ledger = ledgers[tenancyID] else {
            return SecurityDepositLedger(
                tenancyID: tenancyID,
                totalDeposit: tenancy.depositSummary.totalDeposit,
                heldAmount: tenancy.depositSummary.heldAmount,
                deductions: [],
                plannedRefundAmount: tenancy.depositSummary.plannedRefundAmount ?? 0,
                refundPaidAmount: 0
            )
        }
        return ledger
    }

    func makeGatewayPayment(
        tenancyID: String,
        invoiceID: String,
        payerUserID: String,
        method: PaymentRecord.Method,
        amount: Decimal,
        note: String
    ) async throws -> PaymentGatewayIntent {
        let tenancy = try authorizedTenancy(tenancyID: tenancyID, userID: payerUserID)
        guard payerUserID == tenancy.renterID else { throw PaymentsRepositoryError.forbidden }
        guard method == .eSewa || method == .fonepay else { throw PaymentsRepositoryError.invalidMethod }
        try await validateInvoiceAmount(invoiceID: invoiceID, tenancyID: tenancyID, amount: amount, userID: payerUserID)

        let paymentID = "PAY-\(Int.random(in: 500...999))"
        let payment = PaymentRecord(
            id: paymentID,
            tenancyID: tenancyID,
            invoiceID: invoiceID,
            payerUserID: payerUserID,
            receiverUserID: tenancy.ownerID,
            method: method,
            state: .initiated,
            kind: .invoice,
            amount: amount,
            offlineMarkedByOwner: false,
            note: note,
            createdAt: .now,
            updatedAt: .now
        )
        payments.append(payment)
        return try await gatewayService.createIntent(paymentID: paymentID, method: method, amount: amount)
    }

    func completeGatewayPayment(paymentID: String, userID: String) async throws -> PaymentRecord {
        guard let index = payments.firstIndex(where: { $0.id == paymentID }) else { throw PaymentsRepositoryError.paymentNotFound }
        guard payments[index].payerUserID == userID else { throw PaymentsRepositoryError.forbidden }
        guard payments[index].state == .initiated || payments[index].state == .pendingVerification else { throw PaymentsRepositoryError.invalidPaymentState }

        payments[index].state = .completed
        payments[index].updatedAt = .now

        if let invoiceID = payments[index].invoiceID {
            _ = try await billingRepository.applyPayment(invoiceID: invoiceID, amount: payments[index].amount, recordedBy: userID)
        }

        receipts.append(buildReceipt(from: payments[index], issuedBy: payments[index].receiverUserID))
        return payments[index]
    }

    func markCashPayment(
        tenancyID: String,
        invoiceID: String,
        ownerID: String,
        amount: Decimal,
        note: String,
        happenedOffline: Bool
    ) async throws -> PaymentRecord {
        let tenancy = try authorizedTenancy(tenancyID: tenancyID, userID: ownerID)
        guard tenancy.ownerID == ownerID else { throw PaymentsRepositoryError.forbidden }
        try await validateInvoiceAmount(invoiceID: invoiceID, tenancyID: tenancyID, amount: amount, userID: ownerID)

        let payment = PaymentRecord(
            id: "PAY-\(Int.random(in: 900...1200))",
            tenancyID: tenancyID,
            invoiceID: invoiceID,
            payerUserID: tenancy.renterID,
            receiverUserID: ownerID,
            method: .cash,
            state: .completed,
            kind: .invoice,
            amount: amount,
            offlineMarkedByOwner: happenedOffline,
            note: note,
            createdAt: .now,
            updatedAt: .now
        )
        payments.append(payment)
        _ = try await billingRepository.applyPayment(invoiceID: invoiceID, amount: amount, recordedBy: ownerID)
        receipts.append(buildReceipt(from: payment, issuedBy: ownerID))
        return payment
    }

    func createAdvancePayment(tenancyID: String, payerUserID: String, method: PaymentRecord.Method, amount: Decimal, note: String) async throws -> PaymentRecord {
        let tenancy = try authorizedTenancy(tenancyID: tenancyID, userID: payerUserID)
        guard payerUserID == tenancy.renterID else { throw PaymentsRepositoryError.forbidden }
        guard method != .cash else { throw PaymentsRepositoryError.invalidMethod }
        guard amount > 0 else { throw PaymentsRepositoryError.invalidAmount }

        let payment = PaymentRecord(
            id: "PAY-ADV-\(Int.random(in: 500...999))",
            tenancyID: tenancyID,
            invoiceID: nil,
            payerUserID: payerUserID,
            receiverUserID: tenancy.ownerID,
            method: method,
            state: .completed,
            kind: .advance,
            amount: amount,
            offlineMarkedByOwner: false,
            note: note,
            createdAt: .now,
            updatedAt: .now
        )
        payments.append(payment)
        receipts.append(buildReceipt(from: payment, issuedBy: tenancy.ownerID))
        return payment
    }

    func recordDepositDeductionsAndRefund(
        tenancyID: String,
        ownerID: String,
        deductions: [SecurityDepositLedger.Deduction],
        refundAmount: Decimal,
        note: String
    ) async throws -> SecurityDepositLedger {
        let tenancy = try authorizedTenancy(tenancyID: tenancyID, userID: ownerID)
        guard tenancy.ownerID == ownerID else { throw PaymentsRepositoryError.forbidden }
        guard refundAmount >= 0 else { throw PaymentsRepositoryError.invalidAmount }

        let totalDeductions = deductions.reduce(Decimal.zero) { $0 + $1.amount }
        let held = tenancy.depositSummary.heldAmount
        let plannedRefund = max(held - totalDeductions, 0)
        guard refundAmount <= plannedRefund else { throw PaymentsRepositoryError.invalidAmount }

        var ledger = SecurityDepositLedger(
            tenancyID: tenancyID,
            totalDeposit: tenancy.depositSummary.totalDeposit,
            heldAmount: held,
            deductions: deductions,
            plannedRefundAmount: plannedRefund,
            refundPaidAmount: refundAmount
        )

        ledgers[tenancyID] = ledger

        if refundAmount > 0 {
            let refundPayment = PaymentRecord(
                id: "PAY-REF-\(Int.random(in: 100...499))",
                tenancyID: tenancyID,
                invoiceID: nil,
                payerUserID: ownerID,
                receiverUserID: tenancy.renterID,
                method: .cash,
                state: .completed,
                kind: .depositRefund,
                amount: refundAmount,
                offlineMarkedByOwner: true,
                note: note,
                createdAt: .now,
                updatedAt: .now
            )
            payments.append(refundPayment)
            receipts.append(buildReceipt(from: refundPayment, issuedBy: ownerID))
        }

        return ledger
    }

    private func authorizedTenancy(tenancyID: String, userID: String) throws -> TenancyRecord {
        guard let tenancy = tenancies.first(where: { $0.id == tenancyID }) else { throw PaymentsRepositoryError.tenancyNotFound }
        guard tenancy.ownerID == userID || tenancy.renterID == userID else { throw PaymentsRepositoryError.forbidden }
        return tenancy
    }

    private func validateInvoiceAmount(invoiceID: String, tenancyID: String, amount: Decimal, userID: String) async throws {
        guard amount > 0 else { throw PaymentsRepositoryError.invalidAmount }

        guard let invoice = try await billingRepository.fetchInvoice(id: invoiceID, userID: userID) else {
            throw PaymentsRepositoryError.invoiceNotFound
        }
        guard invoice.header.tenancyID == tenancyID else { throw PaymentsRepositoryError.invoiceNotFound }
        guard amount <= invoice.amountRemaining else { throw PaymentsRepositoryError.invalidAmount }
    }

    private func buildReceipt(from payment: PaymentRecord, issuedBy: String) -> PaymentReceipt {
        PaymentReceipt(
            id: "RCT-\(UUID().uuidString.prefix(6))",
            paymentID: payment.id,
            tenancyID: payment.tenancyID,
            invoiceID: payment.invoiceID,
            amount: payment.amount,
            method: payment.method,
            issuedToUserID: payment.payerUserID,
            issuedByUserID: issuedBy,
            issuedAt: .now,
            lineItems: [
                "Type: \(payment.kind.title)",
                "State: \(payment.state.title)",
                payment.note.isEmpty ? "No note" : payment.note
            ]
        )
    }
}
