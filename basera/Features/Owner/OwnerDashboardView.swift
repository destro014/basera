import SwiftUI
import VroxalDesign

struct OwnerDashboardView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = OwnerTenantOverviewViewModel()

    let ownerID: String

    var body: some View {
        ScrollView {
            BaseraPageContainer {
                VStack(alignment: .leading, spacing: VdSpacing.md) {
                    BaseraCard {
                        VStack(alignment: .leading, spacing: VdSpacing.sm) {
                            Text("Owner Dashboard")
                                .vdFont(VdFont.titleLarge)
                            Text("Manage listings, active tenants, billing, and agreements from one place.")
                                .vdFont(VdFont.bodyMedium)
                                .foregroundStyle(Color.vdContentDefaultSecondary)
                        }
                    }

                    if viewModel.activeTenancies.isEmpty {
                        VdAlert(tone: .info, message: "No active tenants yet. Signed agreements appear here as active tenancies.")
                    } else {
                        ForEach(viewModel.activeTenancies) { tenancy in
                            VStack(alignment: .leading, spacing: VdSpacing.sm) {
                                TenancySummaryCard(tenancy: tenancy, party: .owner)
                                VStack(spacing: VdSpacing.sm) {
                                    NavigationLink {
                                        InvoiceListView(tenancy: tenancy, userID: ownerID, actor: .owner)
                                    } label: {
                                        BaseraActionTile(title: "Billing", subtitle: "Issue and track invoices", systemImage: "doc.text")
                                    }
                                    .buttonStyle(.plain)

                                    NavigationLink {
                                        PaymentsHubView(tenancy: tenancy, userID: ownerID, actor: .owner)
                                    } label: {
                                        BaseraActionTile(title: "Payments", subtitle: "Review payment status", systemImage: "creditcard")
                                    }
                                    .buttonStyle(.plain)

                                    NavigationLink {
                                        AgreementHubView(currentUserID: ownerID, party: .owner)
                                    } label: {
                                        BaseraActionTile(title: "Agreement", subtitle: "View signed agreement records", systemImage: "doc.richtext")
                                    }
                                    .buttonStyle(.plain)

                                    NavigationLink {
                                        ActiveTenancyDetailView(tenancyID: tenancy.id, userID: ownerID, party: .owner)
                                    } label: {
                                        BaseraActionTile(title: "Tenancy Detail", subtitle: "Move-in, move-out, and assignment info", systemImage: "person.3")
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    if !viewModel.archivedTenancies.isEmpty {
                        BaseraCard {
                            VStack(alignment: .leading, spacing: VdSpacing.sm) {
                                Text("Archived Tenancies")
                                    .vdFont(VdFont.titleMedium)
                                ForEach(viewModel.archivedTenancies) { archived in
                                    VStack(alignment: .leading, spacing: VdSpacing.sm) {
                                        Text(archived.listingTitle)
                                            .vdFont(VdFont.labelLarge)
                                        VStack(spacing: VdSpacing.sm) {
                                            NavigationLink {
                                                AgreementHubView(currentUserID: ownerID, party: .owner)
                                            } label: {
                                                BaseraActionTile(title: "Agreement", subtitle: nil, systemImage: "doc.richtext")
                                            }
                                            .buttonStyle(.plain)

                                            NavigationLink {
                                                InvoiceListView(tenancy: archived, userID: ownerID, actor: .owner)
                                            } label: {
                                                BaseraActionTile(title: "Invoices", subtitle: nil, systemImage: "doc.text")
                                            }
                                            .buttonStyle(.plain)

                                            NavigationLink {
                                                PaymentsHubView(tenancy: archived, userID: ownerID, actor: .owner)
                                            } label: {
                                                BaseraActionTile(title: "Payments", subtitle: nil, systemImage: "creditcard")
                                            }
                                            .buttonStyle(.plain)

                                            NavigationLink {
                                                ReviewHubView(userID: ownerID, role: .owner)
                                            } label: {
                                                BaseraActionTile(title: "Review Renter", subtitle: nil, systemImage: "star")
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.load(ownerID: ownerID, tenancyRepository: environment.tenancyRepository)
        }
        .baseraScreenBackground()
    }
}

#Preview {
    NavigationView {
        OwnerDashboardView(ownerID: "preview-user-001")
            .environmentObject(AppEnvironment.bootstrap())
    }
}
