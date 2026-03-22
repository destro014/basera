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
        seedNotificationsIfNeeded(for: userID)
        return notificationsByUserID[userID, default: []]
            .sorted { $0.createdAt > $1.createdAt }
    }

    func fetchBadgeState(for userID: String) async throws -> NotificationBadgeState {
        seedNotificationsIfNeeded(for: userID)
        let unreadCount = notificationsByUserID[userID, default: []]
            .filter { $0.isUnread }
            .count
        return NotificationBadgeState(unreadCount: unreadCount)
    }

    func markAsRead(notificationID: String, userID: String) async throws {
        guard let index = notificationsByUserID[userID]?.firstIndex(where: { $0.id == notificationID }) else { return }
        guard var notification = notificationsByUserID[userID]?[index] else { return }
        if notification.readAt == nil {
            notification.readAt = .now
        }
        notificationsByUserID[userID]?[index] = notification
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

    private func seedNotificationsIfNeeded(for userID: String) {
        guard notificationsByUserID[userID, default: []].isEmpty else { return }

        let now = Date()
        notificationsByUserID[userID] = [
            AppNotification(
                id: "NOTIF-SAMPLE-001-\(userID)",
                userID: userID,
                audience: .both,
                type: .interestAccepted,
                title: "Interest accepted",
                message: "Your request for a rental in Jawalakhel has been accepted.",
                createdAt: Calendar.current.date(byAdding: .minute, value: -18, to: now) ?? now,
                readAt: nil,
                route: .interests(listingID: "L-100"),
                metadata: ["listingID": "L-100"]
            ),
            AppNotification(
                id: "NOTIF-SAMPLE-002-\(userID)",
                userID: userID,
                audience: .both,
                type: .billGenerated,
                title: "Monthly bill generated",
                message: "Your latest invoice is ready for review and payment.",
                createdAt: Calendar.current.date(byAdding: .hour, value: -6, to: now) ?? now,
                readAt: nil,
                route: .billing(invoiceID: "INV-501"),
                metadata: ["invoiceID": "INV-501"]
            ),
            AppNotification(
                id: "NOTIF-SAMPLE-003-\(userID)",
                userID: userID,
                audience: .both,
                type: .reviewReminder,
                title: "Leave a review",
                message: "Share your experience with your latest tenancy.",
                createdAt: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now,
                readAt: nil,
                route: .review(tenancyID: "TEN-300"),
                metadata: ["tenancyID": "TEN-300"]
            )
        ]
    }
}
