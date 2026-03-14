import Foundation

actor MockListingsRepository: ListingsRepositoryProtocol {
    private var listings: [Listing]

    init(seedListings: [Listing] = PreviewData.featuredListings + PreviewData.ownerListings) {
        self.listings = seedListings
    }

    func fetchExploreListings() async throws -> [Listing] {
        listings.filter { Listing.Status.discoverableStatuses.contains($0.status) }
    }

    func fetchOwnerListings(ownerID: String) async throws -> [Listing] {
        listings
            .filter { $0.ownerID == ownerID }
            .sorted { $0.availableFrom < $1.availableFrom }
    }

    func createListing(_ listing: Listing) async throws {
        listings.insert(listing, at: 0)
    }

    func updateListing(_ listing: Listing) async throws {
        guard let index = listings.firstIndex(where: { $0.id == listing.id && $0.ownerID == listing.ownerID }) else { return }
        listings[index] = listing
    }

    func pauseListing(id: String, ownerID: String) async throws {
        guard let index = listings.firstIndex(where: { $0.id == id && $0.ownerID == ownerID }) else { return }
        listings[index] = listings[index].updating(status: .paused)
    }

    func duplicateListing(id: String, ownerID: String) async throws -> Listing {
        guard let listing = listings.first(where: { $0.id == id && $0.ownerID == ownerID }) else {
            return PreviewData.ownerListings[0]
        }

        let duplicated = listing.duplicating(
            for: ownerID,
            id: "\(listing.id)-COPY-\(Int.random(in: 100...999))",
            status: .draft
        )

        listings.insert(duplicated, at: 0)
        return duplicated
    }

    func updateListingStatus(id: String, ownerID: String, status: Listing.Status) async throws {
        guard let index = listings.firstIndex(where: { $0.id == id && $0.ownerID == ownerID }) else { return }
        listings[index] = listings[index].updating(status: status)
    }

}
