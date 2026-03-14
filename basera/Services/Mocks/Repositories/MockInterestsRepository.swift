import Foundation

actor MockInterestsRepository: InterestsRepositoryProtocol {
    private var interests: [InterestRequest]
    private var conversations: [ChatConversation]
    private var messagesByConversationID: [String: [ChatMessage]]
    private var visits: [PropertyVisitSchedule]
    private var assignmentsByListingID: [String: ListingAssignment]

    init(
        interests: [InterestRequest] = PreviewData.mockInterests,
        conversations: [ChatConversation] = PreviewData.mockConversations,
        messagesByConversationID: [String: [ChatMessage]] = PreviewData.mockMessagesByConversationID,
        visits: [PropertyVisitSchedule] = PreviewData.mockVisits,
        assignmentsByListingID: [String: ListingAssignment] = PreviewData.mockAssignmentsByListingID
    ) {
        self.interests = interests
        self.conversations = conversations
        self.messagesByConversationID = messagesByConversationID
        self.visits = visits
        self.assignmentsByListingID = assignmentsByListingID
    }

    func submitInterest(_ draft: InterestSubmissionDraft) async throws -> InterestRequest {
        let request = InterestRequest(
            id: "INT-\(UUID().uuidString.prefix(8))",
            listingID: draft.listingID,
            ownerID: draft.ownerID,
            renterID: draft.renterID,
            renterSnapshot: draft.renterSnapshot,
            submittedMessage: draft.optionalMessage,
            submittedAt: .now,
            status: .pending,
            chatApproval: .unavailable
        )
        interests.insert(request, at: 0)
        return request
    }

    func fetchInterests(for listingID: String, ownerID: String) async throws -> [InterestRequest] {
        interests
            .filter { $0.listingID == listingID && $0.ownerID == ownerID }
            .sorted { $0.submittedAt > $1.submittedAt }
    }

    func fetchInterests(for renterID: String) async throws -> [InterestRequest] {
        interests
            .filter { $0.renterID == renterID }
            .sorted { $0.submittedAt > $1.submittedAt }
    }

    func updateInterestStatus(interestID: String, ownerID: String, status: InterestRequest.Status) async throws {
        guard let idx = interests.firstIndex(where: { $0.id == interestID && $0.ownerID == ownerID }) else { return }
        interests[idx].status = status
        if status == .rejected {
            interests[idx].chatApproval = .unavailable
        }
        if status == .accepted, interests[idx].chatApproval == .unavailable {
            interests[idx].chatApproval = .awaitingOwnerApproval
        }
    }

    func approveChat(interestID: String, ownerID: String) async throws {
        guard let idx = interests.firstIndex(where: { $0.id == interestID && $0.ownerID == ownerID }) else { return }
        guard interests[idx].status == .accepted else { return }

        interests[idx].chatApproval = .approved
        let interest = interests[idx]

        guard !conversations.contains(where: { $0.interestID == interestID }) else { return }

        let conversation = ChatConversation(
            id: "CHAT-\(UUID().uuidString.prefix(6))",
            listingID: interest.listingID,
            ownerID: interest.ownerID,
            renterID: interest.renterID,
            participantName: interest.renterSnapshot.fullName,
            listingTitle: "Listing \(interest.listingID)",
            interestID: interest.id,
            lastMessagePreview: "Chat approved. You can now coordinate visit details.",
            lastUpdatedAt: .now,
            unreadCount: 1
        )
        conversations.insert(conversation, at: 0)
        messagesByConversationID[conversation.id] = [
            ChatMessage(
                id: "MSG-\(UUID().uuidString.prefix(6))",
                conversationID: conversation.id,
                senderID: ownerID,
                body: "Hi, chat is now approved. Let us coordinate a visit.",
                sentAt: .now
            )
        ]
    }

    func scheduleVisit(_ draft: VisitScheduleDraft) async throws -> PropertyVisitSchedule {
        let visit = PropertyVisitSchedule(
            id: "VIS-\(UUID().uuidString.prefix(8))",
            listingID: draft.listingID,
            ownerID: draft.ownerID,
            renterID: draft.renterID,
            note: draft.note,
            scheduledAt: draft.scheduledAt,
            status: .proposed,
            updatedAt: .now
        )
        visits.removeAll { $0.listingID == draft.listingID && $0.renterID == draft.renterID && $0.status == .proposed }
        visits.insert(visit, at: 0)
        return visit
    }

    func fetchVisits(listingID: String, ownerID: String) async throws -> [PropertyVisitSchedule] {
        visits
            .filter { $0.listingID == listingID && $0.ownerID == ownerID }
            .sorted { $0.scheduledAt < $1.scheduledAt }
    }

    func fetchVisits(renterID: String) async throws -> [PropertyVisitSchedule] {
        visits
            .filter { $0.renterID == renterID }
            .sorted { $0.scheduledAt < $1.scheduledAt }
    }

    func confirmVisit(visitID: String, renterID: String) async throws {
        guard let idx = visits.firstIndex(where: { $0.id == visitID && $0.renterID == renterID }) else { return }
        let existing = visits[idx]
        visits[idx] = PropertyVisitSchedule(
            id: existing.id,
            listingID: existing.listingID,
            ownerID: existing.ownerID,
            renterID: existing.renterID,
            note: existing.note,
            scheduledAt: existing.scheduledAt,
            status: .confirmed,
            updatedAt: .now
        )
    }

    func requestAssignment(_ draft: AssignmentRequestDraft) async throws -> ListingAssignment {
        guard assignmentsByListingID[draft.listingID] == nil || assignmentsByListingID[draft.listingID]?.status != .requested else {
            return assignmentsByListingID[draft.listingID]!
        }

        let assignment = ListingAssignment(
            id: "ASN-\(UUID().uuidString.prefix(8))",
            listingID: draft.listingID,
            ownerID: draft.ownerID,
            renterID: draft.renterID,
            interestID: draft.interestID,
            requestedAt: .now,
            status: .requested,
            note: draft.note
        )
        assignmentsByListingID[draft.listingID] = assignment
        return assignment
    }

    func fetchAssignment(listingID: String, ownerID: String) async throws -> ListingAssignment? {
        guard let assignment = assignmentsByListingID[listingID], assignment.ownerID == ownerID else { return nil }
        return assignment
    }

    func fetchAssignment(renterID: String) async throws -> ListingAssignment? {
        assignmentsByListingID.values.first(where: { $0.renterID == renterID })
    }

    func respondToAssignment(assignmentID: String, renterID: String, accept: Bool) async throws {
        guard let listingID = assignmentsByListingID.values.first(where: { $0.id == assignmentID && $0.renterID == renterID })?.listingID,
              let assignment = assignmentsByListingID[listingID] else { return }
        assignmentsByListingID[listingID] = ListingAssignment(
            id: assignment.id,
            listingID: assignment.listingID,
            ownerID: assignment.ownerID,
            renterID: assignment.renterID,
            interestID: assignment.interestID,
            requestedAt: assignment.requestedAt,
            status: accept ? .accepted : .declined,
            note: assignment.note
        )
    }

    func fetchConversations(for userID: String) async throws -> [ChatConversation] {
        conversations
            .filter { $0.ownerID == userID || $0.renterID == userID }
            .sorted { $0.lastUpdatedAt > $1.lastUpdatedAt }
    }

    func fetchMessages(conversationID: String, userID: String) async throws -> [ChatMessage] {
        guard let conversation = conversations.first(where: { $0.id == conversationID }) else { return [] }
        guard conversation.ownerID == userID || conversation.renterID == userID else { return [] }
        return messagesByConversationID[conversationID, default: []].sorted { $0.sentAt < $1.sentAt }
    }

    func sendMessage(conversationID: String, senderID: String, body: String) async throws {
        guard !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard let idx = conversations.firstIndex(where: { $0.id == conversationID }) else { return }
        guard conversations[idx].ownerID == senderID || conversations[idx].renterID == senderID else { return }

        let message = ChatMessage(
            id: "MSG-\(UUID().uuidString.prefix(6))",
            conversationID: conversationID,
            senderID: senderID,
            body: body,
            sentAt: .now
        )
        messagesByConversationID[conversationID, default: []].append(message)

        let existing = conversations[idx]
        conversations[idx] = ChatConversation(
            id: existing.id,
            listingID: existing.listingID,
            ownerID: existing.ownerID,
            renterID: existing.renterID,
            participantName: existing.participantName,
            listingTitle: existing.listingTitle,
            interestID: existing.interestID,
            lastMessagePreview: body,
            lastUpdatedAt: .now,
            unreadCount: existing.unreadCount + 1
        )
    }

    func fetchNotificationBadges(userID: String) async throws -> InterestNotificationBadge {
        InterestNotificationBadge(
            ownerPendingInterests: interests.filter { $0.ownerID == userID && $0.status == .pending }.count,
            renterPendingResponses: interests.filter { $0.renterID == userID && $0.status == .pending }.count,
            renterChatApprovals: interests.filter { $0.renterID == userID && $0.chatApproval == .approved }.count
        )
    }
}
