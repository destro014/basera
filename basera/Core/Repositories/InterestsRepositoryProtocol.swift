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
}

struct InterestSubmissionDraft: Equatable, Sendable {
    let listingID: String
    let ownerID: String
    let renterID: String
    let renterSnapshot: RenterProfileSnapshot
    let optionalMessage: String
}
