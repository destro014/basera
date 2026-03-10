import Foundation

protocol NotificationsServiceProtocol {
    func registerForPushNotifications() async
    func updateDeviceToken(_ token: String) async
}
