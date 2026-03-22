import SwiftUI
import VroxalDesign

struct RenterDashboardView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = RenterDashboardViewModel()
    @StateObject private var tenancyViewModel = RenterActiveTenancyViewModel()

    let renterID: String
    let renterSnapshot: RenterProfileSnapshot

    init(
        renterID: String = "preview-user-001",
        renterSnapshot: RenterProfileSnapshot = .init(
            renterID: "preview-user-001",
            fullName: "Sita Basera",
            occupation: "Software Engineer",
            familySize: 3,
            hasPets: false,
            smokingStatus: "Non-smoker"
        )
    ) {
        self.renterID = renterID
        self.renterSnapshot = renterSnapshot
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                VdLoadingState(title: "Finding rentals for you")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            case .error(let message):
                VdAlert(title: "Unable to load Explore", message: message) {
                    Task { await viewModel.retry(using: environment.listingsRepository) }
                }
            case .loaded:
                exploreContent
            }
        }
        .background(Color.vdBackgroundDefaultBase)
        .task {
            guard viewModel.state == .idle else { return }
            await viewModel.load(using: environment.listingsRepository)
            await tenancyViewModel.load(renterID: renterID, tenancyRepository: environment.tenancyRepository)
        }
    }

    private var exploreContent: some View {
        ScrollView {
            BaseraPageContainer {
                VStack(alignment: .leading, spacing: VdSpacing.md) {
                    activeTenancySection
                    favoritesSection
                }
            }
        }
    }



    @ViewBuilder
    private var activeTenancySection: some View {
        if let tenancy = tenancyViewModel.activeTenancy {
            VStack(alignment: .leading, spacing: VdSpacing.smMd) {
                HStack {
                    VStack(alignment: .leading, spacing: VdSpacing.xs) {
                        Text("Current Rental")
                            .vdFont(VdFont.titleMedium)
                            .foregroundStyle(Color.vdContentDefaultBase)
                        Text(tenancy.listingTitle)
                            .vdFont(VdFont.bodySmall)
                            .foregroundStyle(Color.vdContentDefaultSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "house.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(Color.vdContentPrimaryBase)
                }

                TenancySummaryCard(tenancy: tenancy, party: .renter)

                HStack(spacing: VdSpacing.sm) {
                    NavigationLink {
                        ActiveTenancyDetailView(
                            tenancyID: tenancy.id,
                            userID: renterID,
                            party: .renter
                        )
                    } label: {
                        tenancyActionChip(
                            title: "Details",
                            systemImage: "person.3"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        PaymentsHubView(
                            tenancy: tenancy,
                            userID: renterID,
                            actor: .renter
                        )
                    } label: {
                        tenancyActionChip(
                            title: "Payment History",
                            systemImage: "creditcard"
                        )
                    }
                    .buttonStyle(.plain)
                }

                Text("Owner contact: \(tenancy.ownerContact.fullName) • \(tenancy.ownerContact.phoneNumber)")
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary)
            }
            .padding(VdSpacing.md)
            .background(
                LinearGradient(
                    colors: [
                        Color.vdBackgroundPrimarySecondary.opacity(0.65),
                        Color.vdBackgroundDefaultSecondary
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: VdRadius.lg, style: .continuous)
                    .stroke(Color.vdBorderPrimaryBase.opacity(0.22), lineWidth: 1)
            }
        } else {
            VdAlert(tone: .info, message: "No active tenancy yet. It appears once your signed agreement is active.")
        }

        if tenancyViewModel.archivedTenancies.isEmpty == false {
            BaseraCard(backgroundColor: Color.vdBackgroundDefaultBase) {
                VStack(alignment: .leading, spacing: VdSpacing.sm) {
                    Text("Archived Tenancies")
                        .vdFont(VdFont.titleSmall)
                    ForEach(tenancyViewModel.archivedTenancies) { archived in
                        VStack(alignment: .leading, spacing: VdSpacing.sm) {
                            Text(archived.listingTitle)
                                .vdFont(VdFont.labelLarge)
                            VStack(spacing: VdSpacing.sm) {
                                NavigationLink {
                                    AgreementHubView(currentUserID: renterID, party: .renter)
                                } label: {
                                    BaseraActionTile(title: "Agreement", subtitle: nil, systemImage: "doc.richtext")
                                }
                                .buttonStyle(.plain)

                                NavigationLink {
                                    InvoiceListView(tenancy: archived, userID: renterID, actor: .renter)
                                } label: {
                                    BaseraActionTile(title: "Invoices", subtitle: nil, systemImage: "doc.text")
                                }
                                .buttonStyle(.plain)

                                NavigationLink {
                                    PaymentsHubView(tenancy: archived, userID: renterID, actor: .renter)
                                } label: {
                                    BaseraActionTile(title: "Payments", subtitle: nil, systemImage: "creditcard")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: VdSpacing.sm) {
            Text("Favorites")
                .vdFont(VdFont.titleMedium)

            if viewModel.favoriteListings.isEmpty {
                VdAlert(tone: .info, message: "You have no saved listings yet.")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: VdSpacing.sm) {
                        ForEach(viewModel.favoriteListings) { listing in
                            BaseraCard(backgroundColor: Color.vdBackgroundDefaultBase) {
                                VStack(alignment: .leading, spacing: VdSpacing.sm) {
                                    Text(listing.title)
                                        .vdFont(VdFont.labelLarge)
                                    Text(listing.approximateLocation)
                                        .vdFont(VdFont.bodySmall)
                                        .foregroundStyle(Color.vdContentDefaultSecondary)
                                    Button {
                                        viewModel.toggleFavorite(listingID: listing.id)
                                    } label: {
                                        Text("Remove")
                                            .vdFont(VdFont.bodySmall)
                                            .foregroundStyle(Color.vdContentErrorBase)
                                    }
                                }
                                .frame(width: 220, alignment: .leading)
                            }
                        }
                    }
                }
            }
        }
    }


    private func tenancyActionChip(title: String, systemImage: String) -> some View {
        HStack(spacing: VdSpacing.xs) {
            Image(systemName: systemImage)
            Text(title)
                .lineLimit(1)
        }
        .vdFont(VdFont.labelMedium)
        .foregroundStyle(Color.vdContentPrimaryBase)
        .padding(.horizontal, VdSpacing.smMd)
        .padding(.vertical, VdSpacing.sm)
        .frame(maxWidth: .infinity)
        .background(Color.vdBackgroundDefaultBase)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                .stroke(Color.vdBorderDefaultSecondary, lineWidth: 1)
        }
    }
}

#Preview {
    RenterDashboardView()
        .environmentObject(AppEnvironment.bootstrap())
}
