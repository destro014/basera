import Foundation

protocol InterestsRepositoryProtocol: Sendable {
    func submitInterest(_ draft: InterestSubmissionDraft) async throws -> InterestRequest
    func fetchInterests(for listingID: String, ownerID: String) async throws -> [InterestRequest]
    func fetchInterests(for renterID: String) async throws -> [InterestRequest]
    func updateInterestStatus(interestID: String, ownerID: String, status: InterestRequest.Status) async throws
    func approveChat(interestID: String, ownerID: String) async throws
    func fetchConversations(for userID: String) async throws -> [ChatConversation]
    func fetchMessages(conversationID: String, userID: String) async throws -> [ChatMessage]
    func sendMessage(conversationID: String, senderID: String, body: String) async throws
    func fetchNotificationBadges(userID: String) async throws -> InterestNotificationBadge

    func scheduleVisit(_ draft: VisitScheduleDraft) async throws -> PropertyVisitSchedule
    func fetchVisits(listingID: String, ownerID: String) async throws -> [PropertyVisitSchedule]
    func fetchVisits(renterID: String) async throws -> [PropertyVisitSchedule]
    func confirmVisit(visitID: String, renterID: String) async throws

    func requestAssignment(_ draft: AssignmentRequestDraft) async throws -> ListingAssignment
    func fetchAssignment(listingID: String, ownerID: String) async throws -> ListingAssignment?
    func fetchAssignment(renterID: String) async throws -> ListingAssignment?
    func respondToAssignment(assignmentID: String, renterID: String, accept: Bool) async throws
}

struct InterestSubmissionDraft: Equatable, Sendable {
    let listingID: String
    let ownerID: String
    let renterID: String
    let renterSnapshot: RenterProfileSnapshot
    let optionalMessage: String
}

struct VisitScheduleDraft: Equatable, Sendable {
    let listingID: String
    let ownerID: String
    let renterID: String
    let note: String
    let scheduledAt: Date
}

struct AssignmentRequestDraft: Equatable, Sendable {
    let listingID: String
    let ownerID: String
    let renterID: String
    let interestID: String
    let note: String
}
