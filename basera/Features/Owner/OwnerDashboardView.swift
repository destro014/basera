import SwiftUI

struct OwnerDashboardView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = OwnerTenantOverviewViewModel()

    let ownerID: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                BaseraCard {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Owner Tenant Overview")
                            .baseraTextStyle(AppTheme.Typography.titleLarge)
                        Text("Manage active tenants with quick links to monthly billing and signed agreements.")
                            .baseraTextStyle(AppTheme.Typography.bodyMedium)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }

                NavigationLink("Reviews & Rating") {
                    ReviewHubView(userID: ownerID, role: .owner)
                }
                .baseraTextStyle(AppTheme.Typography.bodyMedium)

                if viewModel.activeTenancies.isEmpty {
                    BaseraInlineMessageView(tone: .info, message: "No active tenants yet. Signed agreements appear here as active tenancies.")
                } else {
                    ForEach(viewModel.activeTenancies) { tenancy in
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                            TenancySummaryCard(tenancy: tenancy, party: .owner)
                            HStack {
                                NavigationLink("Billing") {
                                    InvoiceListView(tenancy: tenancy, userID: ownerID, actor: .owner)
                                }
                                NavigationLink("Payments") {
                                    PaymentsHubView(tenancy: tenancy, userID: ownerID, actor: .owner)
                                }
                                NavigationLink("Agreement") {
                                    AgreementHubView(currentUserID: ownerID, party: .owner)
                                }
                                NavigationLink("Tenancy detail") {
                                    ActiveTenancyDetailView(tenancyID: tenancy.id, userID: ownerID, party: .owner)
                                }
                            }
                            .baseraTextStyle(AppTheme.Typography.bodySmall)
                        }
                    }
                }

                if viewModel.archivedTenancies.isEmpty == false {
                    BaseraCard {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                            Text("Archived Tenancies")
                                .baseraTextStyle(AppTheme.Typography.titleMedium)
                            Text("Archive placeholders are ready for post move-out access to agreement, invoices, and payments.")
                                .baseraTextStyle(AppTheme.Typography.bodySmall)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                    }
                }

                MyListingsView(ownerID: ownerID)
            }
            .padding()
        }
        .task {
            await viewModel.load(ownerID: ownerID, tenancyRepository: environment.tenancyRepository)
        }
    }
}

#Preview {
    NavigationView {
        OwnerDashboardView(ownerID: "preview-user-001")
            .environmentObject(AppEnvironment.bootstrap())
    }
}
