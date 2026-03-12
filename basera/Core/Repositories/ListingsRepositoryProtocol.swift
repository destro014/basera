import Foundation

protocol ListingsRepositoryProtocol {
    func fetchExploreListings() async throws -> [Listing]
    func fetchOwnerListings(ownerID: String) async throws -> [Listing]
    func createListing(_ listing: Listing) async throws
    func updateListing(_ listing: Listing) async throws
    func pauseListing(id: String, ownerID: String) async throws
    func duplicateListing(id: String, ownerID: String) async throws -> Listing
    func updateListingStatus(id: String, ownerID: String, status: Listing.Status) async throws
}
