import Foundation

@MainActor
final class RenterInterestsViewModel: ObservableObject {
    @Published private(set) var interests: [InterestRequest] = []
    @Published private(set) var badge: InterestNotificationBadge = .init(ownerPendingInterests: 0, renterPendingResponses: 0, renterChatApprovals: 0)

    let renterID: String

    init(renterID: String) {
        self.renterID = renterID
    }

    func load(using repository: InterestsRepositoryProtocol) async {
        do {
            interests = try await repository.fetchInterests(for: renterID)
            badge = try await repository.fetchNotificationBadges(userID: renterID)
        } catch {
            interests = []
        }
    }
}
