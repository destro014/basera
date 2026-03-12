import Foundation

@MainActor
final class OwnerInterestedRentersViewModel: ObservableObject {
    @Published private(set) var interests: [InterestRequest] = []
    @Published private(set) var badge: InterestNotificationBadge = .init(ownerPendingInterests: 0, renterPendingResponses: 0, renterChatApprovals: 0)

    let listingID: String
    let ownerID: String

    init(listingID: String, ownerID: String) {
        self.listingID = listingID
        self.ownerID = ownerID
    }

    func load(using repository: InterestsRepositoryProtocol) async {
        do {
            interests = try await repository.fetchInterests(for: listingID, ownerID: ownerID)
            badge = try await repository.fetchNotificationBadges(userID: ownerID)
        } catch {
            interests = []
        }
    }

    func accept(_ interestID: String, using repository: InterestsRepositoryProtocol) async {
        try? await repository.updateInterestStatus(interestID: interestID, ownerID: ownerID, status: .accepted)
        await load(using: repository)
    }

    func reject(_ interestID: String, using repository: InterestsRepositoryProtocol) async {
        try? await repository.updateInterestStatus(interestID: interestID, ownerID: ownerID, status: .rejected)
        await load(using: repository)
    }

    func approveChat(_ interestID: String, using repository: InterestsRepositoryProtocol) async {
        try? await repository.approveChat(interestID: interestID, ownerID: ownerID)
        await load(using: repository)
    }
}
