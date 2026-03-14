import SwiftUI

struct MyListingsView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = MyListingsViewModel()

    let ownerID: String

    @State private var isPresentingCreate = false
    @State private var editingListing: Listing?
    @State private var previewListing: Listing?

    var body: some View {
        BaseraPageContainer {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    BaseraLoadingView(message: "Loading your listings")
                case .error(let message):
                    BaseraErrorStateView(title: "My Listings", message: message) {
                        Task { await reload() }
                    }
                case .loaded:
                    content
                }
            }
        }
        .navigationTitle("My Listings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingCreate = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            guard viewModel.state == .idle else { return }
            await reload()
        }
        .alert("Listings", isPresented: operationAlertIsPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.operationErrorMessage ?? "")
        }
        .sheet(isPresented: $isPresentingCreate) {
            NavigationStack {
                ListingEditorView(ownerID: ownerID) { listing in
                    Task {
                        if await viewModel.save(listing: listing, repository: environment.listingsRepository) {
                            await reload()
                        }
                    }
                }
            }
        }
        .sheet(item: $editingListing) { listing in
            NavigationStack {
                ListingEditorView(ownerID: ownerID, listing: listing) { updated in
                    Task {
                        if await viewModel.save(listing: updated, repository: environment.listingsRepository) {
                            await reload()
                        }
                    }
                }
            }
        }
        .sheet(item: $previewListing) { listing in
            NavigationStack {
                ListingPreviewView(listing: listing)
            }
        }
    }

    private var content: some View {
        Group {
            if viewModel.listings.isEmpty {
                BaseraEmptyStateView(
                    title: "No listings yet",
                    message: "Create your first room, flat, or apartment listing.",
                    systemImage: "building.2.crop.circle",
                    actionTitle: "Create Listing",
                    action: { isPresentingCreate = true }
                )
            } else {
                List(viewModel.listings) { listing in
                    BaseraCard {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                            HStack {
                                Text(listing.title)
                                    .baseraTextStyle(AppTheme.Typography.titleMedium)
                                Spacer()
                                statusBadge(for: listing.status)
                            }
                            Text("\(listing.propertyType.rawValue) • \(listing.listingScope.rawValue)")
                                .baseraTextStyle(AppTheme.Typography.bodySmall)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                            Text("Public area: \(listing.approximateLocation)")
                                .baseraTextStyle(AppTheme.Typography.bodySmall)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                            Text("NPR \(listing.monthlyRent)/month")
                                .baseraTextStyle(AppTheme.Typography.labelLarge)

                            HStack {
                                actionButton("Preview") { previewListing = listing }
                                actionButton("Edit") { editingListing = listing }
                                actionButton("Pause") {
                                    Task {
                                        if await viewModel.pause(listing: listing, repository: environment.listingsRepository) {
                                            await reload()
                                        }
                                    }
                                }
                                actionButton("Duplicate") {
                                    Task {
                                        if await viewModel.duplicate(listing: listing, repository: environment.listingsRepository) {
                                            await reload()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
        }
    }

    private func statusBadge(for status: Listing.Status) -> some View {
        BaseraBadge(text: status.label, tone: statusTone(for: status))
    }

    private func statusTone(for status: Listing.Status) -> Color {
        switch status {
        case .draft, .agreementPending: AppTheme.Colors.warningPrimary
        case .active, .occupied: AppTheme.Colors.successPrimary
        case .paused: AppTheme.Colors.infoPrimary
        case .assigned: AppTheme.Colors.brandPrimary
        }
    }

    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .buttonStyle(.bordered)
            .font(.caption)
    }

    private func reload() async {
        await viewModel.load(ownerID: ownerID, repository: environment.listingsRepository)
    }

    private var operationAlertIsPresented: Binding<Bool> {
        Binding(
            get: { viewModel.operationErrorMessage != nil },
            set: { isPresented in
                if isPresented == false {
                    viewModel.operationErrorMessage = nil
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        MyListingsView(ownerID: "preview-user-001")
            .environmentObject(AppEnvironment.bootstrap())
    }
}


#Preview("iPad") {
    NavigationStack {
        MyListingsView(ownerID: "preview-user-001")
            .frame(width: 1024, height: 768)
            .environmentObject(AppEnvironment.bootstrap())
    }
}
