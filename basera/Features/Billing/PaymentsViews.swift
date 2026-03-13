import SwiftUI

struct PaymentsHubView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = PaymentsHubViewModel()

    let tenancy: TenancyRecord
    let userID: String
    let actor: InvoiceRecord.CreatedByRole

    @State private var deductionTitle = ""
    @State private var deductionAmount = ""
    @State private var refundAmount = ""

    var body: some View {
        List {
            Section("Payment method selection") {
                Picker("Method", selection: $viewModel.selectedMethod) {
                    ForEach(viewModel.methods, id: \.self) { method in
                        Text(method.title).tag(method)
                    }
                }
                BaseraTextField(title: "Amount", text: $viewModel.amountText, keyboardType: .decimalPad)
                BaseraTextField(title: "Note", text: $viewModel.note)
            }

            Section("Gateway placeholders") {
                Button("Start eSewa placeholder") {
                    viewModel.selectedMethod = .eSewa
                    Task { await viewModel.makeGatewayPayment(tenancyID: tenancy.id, invoiceID: tenancy.billSummary.currentInvoiceID, userID: userID, repository: environment.paymentsRepository) }
                }
                Button("Start Fonepay placeholder") {
                    viewModel.selectedMethod = .fonepay
                    Task { await viewModel.makeGatewayPayment(tenancyID: tenancy.id, invoiceID: tenancy.billSummary.currentInvoiceID, userID: userID, repository: environment.paymentsRepository) }
                }
                if let intent = viewModel.latestGatewayIntent {
                    Text(intent.gatewayDisplayMessage)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    Button("Mark placeholder as completed") {
                        Task { await viewModel.completeGatewayPayment(userID: userID, repository: environment.paymentsRepository, tenancyID: tenancy.id) }
                    }
                }
            }

            if actor == .owner {
                Section("Cash payment marking (offline supported)") {
                    Button("Mark cash as paid manually") {
                        Task { await viewModel.markCashPayment(tenancyID: tenancy.id, invoiceID: tenancy.billSummary.currentInvoiceID, ownerID: userID, repository: environment.paymentsRepository) }
                    }
                }
            }

            Section("Advance payment") {
                Button("Record advance payment") {
                    Task { await viewModel.addAdvancePayment(tenancyID: tenancy.id, userID: userID, repository: environment.paymentsRepository) }
                }
            }

            Section("Payment history") {
                ForEach(viewModel.payments) { payment in
                    VStack(alignment: .leading) {
                        Text("\(payment.kind.title) • \(payment.method.title) • Rs. \(NSDecimalNumber(decimal: payment.amount).stringValue)")
                        Text("\(payment.state.title)\(payment.offlineMarkedByOwner ? " • Offline marked" : "")")
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
            }

            Section("Receipts") {
                ForEach(viewModel.receipts) { receipt in
                    VStack(alignment: .leading) {
                        Text("Receipt \(receipt.id)")
                        Text("Rs. \(NSDecimalNumber(decimal: receipt.amount).stringValue) • \(receipt.method.title)")
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
            }

            Section("Security deposit tracking + refund") {
                if let ledger = viewModel.depositLedger {
                    Text("Held: Rs. \(NSDecimalNumber(decimal: ledger.heldAmount).stringValue)")
                    Text("Planned refund: Rs. \(NSDecimalNumber(decimal: ledger.plannedRefundAmount).stringValue)")
                    Text("Remaining refund: Rs. \(NSDecimalNumber(decimal: ledger.remainingRefundAmount).stringValue)")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }

                if actor == .owner {
                    BaseraTextField(title: "Deduction title", text: $deductionTitle)
                    BaseraTextField(title: "Deduction amount", text: $deductionAmount, keyboardType: .decimalPad)
                    BaseraTextField(title: "Refund amount", text: $refundAmount, keyboardType: .decimalPad)
                    Button("Apply deduction and refund summary") {
                        Task {
                            await viewModel.updateDeposit(
                                tenancyID: tenancy.id,
                                ownerID: userID,
                                refundAmountText: refundAmount,
                                deductionTitle: deductionTitle,
                                deductionAmountText: deductionAmount,
                                repository: environment.paymentsRepository
                            )
                        }
                    }
                }
            }
        }
        .baseraListBackground()
        .navigationTitle(actor == .owner ? "Tenant Payments" : "My Payments")
        .task {
            await viewModel.load(tenancyID: tenancy.id, userID: userID, repository: environment.paymentsRepository)
        }
        .alert("Payment error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: { Text(viewModel.errorMessage ?? "") })
    }
}

#Preview {
    NavigationView {
        PaymentsHubView(tenancy: PreviewData.mockTenancies[0], userID: "preview-user-001", actor: .renter)
            .environmentObject(AppEnvironment.bootstrap())
    }
}
