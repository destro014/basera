import Foundation

@MainActor
final class RenterDashboardViewModel: ObservableObject {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    enum DiscoveryMode: String, CaseIterable, Identifiable {
        case list = "List"
        case map = "Map"

        var id: String { rawValue }
    }

    struct ListingFilters: Equatable {
        static let defaultAvailableByDate = Calendar.current.date(byAdding: .day, value: 365, to: .now) ?? .now

        var minPrice: Double = 8_000
        var maxPrice: Double = 50_000
        var selectedPropertyTypes: Set<Listing.PropertyType> = []
        var furnishing: Listing.Furnishing?
        var parkingRequired = false
        var wifiRequired = false
        var petsAllowedOnly = false
        var tenantPreference: Listing.TenantPreference?
        var maximumRadiusInKM = 10
        var availableFrom: Date = defaultAvailableByDate
        var includeElectricity = false
        var includeWater = false
        var includeInternet = false
    }

    @Published private(set) var state: LoadState = .idle
    @Published var discoveryMode: DiscoveryMode = .list
    @Published var searchText = ""
    @Published var filters = ListingFilters()
    @Published private(set) var allListings: [Listing] = []
    @Published private(set) var favoriteListingIDs: Set<String> = ["L-102"]
    @Published private(set) var interestByListingID: [String: Listing.InterestState] = ["L-104": .requested]

    var filteredListings: [Listing] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return allListings.filter { listing in
            let matchesSearch = query.isEmpty || listing.title.lowercased().contains(query) || listing.approximateLocation.lowercased().contains(query)
            let matchesPrice = listing.monthlyRent >= Int(filters.minPrice) && listing.monthlyRent <= Int(filters.maxPrice)
            let matchesType = filters.selectedPropertyTypes.isEmpty || filters.selectedPropertyTypes.contains(listing.propertyType)
            let matchesFurnishing = filters.furnishing == nil || filters.furnishing == listing.furnishing
            let matchesParking = !filters.parkingRequired || listing.parkingAvailable
            let matchesWifi = !filters.wifiRequired || listing.wifiAvailable
            let matchesPet = !filters.petsAllowedOnly || listing.petAllowed
            let matchesPreference = filters.tenantPreference == nil || filters.tenantPreference == listing.tenantPreference || listing.tenantPreference == .both
            let matchesRadius = listing.locationRadiusInKM <= filters.maximumRadiusInKM
            let matchesAvailableFrom = listing.availableFrom <= filters.availableFrom
            let matchesElectricity = !filters.includeElectricity || listing.utilities.electricityIncluded
            let matchesWater = !filters.includeWater || listing.utilities.waterIncluded
            let matchesInternet = !filters.includeInternet || listing.utilities.internetIncluded

            return matchesSearch &&
                matchesPrice &&
                matchesType &&
                matchesFurnishing &&
                matchesParking &&
                matchesWifi &&
                matchesPet &&
                matchesPreference &&
                matchesRadius &&
                matchesAvailableFrom &&
                matchesElectricity &&
                matchesWater &&
                matchesInternet
        }
    }

    var favoriteListings: [Listing] {
        allListings.filter { favoriteListingIDs.contains($0.id) }
    }

    var hasAppliedFilters: Bool {
        filters != ListingFilters()
    }

    func load(using repository: ListingsRepositoryProtocol) async {
        state = .loading

        do {
            allListings = try await repository.fetchExploreListings()
            state = .loaded
        } catch {
            state = .error("We couldn't load listings right now.")
        }
    }

    func retry(using repository: ListingsRepositoryProtocol) async {
        await load(using: repository)
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

    func interestState(for listingID: String) -> Listing.InterestState {
        interestByListingID[listingID] ?? .none
    }

    func sendInterest(for listingID: String) {
        guard interestState(for: listingID) == .none else { return }
        interestByListingID[listingID] = .requested
    }

    func similarListings(for listing: Listing) -> [Listing] {
        allListings.filter { listing.similarListingIDs.contains($0.id) }
    }
}
