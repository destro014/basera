import Combine
import Foundation

@MainActor
final class RenterInterestsViewModel: ObservableObject {
    @Published private(set) var interests: [InterestRequest] = []
    @Published private(set) var visits: [PropertyVisitSchedule] = []
    @Published private(set) var assignment: ListingAssignment?
    @Published private(set) var badge: InterestNotificationBadge = .init(ownerPendingInterests: 0, renterPendingResponses: 0, renterChatApprovals: 0)

    let renterID: String

    init(renterID: String) {
        self.renterID = renterID
    }

    func load(using repository: InterestsRepositoryProtocol) async {
        do {
            interests = try await repository.fetchInterests(for: renterID)
            visits = try await repository.fetchVisits(renterID: renterID)
            assignment = try await repository.fetchAssignment(renterID: renterID)
            badge = try await repository.fetchNotificationBadges(userID: renterID)
        } catch {
            interests = []
        }
    }

    func confirmVisit(_ visitID: String, using repository: InterestsRepositoryProtocol) async {
        try? await repository.confirmVisit(visitID: visitID, renterID: renterID)
        await load(using: repository)
    }

    func respondToAssignment(
        accept: Bool,
        interestsRepository: InterestsRepositoryProtocol,
        listingsRepository: ListingsRepositoryProtocol
    ) async {
        guard let assignment else { return }
        try? await interestsRepository.respondToAssignment(assignmentID: assignment.id, renterID: renterID, accept: accept)
        let status: Listing.Status = accept ? .agreementPending : .active
        try? await listingsRepository.updateListingStatus(id: assignment.listingID, ownerID: assignment.ownerID, status: status)
        await load(using: interestsRepository)
    }
}
