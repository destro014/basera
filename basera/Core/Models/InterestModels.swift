import Foundation

struct RenterProfileSnapshot: Equatable {
    let renterID: String
    let fullName: String
    let occupation: String
    let familySize: Int
    let hasPets: Bool
    let smokingStatus: String
}

struct InterestRequest: Identifiable, Equatable {
    enum Status: String, CaseIterable, Equatable {
        case pending
        case accepted
        case rejected

        var label: String {
            switch self {
            case .pending: "Pending"
            case .accepted: "Accepted"
            case .rejected: "Rejected"
            }
        }
    }

    enum ChatApproval: String, CaseIterable, Equatable {
        case unavailable
        case awaitingOwnerApproval
        case approved

        var label: String {
            switch self {
            case .unavailable: "Chat unavailable"
            case .awaitingOwnerApproval: "Waiting for chat approval"
            case .approved: "Chat approved"
            }
        }
    }

    let id: String
    let listingID: String
    let ownerID: String
    let renterID: String
    let renterSnapshot: RenterProfileSnapshot
    let submittedMessage: String
    let submittedAt: Date
    var status: Status
    var chatApproval: ChatApproval

    var canApproveChat: Bool {
        status == .accepted && chatApproval != .approved
    }

    var canOpenChat: Bool {
        status == .accepted && chatApproval == .approved
    }
}

struct ChatConversation: Identifiable, Equatable {
    let id: String
    let listingID: String
    let ownerID: String
    let renterID: String
    let participantName: String
    let listingTitle: String
    let interestID: String
    let lastMessagePreview: String
    let lastUpdatedAt: Date
    let unreadCount: Int
}

struct ChatMessage: Identifiable, Equatable {
    let id: String
    let conversationID: String
    let senderID: String
    let body: String
    let sentAt: Date
}

struct InterestNotificationBadge: Equatable {
    let ownerPendingInterests: Int
    let renterPendingResponses: Int
    let renterChatApprovals: Int
}
