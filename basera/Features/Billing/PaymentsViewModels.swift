import Combine
import Foundation

@MainActor
final class PaymentsHubViewModel: ObservableObject {
    @Published private(set) var methods: [PaymentRecord.Method] = []
    @Published private(set) var payments: [PaymentRecord] = []
    @Published private(set) var receipts: [PaymentReceipt] = []
    @Published private(set) var depositLedger: SecurityDepositLedger?
    @Published var selectedMethod: PaymentRecord.Method = .eSewa
    @Published var amountText = ""
    @Published var note = ""
    @Published private(set) var latestGatewayIntent: PaymentGatewayIntent?
    @Published var errorMessage: String?

    func load(tenancyID: String, userID: String, repository: PaymentsRepositoryProtocol) async {
        do {
            methods = try await repository.fetchPaymentMethods(tenancyID: tenancyID, userID: userID)
            payments = try await repository.fetchPayments(tenancyID: tenancyID, userID: userID)
            receipts = try await repository.fetchReceipts(tenancyID: tenancyID, userID: userID)
            depositLedger = try await repository.fetchDepositLedger(tenancyID: tenancyID, userID: userID)
            if let first = methods.first {
                selectedMethod = first
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func makeGatewayPayment(tenancyID: String, invoiceID: String, userID: String, repository: PaymentsRepositoryProtocol) async {
        do {
            let amount = Decimal(string: amountText) ?? 0
            latestGatewayIntent = try await repository.makeGatewayPayment(
                tenancyID: tenancyID,
                invoiceID: invoiceID,
                payerUserID: userID,
                method: selectedMethod,
                amount: amount,
                note: note
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func completeGatewayPayment(userID: String, repository: PaymentsRepositoryProtocol, tenancyID: String) async {
        guard let intent = latestGatewayIntent else { return }
        do {
            _ = try await repository.completeGatewayPayment(paymentID: intent.paymentID, userID: userID)
            await refreshHistory(tenancyID: tenancyID, userID: userID, repository: repository)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markCashPayment(tenancyID: String, invoiceID: String, ownerID: String, repository: PaymentsRepositoryProtocol) async {
        do {
            let amount = Decimal(string: amountText) ?? 0
            _ = try await repository.markCashPayment(
                tenancyID: tenancyID,
                invoiceID: invoiceID,
                ownerID: ownerID,
                amount: amount,
                note: note,
                happenedOffline: true
            )
            await refreshHistory(tenancyID: tenancyID, userID: ownerID, repository: repository)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addAdvancePayment(tenancyID: String, userID: String, repository: PaymentsRepositoryProtocol) async {
        do {
            let amount = Decimal(string: amountText) ?? 0
            _ = try await repository.createAdvancePayment(tenancyID: tenancyID, payerUserID: userID, method: selectedMethod, amount: amount, note: note)
            await refreshHistory(tenancyID: tenancyID, userID: userID, repository: repository)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateDeposit(tenancyID: String, ownerID: String, refundAmountText: String, deductionTitle: String, deductionAmountText: String, repository: PaymentsRepositoryProtocol) async {
        do {
            let refund = Decimal(string: refundAmountText) ?? 0
            let deductionAmount = Decimal(string: deductionAmountText) ?? 0
            let deductions: [SecurityDepositLedger.Deduction] = deductionTitle.isEmpty ? [] : [
                .init(id: UUID().uuidString, title: deductionTitle, amount: deductionAmount, note: "Move-out deduction")
            ]
            depositLedger = try await repository.recordDepositDeductionsAndRefund(
                tenancyID: tenancyID,
                ownerID: ownerID,
                deductions: deductions,
                refundAmount: refund,
                note: "Move-out deposit settlement"
            )
            await refreshHistory(tenancyID: tenancyID, userID: ownerID, repository: repository)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshHistory(tenancyID: String, userID: String, repository: PaymentsRepositoryProtocol) async {
        do {
            payments = try await repository.fetchPayments(tenancyID: tenancyID, userID: userID)
            receipts = try await repository.fetchReceipts(tenancyID: tenancyID, userID: userID)
            depositLedger = try await repository.fetchDepositLedger(tenancyID: tenancyID, userID: userID)
            amountText = ""
            note = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
