import Foundation

@MainActor
final class OwnerInterestedRentersViewModel: ObservableObject {
    @Published private(set) var interests: [InterestRequest] = []
    @Published private(set) var visits: [PropertyVisitSchedule] = []
    @Published private(set) var assignment: ListingAssignment?
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
            visits = try await repository.fetchVisits(listingID: listingID, ownerID: ownerID)
            assignment = try await repository.fetchAssignment(listingID: listingID, ownerID: ownerID)
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

    func scheduleVisit(for renterID: String, at scheduledAt: Date, note: String, using repository: InterestsRepositoryProtocol) async {
        let draft = VisitScheduleDraft(listingID: listingID, ownerID: ownerID, renterID: renterID, note: note, scheduledAt: scheduledAt)
        try? await repository.scheduleVisit(draft)
        await load(using: repository)
    }

    func requestAssignment(
        interestID: String,
        note: String,
        interestsRepository: InterestsRepositoryProtocol,
        listingsRepository: ListingsRepositoryProtocol
    ) async {
        guard let interest = interests.first(where: { $0.id == interestID }) else { return }
        guard assignment?.isPendingRenterAction != true else { return }

        let draft = AssignmentRequestDraft(
            listingID: listingID,
            ownerID: ownerID,
            renterID: interest.renterID,
            interestID: interestID,
            note: note
        )
        _ = try? await interestsRepository.requestAssignment(draft)
        try? await listingsRepository.updateListingStatus(id: listingID, ownerID: ownerID, status: .assigned)
        await load(using: interestsRepository)
    }

    func canRequestAssignment(for interest: InterestRequest) -> Bool {
        guard interest.status == .accepted else { return false }
        return assignment?.isPendingRenterAction != true || assignment?.renterID == interest.renterID
    }
}
