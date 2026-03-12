import Combine
import Foundation

@MainActor
final class MyListingsViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var listings: [Listing] = []

    func load(ownerID: String, repository: ListingsRepositoryProtocol) async {
        state = .loading
        do {
            listings = try await repository.fetchOwnerListings(ownerID: ownerID)
            state = .loaded
        } catch {
            state = .error("Unable to load listings.")
        }
    }

    func save(listing: Listing, repository: ListingsRepositoryProtocol) async {
        do {
            if listings.contains(where: { $0.id == listing.id }) {
                try await repository.updateListing(listing)
            } else {
                try await repository.createListing(listing)
            }
        } catch { }
    }

    func pause(listing: Listing, repository: ListingsRepositoryProtocol) async {
        do {
            try await repository.pauseListing(id: listing.id, ownerID: listing.ownerID)
        } catch { }
    }

    func duplicate(listing: Listing, repository: ListingsRepositoryProtocol) async {
        do {
            _ = try await repository.duplicateListing(id: listing.id, ownerID: listing.ownerID)
        } catch { }
    }
}
