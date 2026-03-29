import Combine
import Foundation

@MainActor
final class ExploreViewModel: ObservableObject {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    enum AmenityFilter: String, CaseIterable, Identifiable, Hashable {
        case freeWifi = "Free wifi"
        case parking = "Parking"
        case petsAllowed = "Pets allowed"

        var id: String { rawValue }
    }

    @Published private(set) var state: LoadState = .idle
    @Published private(set) var listings: [Listing] = []
    @Published var searchText = ""
    @Published private(set) var selectedFilters: Set<AmenityFilter> = []
    @Published private(set) var favoriteListingIDs: Set<String> = [
        "L-100",
        "L-102",
        "L-104"
    ]

    var filteredListings: [Listing] {
        let query = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return listings.filter { listing in
            let matchesQuery = query.isEmpty
                || listing.title.lowercased().contains(query)
                || listing.approximateLocation.lowercased().contains(query)
                || listing.description.lowercased().contains(query)
            let matchesAmenities = selectedFilters.allSatisfy { filter in
                switch filter {
                case .freeWifi: return listing.wifiAvailable
                case .parking: return listing.parkingAvailable
                case .petsAllowed: return listing.petAllowed
                }
            }

            return matchesQuery && matchesAmenities
        }
    }

    var recentListings: [Listing] {
        Array(
            filteredListings
                .sorted { $0.availableFrom < $1.availableFrom }
                .prefix(6)
        )
    }

    var favoriteListings: [Listing] {
        Array(
            filteredListings
                .filter { favoriteListingIDs.contains($0.id) }
                .prefix(6)
        )
    }

    var nearbyListings: [Listing] {
        Array(
            filteredListings
                .sorted {
                    if $0.locationRadiusInKM == $1.locationRadiusInKM {
                        return $0.monthlyRent < $1.monthlyRent
                    }
                    return $0.locationRadiusInKM < $1.locationRadiusInKM
                }
                .prefix(6)
        )
    }

    func load(using repository: ListingsRepositoryProtocol) async {
        state = .loading

        do {
            listings = try await repository.fetchExploreListings()
            synchronizeFavoritesWithAvailableListings()
            state = .loaded
        } catch {
            state = .error("Could not load listings right now.")
        }
    }

    func retry(using repository: ListingsRepositoryProtocol) async {
        await load(using: repository)
    }

    func toggle(filter: AmenityFilter) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
    }

    func isFilterSelected(_ filter: AmenityFilter) -> Bool {
        selectedFilters.contains(filter)
    }

    func toggleFavorite(listingID: String) {
        if favoriteListingIDs.contains(listingID) {
            favoriteListingIDs.remove(listingID)
        } else {
            favoriteListingIDs.insert(listingID)
        }
    }

    func isFavorite(listingID: String) -> Bool {
        favoriteListingIDs.contains(listingID)
    }

    private func synchronizeFavoritesWithAvailableListings() {
        let availableIDs = Set(listings.map(\.id))
        favoriteListingIDs = favoriteListingIDs.intersection(availableIDs)

        if favoriteListingIDs.isEmpty {
            favoriteListingIDs = Set(listings.prefix(2).map(\.id))
        }
    }
}
