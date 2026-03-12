import Foundation

protocol ListingsRepositoryProtocol {
    func fetchExploreListings() async throws -> [Listing]
}
