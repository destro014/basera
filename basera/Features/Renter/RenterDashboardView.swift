import SwiftUI

struct RenterDashboardView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = RenterDashboardViewModel()

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    BaseraLoadingView(message: "Finding rentals for you")
                case .error(let message):
                    BaseraErrorStateView(title: "Unable to load Explore", message: message) {
                        Task { await viewModel.retry(using: environment.listingsRepository) }
                    }
                case .loaded:
                    exploreContent
                }
            }
            .navigationTitle("Explore")
            .task {
                guard viewModel.state == .idle else { return }
                await viewModel.load(using: environment.listingsRepository)
            }
        }
    }

    private var exploreContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                searchAndFilters
                favoritesSection
                listingModePicker
                resultsSection
            }
            .padding()
        }
    }

    private var searchAndFilters: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                TextField("Search by area or title", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    Text("Price Range (NPR \\(Int(viewModel.filters.minPrice)) - \\(Int(viewModel.filters.maxPrice)))")
                        .font(AppTheme.Typography.caption)
                    HStack {
                        Slider(value: $viewModel.filters.minPrice, in: 8_000...50_000, step: 1_000)
                        Slider(value: $viewModel.filters.maxPrice, in: 8_000...50_000, step: 1_000)
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.small) {
                        ForEach(Listing.PropertyType.allCases) { type in
                            filterChip(
                                title: type.rawValue,
                                isSelected: viewModel.filters.selectedPropertyTypes.contains(type)
                            ) {
                                if viewModel.filters.selectedPropertyTypes.contains(type) {
                                    viewModel.filters.selectedPropertyTypes.remove(type)
                                } else {
                                    viewModel.filters.selectedPropertyTypes.insert(type)
                                }
                            }
                        }
                    }
                }

                Toggle("Parking required", isOn: $viewModel.filters.parkingRequired)
                Toggle("Wi-Fi required", isOn: $viewModel.filters.wifiRequired)
                Toggle("Pet allowed only", isOn: $viewModel.filters.petsAllowedOnly)

                Picker("Furnishing", selection: $viewModel.filters.furnishing) {
                    Text("Any").tag(Optional<Listing.Furnishing>.none)
                    ForEach(Listing.Furnishing.allCases) { furnishing in
                        Text(furnishing.rawValue).tag(Optional(furnishing))
                    }
                }
                .pickerStyle(.segmented)

                Picker("Tenant Preference", selection: $viewModel.filters.tenantPreference) {
                    Text("Any").tag(Optional<Listing.TenantPreference>.none)
                    ForEach(Listing.TenantPreference.allCases) { pref in
                        Text(pref.rawValue).tag(Optional(pref))
                    }
                }

                Stepper("Location radius: \\(viewModel.filters.maximumRadiusInKM) KM", value: $viewModel.filters.maximumRadiusInKM, in: 1...12)
                DatePicker("Available by", selection: $viewModel.filters.availableFrom, displayedComponents: .date)

                Group {
                    Toggle("Electricity included", isOn: $viewModel.filters.includeElectricity)
                    Toggle("Water included", isOn: $viewModel.filters.includeWater)
                    Toggle("Internet included", isOn: $viewModel.filters.includeInternet)
                }
            }
        }
    }

    private var listingModePicker: some View {
        Picker("Mode", selection: $viewModel.discoveryMode) {
            ForEach(RenterDashboardViewModel.DiscoveryMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder
    private var resultsSection: some View {
        if viewModel.filteredListings.isEmpty {
            if viewModel.hasAppliedFilters || !viewModel.searchText.isEmpty {
                BaseraEmptyStateView(title: "No results", message: "Try adjusting search and filters.")
            } else {
                BaseraEmptyStateView(title: "No listings", message: "There are no listings available right now.")
            }
        } else {
            switch viewModel.discoveryMode {
            case .list:
                listingsGrid
            case .map:
                mapPlaceholderView
            }
        }
    }

    private var listingsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: AppTheme.Spacing.medium)], spacing: AppTheme.Spacing.medium) {
            ForEach(viewModel.filteredListings) { listing in
                NavigationLink {
                    ListingDetailView(
                        listing: listing,
                        similarListings: viewModel.similarListings(for: listing),
                        isFavorite: viewModel.isFavorite(listingID: listing.id),
                        interestState: viewModel.interestState(for: listing.id),
                        onFavoriteTapped: { viewModel.toggleFavorite(listingID: listing.id) },
                        onInterestedTapped: { viewModel.sendInterest(for: listing.id) }
                    )
                } label: {
                    listingCard(for: listing)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var mapPlaceholderView: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Label("Map integration placeholder", systemImage: "map")
                    .font(AppTheme.Typography.subtitle)
                Text("Showing approximate pins only. Exact address remains hidden until owner approval.")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                ForEach(viewModel.filteredListings.prefix(5)) { listing in
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text("\(listing.approximateLocation) • Rs. \(listing.monthlyRent)")
                            .font(AppTheme.Typography.body)
                    }
                }
            }
        }
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text("Favorites")
                .font(AppTheme.Typography.subtitle)

            if viewModel.favoriteListings.isEmpty {
                BaseraInlineMessageView(tone: .info, message: "You have no saved listings yet.")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.small) {
                        ForEach(viewModel.favoriteListings) { listing in
                            BaseraCard {
                                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                                    Text(listing.title)
                                        .font(AppTheme.Typography.caption.weight(.semibold))
                                    Text(listing.approximateLocation)
                                        .font(AppTheme.Typography.caption)
                                        .foregroundStyle(AppTheme.Colors.textSecondary)
                                    Button("Remove") {
                                        viewModel.toggleFavorite(listingID: listing.id)
                                    }
                                    .font(AppTheme.Typography.caption)
                                }
                                .frame(width: 220, alignment: .leading)
                            }
                        }
                    }
                }
            }
        }
    }

    private func listingCard(for listing: Listing) -> some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                HStack {
                    Text(listing.title)
                        .font(AppTheme.Typography.subtitle)
                    Spacer()
                    Button {
                        viewModel.toggleFavorite(listingID: listing.id)
                    } label: {
                        Image(systemName: viewModel.isFavorite(listingID: listing.id) ? "heart.fill" : "heart")
                            .foregroundStyle(AppTheme.Colors.danger)
                    }
                }

                Text(listing.approximateLocation)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                HStack {
                    BaseraChip(text: listing.propertyType.rawValue)
                    BaseraChip(text: "Rs. \(listing.monthlyRent)/month")
                }
                Text("Approximate location only")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.caption)
                .padding(.horizontal, AppTheme.Spacing.medium)
                .padding(.vertical, AppTheme.Spacing.small)
                .background(isSelected ? AppTheme.Colors.brandPrimary : AppTheme.Colors.surface)
                .foregroundStyle(isSelected ? AppTheme.Colors.onPrimary : AppTheme.Colors.textPrimary)
                .clipShape(Capsule())
        }
    }
}

private struct ListingDetailView: View {
    let listing: Listing
    let similarListings: [Listing]
    let isFavorite: Bool
    let interestState: Listing.InterestState
    let onFavoriteTapped: () -> Void
    let onInterestedTapped: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                gallerySection
                summarySection
                amenitiesSection
                similarSection
            }
            .padding()
        }
        .navigationTitle("Listing Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var gallerySection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.medium) {
                ForEach(listing.media) { media in
                    BaseraCard {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                            Image(systemName: media.systemImageName)
                                .font(.system(size: 28))
                            Text(media.title)
                                .font(AppTheme.Typography.body.weight(.semibold))
                            Text(media.subtitle)
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                            if media.kind == .videoPreview {
                                BaseraChip(text: "Video Preview")
                            }
                        }
                        .frame(width: 200, alignment: .leading)
                    }
                }
            }
        }
    }

    private var summarySection: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text(listing.title)
                    .font(AppTheme.Typography.title)
                Text(listing.description)
                Text("Approximate location: \(listing.approximateLocation)")
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text(listing.exactAddressMasked)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text("Rs. \(listing.monthlyRent)/month")
                    .font(AppTheme.Typography.subtitle)

                HStack {
                    BaseraButton(title: isFavorite ? "Saved" : "Save", style: .secondary, action: onFavoriteTapped)
                    BaseraButton(
                        title: interestState.label,
                        style: .primary,
                        isDisabled: interestState != .none,
                        action: onInterestedTapped
                    )
                }
                if interestState != .none {
                    BaseraInlineMessageView(tone: .info, message: "Interest already sent. We'll notify you when the owner responds.")
                }
            }
        }
    }

    private var amenitiesSection: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text("Amenities & Rules")
                    .font(AppTheme.Typography.subtitle)
                Text("• Furnishing: \(listing.furnishing.rawValue)")
                Text("• Parking: \(listing.parkingAvailable ? "Available" : "Not available")")
                Text("• Wi-Fi: \(listing.wifiAvailable ? "Available" : "Not available")")
                Text("• Pets: \(listing.petAllowed ? "Allowed" : "Not allowed")")
                Text("• Tenant preference: \(listing.tenantPreference.rawValue)")
            }
        }
    }

    private var similarSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text("Similar Listings")
                .font(AppTheme.Typography.subtitle)

            if similarListings.isEmpty {
                BaseraInlineMessageView(tone: .info, message: "No similar listings available yet.")
            } else {
                ForEach(similarListings) { listing in
                    BaseraCard {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                            Text(listing.title)
                            Text("\(listing.approximateLocation) • Rs. \(listing.monthlyRent)")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    RenterDashboardView()
        .environmentObject(AppEnvironment.bootstrap())
}
