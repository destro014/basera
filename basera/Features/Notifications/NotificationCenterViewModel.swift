import Foundation

@MainActor
final class NotificationCenterViewModel: ObservableObject {
    @Published private(set) var notifications: [AppNotification] = []
    @Published private(set) var badgeState: NotificationBadgeState = .empty

    let userID: String

    init(userID: String) {
        self.userID = userID
    }

    func load(repository: NotificationsRepositoryProtocol) async {
        await repository.syncIncomingNotifications(for: userID)
        notifications = (try? await repository.fetchNotifications(for: userID)) ?? []
        badgeState = (try? await repository.fetchBadgeState(for: userID)) ?? .empty
    }

    func markAsRead(_ notificationID: String, repository: NotificationsRepositoryProtocol) async {
        try? await repository.markAsRead(notificationID: notificationID, userID: userID)
        await load(repository: repository)
    }

    func markAllAsRead(repository: NotificationsRepositoryProtocol) async {
        try? await repository.markAllAsRead(for: userID)
        await load(repository: repository)
    }
}
