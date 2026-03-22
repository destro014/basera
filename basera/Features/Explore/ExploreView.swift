import SwiftUI
import VroxalDesign

struct ExploreView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = ExploreViewModel()
    @State private var isFilterSheetPresented = false

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                VdLoadingState(title: "Loading explore feed")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            case .error(let message):
                VdAlert(title: "Explore unavailable", message: message) {
                    Task {
                        await viewModel.retry(using: environment.listingsRepository)
                    }
                }
            case .loaded:
                content
            }
        }
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.large)
        .task {
            guard viewModel.state == .idle else { return }
            await viewModel.load(using: environment.listingsRepository)
        }
        .baseraScreenBackground()
        .sheet(isPresented: $isFilterSheetPresented) {
            NavigationStack {
                ScrollView {
                    filterControls
                        .padding()
                }
                .navigationTitle("Filters")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Reset") {
                            viewModel.resetFilters()
                        }
                    }
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
    }
    

    private var content: some View {
        ScrollView {
            BaseraPageContainer {
                VStack(alignment: .leading, spacing: VdSpacing.md) {
                    titleCard
                    searchAndFiltersRow
                    categorySection
                    listingsSection(
                        title: "Recently Posted",
                        subtitle: "Fresh listings with upcoming availability.",
                        listings: viewModel.recentListings
                    )
                    listingsSection(
                        title: "Popular Listings",
                        subtitle: "Homes with strong amenities and value.",
                        listings: viewModel.popularListings
                    )
                    listingsSection(
                        title: "Listings Near You",
                        subtitle: "Options prioritized by nearby coverage radius.",
                        listings: viewModel.nearbyListings
                    )
                    discoveryModePicker
                    browseResultsSection
                }
            }
        }
    }

    private var titleCard: some View {
        BaseraCard(backgroundColor: Color.vdBackgroundDefaultSecondary) {
            VStack(alignment: .leading, spacing: VdSpacing.sm) {
                Text("Find Your Next Rental")
                    .vdFont(VdFont.titleLarge)
                    .foregroundStyle(Color.vdContentDefaultBase)
                Text("Search smarter with curated listings by recency, popularity, and nearby location.")
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary)
            }
        }
    }

    private var searchAndFiltersRow: some View {
        HStack(spacing: VdSpacing.sm) {
            VdTextField(
                "Search Listings",
                text: $viewModel.searchText,
                placeholder: "Search by area, title, or keywords",
                leadingIcon: "magnifyingglass"
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)

            Button {
                isFilterSheetPresented = true
            } label: {
                VStack(spacing: VdSpacing.xs) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 20, weight: .semibold))
                    Text("Filter")
                        .vdFont(VdFont.labelSmall)
                }
                .foregroundStyle(Color.vdContentPrimaryBase)
                .frame(width: 64, height: 56)
                .background(Color.vdBackgroundDefaultSecondary)
                .clipShape(RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                        .stroke(Color.vdBorderDefaultSecondary, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var filterControls: some View {
        VStack(alignment: .leading, spacing: VdSpacing.smMd) {
            VStack(alignment: .leading, spacing: VdSpacing.sm) {
                Text("Price Range (NPR \(Int(viewModel.filters.minPrice)) - \(Int(viewModel.filters.maxPrice)))")
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary)

                HStack {
                    Slider(value: $viewModel.filters.minPrice, in: 8_000...50_000, step: 1_000)
                        .tint(Color.vdContentPrimaryBase)
                    Slider(value: $viewModel.filters.maxPrice, in: 8_000...50_000, step: 1_000)
                        .tint(Color.vdContentPrimaryBase)
                }
            }

            Toggle(isOn: $viewModel.filters.parkingRequired) {
                Text("Parking required")
                    .vdFont(VdFont.bodyLarge)
            }
            .tint(Color.vdContentPrimaryBase)

            Toggle(isOn: $viewModel.filters.wifiRequired) {
                Text("Wi-Fi required")
                    .vdFont(VdFont.bodyLarge)
            }
            .tint(Color.vdContentPrimaryBase)

            Toggle(isOn: $viewModel.filters.petsAllowedOnly) {
                Text("Pet friendly only")
                    .vdFont(VdFont.bodyLarge)
            }
            .tint(Color.vdContentPrimaryBase)

            Picker(selection: $viewModel.filters.tenantPreference) {
                Text("Any").tag(Optional<Listing.TenantPreference>.none)
                ForEach(Listing.TenantPreference.allCases) { preference in
                    Text(preference.rawValue).tag(Optional(preference))
                }
            } label: {
                Text("Tenant Preference")
                    .vdFont(VdFont.labelLarge)
            }
            .pickerStyle(.segmented)
            .tint(Color.vdContentPrimaryBase)

            Stepper(value: $viewModel.filters.maximumRadiusInKM, in: 1...12) {
                Text("Location radius: \(viewModel.filters.maximumRadiusInKM) KM")
                    .vdFont(VdFont.bodyLarge)
            }
            .tint(Color.vdContentPrimaryBase)

            DatePicker(selection: $viewModel.filters.availableFrom, displayedComponents: .date) {
                Text("Available by")
                    .vdFont(VdFont.labelLarge)
            }
            .tint(Color.vdContentPrimaryBase)
        }
    }

    private var discoveryModePicker: some View {
        Picker(selection: $viewModel.discoveryMode) {
            ForEach(ExploreViewModel.DiscoveryMode.allCases) { mode in
                Text(mode.rawValue)
                    .vdFont(VdFont.labelMedium)
                    .tag(mode)
            }
        } label: {
            Text("Browse Mode")
                .vdFont(VdFont.titleMedium)
        }
        .pickerStyle(.segmented)
        .tint(Color.vdContentPrimaryBase)
    }

    @ViewBuilder
    private var browseResultsSection: some View {
        VStack(alignment: .leading, spacing: VdSpacing.sm) {
            Text("Browse Results")
                .vdFont(VdFont.titleMedium)
                .foregroundStyle(Color.vdContentDefaultBase)

            if viewModel.filteredListings.isEmpty {
                if viewModel.hasAppliedFilters || !viewModel.searchText.isEmpty {
                    VdEmptyState(
                        title: "No results",
                        message: "Try broadening your search or filters.",
                        systemImage: "magnifyingglass"
                    )
                } else {
                    VdEmptyState(
                        title: "No listings",
                        message: "No listings available right now.",
                        systemImage: "house"
                    )
                }
            } else {
                switch viewModel.discoveryMode {
                case .list:
                    LazyVStack(spacing: VdSpacing.smMd) {
                        ForEach(viewModel.filteredListings) { listing in
                            ExploreListingRowCard(listing: listing)
                        }
                    }
                case .map:
                    mapPlaceholder
                }
            }
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: VdSpacing.sm) {
            Text("Categories")
                .vdFont(VdFont.titleMedium)
                .foregroundStyle(Color.vdContentDefaultBase)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: VdSpacing.sm) {
                    categoryPill(
                        title: "All",
                        isSelected: viewModel.selectedCategory == nil
                    ) {
                        viewModel.selectedCategory = nil
                    }

                    ForEach(ExploreViewModel.Category.allCases) { category in
                        categoryPill(
                            title: category.rawValue,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            viewModel.toggleCategory(category)
                        }
                    }
                }
                .padding(.vertical, VdSpacing.xs)
            }
        }
    }

    @ViewBuilder
    private func listingsSection(
        title: String,
        subtitle: String,
        listings: [Listing]
    ) -> some View {
        VStack(alignment: .leading, spacing: VdSpacing.sm) {
            Text(title)
                .vdFont(VdFont.titleMedium)
                .foregroundStyle(Color.vdContentDefaultBase)
            Text(subtitle)
                .vdFont(VdFont.bodySmall)
                .foregroundStyle(Color.vdContentDefaultSecondary)

            if listings.isEmpty {
                VdEmptyState(
                    title: "No matching listings",
                    message: "Try another category or a different search term.",
                    systemImage: "magnifyingglass"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: VdSpacing.smMd) {
                        ForEach(listings) { listing in
                            ExploreListingCard(listing: listing)
                        }
                    }
                    .padding(.vertical, VdSpacing.xs)
                }
            }
        }
    }

    private func categoryPill(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .vdFont(VdFont.bodySmall)
                .foregroundStyle(
                    isSelected
                        ? Color.vdContentPrimaryOnBase
                        : Color.vdContentDefaultBase
                )
                .padding(.horizontal, VdSpacing.smMd)
                .padding(.vertical, VdSpacing.sm)
                .background(
                    isSelected
                        ? Color.vdBackgroundPrimaryBase
                        : Color.vdBackgroundDefaultSecondary
                )
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(
                            isSelected
                                ? Color.clear
                                : Color.vdBorderDefaultSecondary,
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
    }

    private var mapPlaceholder: some View {
        BaseraCard(backgroundColor: Color.vdBackgroundDefaultSecondary) {
            VStack(alignment: .leading, spacing: VdSpacing.sm) {
                Label("Map Preview", systemImage: "map")
                    .vdFont(VdFont.titleMedium)
                Text("Exact addresses stay hidden until owner approval. These are approximate pins.")
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary)

                ForEach(viewModel.filteredListings.prefix(6)) { listing in
                    HStack(spacing: VdSpacing.xs) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(Color.vdContentPrimaryBase)
                        Text("\(listing.approximateLocation) • NPR \(listing.monthlyRent.formatted(.number))")
                            .vdFont(VdFont.bodyMedium)
                            .foregroundStyle(Color.vdContentDefaultBase)
                    }
                }
            }
        }
    }
}

private struct ExploreListingCard: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: VdSpacing.sm) {
            HStack {
                Text(listing.propertyType.rawValue)
                    .vdFont(VdFont.labelSmall)
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, VdSpacing.sm)
                    .padding(.vertical, VdSpacing.xs)
                    .background(accentColor.opacity(0.14))
                    .clipShape(Capsule())

                Spacer()

                Image(systemName: "sparkles")
                    .foregroundStyle(accentColor)
            }

            Text(listing.title)
                .vdFont(VdFont.titleMedium)
                .foregroundStyle(Color.vdContentDefaultBase)
                .lineLimit(2)

            HStack(spacing: VdSpacing.xs) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(Color.vdContentPrimaryBase)
                Text(listing.approximateLocation)
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary)
                    .lineLimit(1)
            }

            HStack(spacing: VdSpacing.xs) {
                metadataPill(text: "NPR \(formattedRent)", tone: Color.vdContentPrimaryBase)
                metadataPill(text: "\(listing.bedroomCount) room", tone: Color.vdContentSuccessBase)
                metadataPill(text: "\(listing.locationRadiusInKM) KM", tone: Color.vdContentInfoBase)
            }
        }
        .padding(VdSpacing.md)
        .frame(width: 286, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: VdRadius.lg, style: .continuous)
                .fill(Color.vdBackgroundDefaultSecondary)
                .overlay {
                    LinearGradient(
                        colors: [
                            accentColor.opacity(0.18),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: VdRadius.lg, style: .continuous)
                    )
                }
        )
        .overlay {
            RoundedRectangle(cornerRadius: VdRadius.lg, style: .continuous)
                .stroke(accentColor.opacity(0.30), lineWidth: 1)
        }
    }

    private var accentColor: Color {
        switch listing.propertyType {
        case .room: return Color.vdContentInfoBase
        case .flat: return Color.vdContentPrimaryBase
        case .apartment: return Color.vdContentSuccessBase
        }
    }

    private var formattedRent: String {
        listing.monthlyRent.formatted(.number)
    }

    private func metadataPill(text: String, tone: Color) -> some View {
        Text(text)
            .vdFont(VdFont.labelSmall)
            .foregroundStyle(tone)
            .padding(.horizontal, VdSpacing.sm)
            .padding(.vertical, VdSpacing.xs)
            .background(tone.opacity(0.14))
            .clipShape(Capsule())
    }
}

private struct ExploreListingRowCard: View {
    let listing: Listing

    var body: some View {
        BaseraCard(backgroundColor: Color.vdBackgroundDefaultSecondary) {
            VStack(alignment: .leading, spacing: VdSpacing.sm) {
                HStack {
                    Text(listing.title)
                        .vdFont(VdFont.titleMedium)
                    Spacer()
                    Text("NPR \(listing.monthlyRent.formatted(.number))/month")
                        .vdFont(VdFont.labelLarge)
                        .foregroundStyle(Color.vdContentPrimaryBase)
                }

                Text(listing.approximateLocation)
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary)

                HStack(spacing: VdSpacing.xs) {
                    BaseraChip(text: listing.propertyType.rawValue)
                    BaseraChip(text: "\(listing.bedroomCount) room")
                    BaseraChip(text: "\(listing.locationRadiusInKM) KM")
                }
            }
        }
    }
}

#Preview("iPhone") {
    NavigationStack {
        ExploreView()
    }
    .environmentObject(AppEnvironment.bootstrap())
}

#Preview("iPad") {
    NavigationStack {
        ExploreView()
    }
    .frame(width: 1024, height: 768)
    .environmentObject(AppEnvironment.bootstrap())
}
