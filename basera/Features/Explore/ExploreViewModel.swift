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

    enum Category: String, CaseIterable, Identifiable {
        case room = "Room"
        case flat = "Flat"
        case apartment = "Apartment"

        var id: String { rawValue }

        var propertyType: Listing.PropertyType {
            switch self {
            case .room: return .room
            case .flat: return .flat
            case .apartment: return .apartment
            }
        }
    }

    enum DiscoveryMode: String, CaseIterable, Identifiable {
        case list = "List"
        case map = "Map"

        var id: String { rawValue }
    }

    struct ListingFilters: Equatable {
        static let defaultAvailableByDate = Calendar.current.date(
            byAdding: .day,
            value: 365,
            to: .now
        ) ?? .now

        var minPrice: Double = 8_000
        var maxPrice: Double = 50_000
        var parkingRequired = false
        var wifiRequired = false
        var petsAllowedOnly = false
        var tenantPreference: Listing.TenantPreference?
        var maximumRadiusInKM = 10
        var availableFrom: Date = defaultAvailableByDate
    }

    @Published private(set) var state: LoadState = .idle
    @Published private(set) var listings: [Listing] = []
    @Published var searchText = ""
    @Published var selectedCategory: Category?
    @Published var discoveryMode: DiscoveryMode = .list
    @Published var filters = ListingFilters()

    var filteredListings: [Listing] {
        let query = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return listings.filter { listing in
            let matchesCategory = selectedCategory == nil || listing.propertyType == selectedCategory?.propertyType
            let matchesQuery = query.isEmpty
                || listing.title.lowercased().contains(query)
                || listing.approximateLocation.lowercased().contains(query)
                || listing.description.lowercased().contains(query)
            let matchesPrice = listing.monthlyRent >= Int(filters.minPrice)
                && listing.monthlyRent <= Int(filters.maxPrice)
            let matchesParking = !filters.parkingRequired || listing.parkingAvailable
            let matchesWifi = !filters.wifiRequired || listing.wifiAvailable
            let matchesPet = !filters.petsAllowedOnly || listing.petAllowed
            let matchesPreference = filters.tenantPreference == nil
                || filters.tenantPreference == listing.tenantPreference
                || listing.tenantPreference == .both
            let matchesRadius = listing.locationRadiusInKM <= filters.maximumRadiusInKM
            let matchesAvailableFrom = listing.availableFrom <= filters.availableFrom

            return matchesCategory
                && matchesQuery
                && matchesPrice
                && matchesParking
                && matchesWifi
                && matchesPet
                && matchesPreference
                && matchesRadius
                && matchesAvailableFrom
        }
    }

    var hasAppliedFilters: Bool {
        filters != ListingFilters()
    }

    var recentListings: [Listing] {
        Array(
            filteredListings
                .sorted { $0.availableFrom < $1.availableFrom }
                .prefix(6)
        )
    }

    var popularListings: [Listing] {
        Array(
            filteredListings
                .sorted { popularityScore(for: $0) > popularityScore(for: $1) }
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
            state = .loaded
        } catch {
            state = .error("Could not load listings right now.")
        }
    }

    func retry(using repository: ListingsRepositoryProtocol) async {
        await load(using: repository)
    }

    func toggleCategory(_ category: Category) {
        if selectedCategory == category {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
    }

    func resetFilters() {
        filters = ListingFilters()
    }

    private func popularityScore(for listing: Listing) -> Int {
        let amenitiesScore = (listing.parkingAvailable ? 1 : 0)
            + (listing.wifiAvailable ? 1 : 0)
            + (listing.petAllowed ? 1 : 0)

        let affordabilityScore = max(0, 60_000 - listing.monthlyRent) / 1_000
        let spaceScore = listing.bedroomCount * 3

        return (amenitiesScore * 10) + affordabilityScore + spaceScore
    }
}
