import Foundation

protocol NotificationsRepositoryProtocol {
    func registerForPushNotifications() async
    func syncIncomingNotifications(for userID: String) async
    func fetchNotifications(for userID: String) async throws -> [AppNotification]
    func fetchBadgeState(for userID: String) async throws -> NotificationBadgeState
    func markAsRead(notificationID: String, userID: String) async throws
    func markAllAsRead(for userID: String) async throws
}
