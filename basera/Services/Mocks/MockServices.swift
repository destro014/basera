import Foundation

actor MockAuthService: AuthServiceProtocol {
    private var currentID: String? = nil

    func currentUserID() async throws -> String? {
        currentID
    }

    func signInPreviewUser() async throws -> String {
        let generated = "preview-user-001"
        currentID = generated
        return generated
    }

    func signOut() async throws {
        currentID = nil
    }
}

struct MockFirestoreService: FirestoreServiceProtocol {
    func fetchDocument(path: String) async throws -> [String: Any] {
        ["path": path, "source": "mock"]
    }

    func setDocument(path: String, data: [String: Any]) async throws {}
}

struct MockStorageService: StorageServiceProtocol {
    func upload(data: Data, path: String) async throws -> URL {
        URL(string: "https://example.com/mock/\(path)")!
    }
}

struct MockNotificationsService: NotificationsServiceProtocol {
    func registerForPushNotifications() async {}
    func updateDeviceToken(_ token: String) async {}
}

final class MockRemoteConfigService: RemoteConfigServiceProtocol {
    private let values: [String: String] = [
        "home_banner_text": "Welcome to Basra"
    ]

    func refresh() async {}

    func value(for key: String) -> String? {
        values[key]
    }
}
