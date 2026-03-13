import SwiftUI

struct OwnerDashboardView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = OwnerTenantOverviewViewModel()

    let ownerID: String

    var body: some View {
        ScrollView {
            BaseraPageContainer {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                    BaseraCard {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                            Text("Owner Dashboard")
                                .baseraTextStyle(AppTheme.Typography.titleLarge)
                            Text("Manage listings, active tenants, billing, and agreements from one place.")
                                .baseraTextStyle(AppTheme.Typography.bodyMedium)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Quick Actions")
                            .baseraTextStyle(AppTheme.Typography.titleMedium)

                        NavigationLink {
                            MyListingsView(ownerID: ownerID)
                        } label: {
                            BaseraActionTile(
                                title: "Manage My Listings",
                                subtitle: "Create, edit, pause, and preview listings",
                                systemImage: "building.2"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            ReviewHubView(userID: ownerID, role: .owner)
                        } label: {
                            BaseraActionTile(
                                title: "Reviews & Ratings",
                                subtitle: "Check renter feedback and your profile score",
                                systemImage: "star.bubble"
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    if viewModel.activeTenancies.isEmpty {
                        BaseraInlineMessageView(tone: .info, message: "No active tenants yet. Signed agreements appear here as active tenancies.")
                    } else {
                        ForEach(viewModel.activeTenancies) { tenancy in
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                                TenancySummaryCard(tenancy: tenancy, party: .owner)
                                VStack(spacing: AppTheme.Spacing.small) {
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
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                                Text("Archived Tenancies")
                                    .baseraTextStyle(AppTheme.Typography.titleMedium)
                                ForEach(viewModel.archivedTenancies) { archived in
                                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                                        Text(archived.listingTitle)
                                            .baseraTextStyle(AppTheme.Typography.labelLarge)
                                        VStack(spacing: AppTheme.Spacing.small) {
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
    }
}

#Preview {
    NavigationView {
        OwnerDashboardView(ownerID: "preview-user-001")
            .environmentObject(AppEnvironment.bootstrap())
    }
}
