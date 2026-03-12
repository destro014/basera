import Foundation

actor MockNotificationsRepository: NotificationsRepositoryProtocol {
    private var notificationsByUserID: [String: [AppNotification]]
    private let service: NotificationsServiceProtocol

    init(
        service: NotificationsServiceProtocol,
        seedNotificationsByUserID: [String: [AppNotification]] = PreviewData.mockNotificationsByUserID
    ) {
        self.service = service
        self.notificationsByUserID = seedNotificationsByUserID
    }

    func registerForPushNotifications() async {
        await service.registerForPushNotifications()
    }

    func syncIncomingNotifications(for userID: String) async {
        let payloads = await service.fetchPendingPayloads(for: userID)
        guard payloads.isEmpty == false else { return }

        let mapped = payloads.map {
            AppNotification(
                id: $0.id,
                userID: $0.userID,
                audience: .both,
                type: $0.type,
                title: $0.title,
                message: $0.message,
                createdAt: $0.createdAt,
                readAt: nil,
                route: $0.route,
                metadata: $0.metadata
            )
        }

        notificationsByUserID[userID, default: []].insert(contentsOf: mapped, at: 0)
    }

    func fetchNotifications(for userID: String) async throws -> [AppNotification] {
        notificationsByUserID[userID, default: []]
            .sorted { $0.createdAt > $1.createdAt }
    }

    func fetchBadgeState(for userID: String) async throws -> NotificationBadgeState {
        let unreadCount = notificationsByUserID[userID, default: []]
            .filter(\.isUnread)
            .count
        return NotificationBadgeState(unreadCount: unreadCount)
    }

    func markAsRead(notificationID: String, userID: String) async throws {
        guard let index = notificationsByUserID[userID]?.firstIndex(where: { $0.id == notificationID }) else { return }
        var notification = notificationsByUserID[userID]?[index]
        notification?.readAt = notification?.readAt ?? .now
        if let notification {
            notificationsByUserID[userID]?[index] = notification
        }
    }

    func markAllAsRead(for userID: String) async throws {
        let now = Date()
        notificationsByUserID[userID] = notificationsByUserID[userID, default: []].map {
            AppNotification(
                id: $0.id,
                userID: $0.userID,
                audience: $0.audience,
                type: $0.type,
                title: $0.title,
                message: $0.message,
                createdAt: $0.createdAt,
                readAt: $0.readAt ?? now,
                route: $0.route,
                metadata: $0.metadata
            )
        }
    }
}
