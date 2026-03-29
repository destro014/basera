import MapKit
import SwiftUI
import VroxalDesign

struct ExploreView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = ExploreViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                VdLoadingState(title: "Loading explore feed")
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .center
                    )
            case .error(let message):
                VdAlert(title: "Explore unavailable", message: message) {
                    Task {
                        await viewModel.retry(
                            using: environment.listingsRepository
                        )
                    }
                }
            case .loaded:
                exploreContent
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            guard viewModel.state == .idle else { return }
            await viewModel.load(using: environment.listingsRepository)
        }
        .baseraScreenBackground()
    }

    private var exploreContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: VdSpacing.md) {
                searchSection
                listingSection(
                    title: "Recent listings",
                    listings: viewModel.recentListings,
                    favoriteStyle: .subtle
                )
                listingSection(
                    title: "Your favourites",
                    listings: viewModel.favoriteListings,
                    favoriteStyle: .prominent
                )
                listingSection(
                    title: "Nearby listings",
                    listings: viewModel.nearbyListings,
                    favoriteStyle: .subtle
                )
                mapSection
            }
            .padding(.horizontal, VdSpacing.md)
            .padding(.top, VdSpacing.md)
            .padding(.bottom, VdSpacing.lg)
        }
        .safeAreaInset(edge: .top, spacing: VdSpacing.none) {
            topToolbar
        }
    }

    private var topToolbar: some View {
        HStack(spacing: VdSpacing.xs) {
            Text("Explore")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Spacer()

            toolbarButton(
                systemImage: "map",
                isPrimary: false,
                action: {}
            )

            toolbarButton(
                systemImage: "slider.horizontal.3",
                isPrimary: true,
                action: {}
            )
        }
        .padding(.horizontal, VdSpacing.md)
        .padding(.top, VdSpacing.xs)
        .padding(.bottom, VdSpacing.sm)
        .background(Color.vdBackgroundDefaultBase)
    }

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: VdSpacing.md) {
            HStack(spacing: VdSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.vdContentDefaultSecondary)

                TextField(
                    "Search by location, type, features",
                    text: $viewModel.searchText
                )
                .vdFont(VdFont.bodyMedium)
                .foregroundStyle(Color.vdContentDefaultBase)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            }
            .padding(.horizontal, VdSpacing.md - VdSpacing.xs)
            .frame(height: 48)
            .background(Color.vdBackgroundDefaultSecondary)
            .clipShape(
                RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: VdRadius.md,
                    style: .continuous
                )
                .stroke(Color.vdBorderDefaultSecondary, lineWidth: 1)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: VdSpacing.sm) {
                    ForEach(ExploreViewModel.AmenityFilter.allCases) { filter in
                        amenityChip(for: filter)
                    }
                }
                .padding(.trailing, VdSpacing.md)
            }
        }
    }

    @ViewBuilder
    private func listingSection(
        title: String,
        listings: [Listing],
        favoriteStyle: ListingCard.FavoriteStyle
    ) -> some View {
        VStack(alignment: .leading, spacing: VdSpacing.sm) {
            Text(title)
                .vdFont(VdFont.titleLarge)
                .foregroundStyle(Color.vdContentDefaultSecondary)

            if listings.isEmpty {
                VStack(alignment: .leading, spacing: VdSpacing.xs) {
                    Text("No listings available")
                        .vdFont(VdFont.labelMedium)
                        .foregroundStyle(Color.vdContentDefaultBase)
                    Text("Try adjusting search or filter selections.")
                        .vdFont(VdFont.bodySmall)
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                }
                .padding(VdSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.vdBackgroundDefaultSecondary)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: VdRadius.md,
                        style: .continuous
                    )
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: VdSpacing.md) {
                        ForEach(listings) { listing in
                            ListingCard(
                                listing: listing,
                                isFavorite: viewModel.isFavorite(
                                    listingID: listing.id
                                ),
                                favoriteStyle: favoriteStyle,
                                onFavoriteTap: {
                                    viewModel.toggleFavorite(
                                        listingID: listing.id
                                    )
                                }
                            )
                        }
                    }
                    .padding(.trailing, VdSpacing.md)
                }
            }
        }
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: VdSpacing.sm) {
            Text("Explore by map")
                .vdFont(VdFont.titleLarge)
                .foregroundStyle(Color.vdContentDefaultSecondary)

            ZStack(alignment: .topTrailing) {
                Map(
                    coordinateRegion: .constant(mapRegion),
                    interactionModes: []
                )
                .frame(height: 250)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: VdRadius.md,
                        style: .continuous
                    )
                )

                Button(action: {}) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.vdContentPrimaryBase)
                        .frame(width: 24, height: 24)
                        .padding(4)
                        .background(Color.vdBackgroundPrimarySecondary)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: VdRadius.md,
                                style: .continuous
                            )
                        )
                }
                .buttonStyle(.plain)
                .padding(VdSpacing.sm)
            }
        }
    }

    private var mapRegion: MKCoordinateRegion {
        let fallback = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 27.7172, longitude: 85.3240),
            span: MKCoordinateSpan(latitudeDelta: 0.22, longitudeDelta: 0.22)
        )

        guard let firstListing = viewModel.nearbyListings.first
            ?? viewModel.filteredListings.first
        else {
            return fallback
        }

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: firstListing.location.latitude,
                longitude: firstListing.location.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.22, longitudeDelta: 0.22)
        )
    }

    private func amenityChip(for filter: ExploreViewModel.AmenityFilter) -> some View {
        let isSelected = viewModel.isFilterSelected(filter)

        return Button {
            viewModel.toggle(filter: filter)
        } label: {
            Text(filter.rawValue)
                .vdFont(VdFont.labelMedium)
                .foregroundStyle(
                    isSelected
                        ? Color.vdContentPrimaryOnBase
                        : Color.vdContentDefaultSecondary
                )
                .padding(.horizontal, VdSpacing.md)
                .padding(.vertical, VdSpacing.xs)
                .background(
                    isSelected
                        ? Color.vdBackgroundPrimaryBase
                        : Color.vdBackgroundDefaultSecondary
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: VdRadius.md,
                        style: .continuous
                    )
                )
                .overlay {
                    RoundedRectangle(
                        cornerRadius: VdRadius.md,
                        style: .continuous
                    )
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

    private func toolbarButton(
        systemImage: String,
        isPrimary: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(
                    isPrimary
                        ? Color.white
                        : Color.vdContentDefaultBase
                )
                .frame(width: 44, height: 44)
                .background(
                    isPrimary
                        ? Color.vdBackgroundPrimaryBase
                        : Color.vdBackgroundDefaultSecondary
                )
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(
                            isPrimary
                                ? Color.clear
                                : Color.vdBorderDefaultSecondary,
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
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
