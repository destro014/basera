import Combine
import Foundation

@MainActor
final class HomeShellViewModel: ObservableObject {
    enum Tab: Hashable {
        case primary
        case explore
        case messages
        case notifications
        case settings
    }

    @Published var user: AppUser
    @Published var selectedTab: Tab = .primary
    @Published var notificationBadge: NotificationBadgeState = .empty
    @Published var routedNotification: NotificationRoute?

    init(user: AppUser) {
        self.user = user
    }

    func refreshNotificationBadge(using repository: NotificationsRepositoryProtocol) async {
        await repository.syncIncomingNotifications(for: user.id)
        notificationBadge = (try? await repository.fetchBadgeState(for: user.id)) ?? .empty
    }

    func openNotificationRoute(_ route: NotificationRoute) {
        selectedTab = .primary
        routedNotification = route
    }

    func clearRoutedNotification() {
        routedNotification = nil
    }
}
