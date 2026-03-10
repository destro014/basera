import Combine
import Foundation

@MainActor
final class RenterDashboardViewModel: ObservableObject {
    @Published private(set) var listings: [Listing] = []
    @Published private(set) var isLoading = false

    func load(using repository: ListingsRepositoryProtocol) async {
        isLoading = true
        defer { isLoading = false }

        listings = (try? await repository.fetchFeaturedListings()) ?? []
    }
}
