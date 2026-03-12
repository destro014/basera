import SwiftUI

struct RenterDashboardView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = RenterDashboardViewModel()
    @State private var isFilterSheetPresented = false
    @State private var selectedListingForInterest: Listing?
    @StateObject private var tenancyViewModel = RenterActiveTenancyViewModel()

    var body: some View {
        NavigationView {
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
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("logo-horizontal")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160)
                        .accessibilityHidden(true)
                }
            }
            .sheet(isPresented: $isFilterSheetPresented) {
                NavigationView {
                    ScrollView {
                        filterControls
                            .padding()
                    }
                    .navigationTitle("Filters")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                isFilterSheetPresented = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .task {
                guard viewModel.state == .idle else { return }
                await viewModel.load(using: environment.listingsRepository)
                await viewModel.refreshInterestStates(renterID: "preview-user-001", using: environment.interestsRepository)
                await tenancyViewModel.load(renterID: "preview-user-001", tenancyRepository: environment.tenancyRepository)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $selectedListingForInterest) { listing in
            NavigationView {
                InterestSubmissionView(
                    listing: listing,
                    renterID: "preview-user-001",
                    renterSnapshot: .init(renterID: "preview-user-001", fullName: "Sita Basera", occupation: "Software Engineer", familySize: 3, hasPets: false, smokingStatus: "Non-smoker")
                )
            }
            .environmentObject(environment)
        }
    }

    private var exploreContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                searchAndFilters
                activeTenancySection
                renterWorkflowLinks
                favoritesSection
                listingModePicker
                resultsSection
            }
            .padding()
        }
    }

    private var searchAndFilters: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            BaseraCard {
                TextField("Search by area or title", text: $viewModel.searchText)
                    .baseraTextStyle(AppTheme.Typography.bodyLarge)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .tint(AppTheme.Colors.brandPrimary)
                    .padding(.horizontal, AppTheme.Spacing.small)
            }

            Button {
                isFilterSheetPresented = true
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.brandPrimary)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.Colors.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                            .stroke(AppTheme.Colors.borderSecondary, lineWidth: 1)
                    }
            }
        }
    }

    private var filterControls: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text("Price Range (NPR \(Int(viewModel.filters.minPrice)) - \(Int(viewModel.filters.maxPrice)))")
                    .baseraTextStyle(AppTheme.Typography.bodySmall)
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                HStack {
                    Slider(value: $viewModel.filters.minPrice, in: 8_000...50_000, step: 1_000)
                        .tint(AppTheme.Colors.brandPrimary)
                    Slider(value: $viewModel.filters.maxPrice, in: 8_000...50_000, step: 1_000)
                        .tint(AppTheme.Colors.brandPrimary)
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

            dashboardToggle(title: "Parking required", isOn: $viewModel.filters.parkingRequired)
            dashboardToggle(title: "Wi-Fi required", isOn: $viewModel.filters.wifiRequired)
            dashboardToggle(title: "Pet allowed only", isOn: $viewModel.filters.petsAllowedOnly)

            Picker(selection: $viewModel.filters.furnishing) {
                segmentedOption("Any").tag(Optional<Listing.Furnishing>.none)
                ForEach(Listing.Furnishing.allCases) { furnishing in
                    segmentedOption(furnishing.rawValue).tag(Optional(furnishing))
                }
            } label: {
                controlLabel("Furnishing")
            }
            .pickerStyle(.segmented)
            .tint(AppTheme.Colors.brandPrimary)

            Picker(selection: $viewModel.filters.tenantPreference) {
                segmentedOption("Any").tag(Optional<Listing.TenantPreference>.none)
                ForEach(Listing.TenantPreference.allCases) { preference in
                    segmentedOption(preference.rawValue).tag(Optional(preference))
                }
            } label: {
                controlLabel("Tenant Preference")
            }
            .tint(AppTheme.Colors.brandPrimary)

            Stepper(value: $viewModel.filters.maximumRadiusInKM, in: 1...12) {
                Text("Location radius: \(viewModel.filters.maximumRadiusInKM) KM")
                    .baseraTextStyle(AppTheme.Typography.bodyLarge)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }
            .tint(AppTheme.Colors.brandPrimary)

            DatePicker(selection: $viewModel.filters.availableFrom, displayedComponents: .date) {
                controlLabel("Available by")
            }
            .tint(AppTheme.Colors.brandPrimary)

            Group {
                dashboardToggle(title: "Electricity included", isOn: $viewModel.filters.includeElectricity)
                dashboardToggle(title: "Water included", isOn: $viewModel.filters.includeWater)
                dashboardToggle(title: "Internet included", isOn: $viewModel.filters.includeInternet)
            }
        }
    }

    private var listingModePicker: some View {
        Picker(selection: $viewModel.discoveryMode) {
            ForEach(RenterDashboardViewModel.DiscoveryMode.allCases) { mode in
                segmentedOption(mode.rawValue).tag(mode)
            }
        } label: {
            controlLabel("Mode")
        }
        .pickerStyle(.segmented)
        .tint(AppTheme.Colors.brandPrimary)
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



    @ViewBuilder
    private var activeTenancySection: some View {
        if let tenancy = tenancyViewModel.activeTenancy {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text("Active Tenancy")
                    .baseraTextStyle(AppTheme.Typography.titleMedium)
                TenancySummaryCard(tenancy: tenancy, party: .renter)
                HStack {
                    NavigationLink("Open tenancy details") {
                        ActiveTenancyDetailView(tenancyID: tenancy.id, userID: "preview-user-001", party: .renter)
                    }
                    NavigationLink("Payment history") {
                        PaymentsHubView(tenancy: tenancy, userID: "preview-user-001", actor: .renter)
                    }
                }
                Text("Owner contact: \(tenancy.ownerContact.fullName) • \(tenancy.ownerContact.phoneNumber)")
                    .baseraTextStyle(AppTheme.Typography.bodySmall)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        } else {
            BaseraInlineMessageView(tone: .info, message: "No active tenancy yet. It appears once your signed agreement is active.")
        }

        if tenancyViewModel.archivedTenancies.isEmpty == false {
            BaseraCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    Text("Archived Tenancies")
                        .baseraTextStyle(AppTheme.Typography.titleSmall)
                    Text("Archive access placeholder for post move-out agreements, invoices, and payment history.")
                        .baseraTextStyle(AppTheme.Typography.bodySmall)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
        }
    }

    private var renterWorkflowLinks: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            HStack {
                NavigationLink("My Interest Requests") {
                    RenterInterestsView(renterID: "preview-user-001")
                }
                NavigationLink("Conversations") {
                    ConversationListView(userID: "preview-user-001")
                }
            }
            NavigationLink("My Agreement") {
                AgreementHubView(currentUserID: "preview-user-001", party: .renter)
            }
            NavigationLink("Reviews & Rating") {
                ReviewHubView(userID: "preview-user-001", role: .renter)
            }
        }
        .baseraTextStyle(AppTheme.Typography.bodyMedium)
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
                        onInterestedTapped: { selectedListingForInterest = listing }
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
                    .baseraTextStyle(AppTheme.Typography.titleMedium)

                Text("Showing approximate pins only. Exact address remains hidden until owner approval.")
                    .baseraTextStyle(AppTheme.Typography.bodySmall)
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                ForEach(viewModel.filteredListings.prefix(5)) { listing in
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(AppTheme.Colors.brandPrimary)
                        Text("\(listing.approximateLocation) • Rs. \(listing.monthlyRent)")
                            .baseraTextStyle(AppTheme.Typography.bodyLarge)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                    }
                }
            }
        }
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text("Favorites")
                .baseraTextStyle(AppTheme.Typography.titleMedium)

            if viewModel.favoriteListings.isEmpty {
                BaseraInlineMessageView(tone: .info, message: "You have no saved listings yet.")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.small) {
                        ForEach(viewModel.favoriteListings) { listing in
                            BaseraCard {
                                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                                    Text(listing.title)
                                        .baseraTextStyle(AppTheme.Typography.labelLarge)
                                    Text(listing.approximateLocation)
                                        .baseraTextStyle(AppTheme.Typography.bodySmall)
                                        .foregroundStyle(AppTheme.Colors.textSecondary)
                                    Button {
                                        viewModel.toggleFavorite(listingID: listing.id)
                                    } label: {
                                        Text("Remove")
                                            .baseraTextStyle(AppTheme.Typography.bodySmall)
                                            .foregroundStyle(AppTheme.Colors.errorPrimary)
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


    private func listingCard(for listing: Listing) -> some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                HStack {
                    Text(listing.title)
                        .baseraTextStyle(AppTheme.Typography.titleMedium)

                    Spacer()

                    Button {
                        viewModel.toggleFavorite(listingID: listing.id)
                    } label: {
                        Image(systemName: viewModel.isFavorite(listingID: listing.id) ? "heart.fill" : "heart")
                            .foregroundStyle(AppTheme.Colors.errorPrimary)
                    }
                }

                Text(listing.approximateLocation)
                    .baseraTextStyle(AppTheme.Typography.bodyMedium)
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                HStack {
                    BaseraChip(text: listing.propertyType.rawValue)
                    BaseraChip(text: "Rs. \(listing.monthlyRent)/month")
                }

                Text("Approximate location only")
                    .baseraTextStyle(AppTheme.Typography.bodySmall)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .baseraTextStyle(AppTheme.Typography.bodySmall)
                .padding(.horizontal, AppTheme.Spacing.medium)
                .padding(.vertical, AppTheme.Spacing.small)
                .background(isSelected ? AppTheme.Colors.brandPrimary : AppTheme.Colors.surfacePrimary)
                .foregroundStyle(isSelected ? AppTheme.Colors.brandOnPrimary : AppTheme.Colors.textPrimary)
                .clipShape(Capsule())
        }
    }

    private func controlLabel(_ title: String) -> some View {
        Text(title)
            .baseraTextStyle(AppTheme.Typography.labelLarge)
            .foregroundStyle(AppTheme.Colors.textPrimary)
    }

    private func segmentedOption(_ title: String) -> some View {
        Text(title)
            .baseraTextStyle(AppTheme.Typography.labelMedium)
    }

    private func dashboardToggle(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .baseraTextStyle(AppTheme.Typography.bodyLarge)
                .foregroundStyle(AppTheme.Colors.textPrimary)
        }
        .tint(AppTheme.Colors.brandPrimary)
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
                                .foregroundStyle(AppTheme.Colors.brandPrimary)
                            Text(media.title)
                                .baseraTextStyle(AppTheme.Typography.titleMedium)
                            Text(media.subtitle)
                                .baseraTextStyle(AppTheme.Typography.bodySmall)
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
                    .baseraTextStyle(AppTheme.Typography.titleLarge)
                Text(listing.description)
                    .baseraTextStyle(AppTheme.Typography.bodyLarge)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("Approximate location: \(listing.approximateLocation)")
                    .baseraTextStyle(AppTheme.Typography.bodyMedium)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text(listing.exactAddressMasked)
                    .baseraTextStyle(AppTheme.Typography.bodySmall)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text("Rs. \(listing.monthlyRent)/month")
                    .baseraTextStyle(AppTheme.Typography.titleMedium)

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
                    .baseraTextStyle(AppTheme.Typography.titleMedium)
                Text("• Furnishing: \(listing.furnishing.rawValue)")
                    .baseraTextStyle(AppTheme.Typography.bodyMedium)
                Text("• Parking: \(listing.parkingAvailable ? "Available" : "Not available")")
                    .baseraTextStyle(AppTheme.Typography.bodyMedium)
                Text("• Wi-Fi: \(listing.wifiAvailable ? "Available" : "Not available")")
                    .baseraTextStyle(AppTheme.Typography.bodyMedium)
                Text("• Pets: \(listing.petAllowed ? "Allowed" : "Not allowed")")
                    .baseraTextStyle(AppTheme.Typography.bodyMedium)
                Text("• Tenant preference: \(listing.tenantPreference.rawValue)")
                    .baseraTextStyle(AppTheme.Typography.bodyMedium)
            }
        }
    }

    private var similarSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text("Similar Listings")
                .baseraTextStyle(AppTheme.Typography.titleMedium)

            if similarListings.isEmpty {
                BaseraInlineMessageView(tone: .info, message: "No similar listings available yet.")
            } else {
                ForEach(similarListings) { similarListing in
                    BaseraCard {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                            Text(similarListing.title)
                                .baseraTextStyle(AppTheme.Typography.titleSmall)
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                            Text("\(similarListing.approximateLocation) • Rs. \(similarListing.monthlyRent)")
                                .baseraTextStyle(AppTheme.Typography.bodySmall)
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
