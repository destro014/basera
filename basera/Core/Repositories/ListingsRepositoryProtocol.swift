import Foundation

protocol ListingsRepositoryProtocol {
    func fetchFeaturedListings() async throws -> [Listing]
}
