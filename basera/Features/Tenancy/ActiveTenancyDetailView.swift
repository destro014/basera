import SwiftUI
import VroxalDesign

struct ActiveTenancyDetailView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = ActiveTenancyDetailViewModel()

    let tenancyID: String
    let userID: String
    let party: AgreementRecord.Party

    var body: some View {
        ScrollView {
            if let tenancy = viewModel.tenancy {
                VStack(alignment: .leading, spacing: VdSpacing.smMd) {
                    TenancySummaryCard(tenancy: tenancy, party: party)
                    dueBillCard(tenancy)
                    DepositSummaryCard(deposit: tenancy.depositSummary)

                    NavigationLink("Move-out and tenancy closure") {
                        MoveOutFlowView(tenancy: tenancy, userID: userID, party: party)
                    }

                    NavigationLink("Open move-in checklist") {
                        MoveInChecklistView(tenancy: tenancy, userID: userID)
                    }

                    historicalAccessCard(tenancy)

                    if let agreement = viewModel.agreement {
                        BaseraCard {
                            VStack(alignment: .leading, spacing: VdSpacing.sm) {
                                Text("Agreement")
                                    .vdFont(VdFont.titleMedium)
                                Text("Status: \(agreement.status.title)")
                                Text(agreement.isLocked ? "Signed agreement is locked." : "Agreement editable before signing.")
                            }
                        }
                    }
                }
                .padding()
            } else {
                VdEmptyState(title: "No tenancy found", message: "This tenancy may be archived or unavailable.")
                    .padding()
            }
        }
        .navigationTitle("Tenancy Details")
        .task {
            await viewModel.load(
                tenancyID: tenancyID,
                userID: userID,
                tenancyRepository: environment.tenancyRepository,
                agreementsRepository: environment.agreementsRepository
            )
        }
    }

    private func dueBillCard(_ tenancy: TenancyRecord) -> some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: VdSpacing.sm) {
                Text("Current Billing")
                    .vdFont(VdFont.titleMedium)
                Text("Due: Rs. \(NSDecimalNumber(decimal: tenancy.billSummary.amountDue).intValue)")
                Text("Due date: \(tenancy.billSummary.dueDate.formatted(date: .abbreviated, time: .omitted))")
                Text("Carry-forward: Rs. \(NSDecimalNumber(decimal: tenancy.billSummary.carryForward).intValue)")
                    .foregroundStyle(Color.vdContentDefaultSecondary)
                HStack {
                    BaseraChip(text: tenancy.billSummary.allowsPartialPayment ? "Partial payment enabled" : "Partial payment disabled")
                    BaseraChip(text: tenancy.billSummary.allowsAdvancePayment ? "Advance payment enabled" : "Advance payment disabled")
                }
            }
        }
    }

    private func historicalAccessCard(_ tenancy: TenancyRecord) -> some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: VdSpacing.sm) {
                Text("Historical access")
                    .vdFont(VdFont.titleMedium)
                Text("Agreement, invoice, and payment records stay available after tenancy closure.")
                    .foregroundStyle(Color.vdContentDefaultSecondary)
                HStack {
                    NavigationLink("Agreement") {
                        AgreementHubView(currentUserID: userID, party: party)
                    }
                    NavigationLink("Invoices") {
                        InvoiceListView(tenancy: tenancy, userID: userID, actor: party == .owner ? .owner : .renter)
                    }
                    NavigationLink("Payments") {
                        PaymentsHubView(tenancy: tenancy, userID: userID, actor: party == .owner ? .owner : .renter)
                    }
                }
                .vdFont(VdFont.bodySmall)
            }
        }
    }
}

#Preview {
    NavigationView {
        ActiveTenancyDetailView(tenancyID: "TEN-300", userID: "preview-user-001", party: .renter)
            .environmentObject(AppEnvironment.bootstrap())
    }
}
