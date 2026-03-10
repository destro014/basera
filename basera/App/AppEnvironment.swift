import Combine
import Foundation

@MainActor
final class AppEnvironment: ObservableObject {
    let authService: AuthServiceProtocol
    let firestoreService: FirestoreServiceProtocol
    let storageService: StorageServiceProtocol
    let notificationsService: NotificationsServiceProtocol
    let remoteConfigService: RemoteConfigServiceProtocol

    let authRepository: AuthRepositoryProtocol
    let listingsRepository: ListingsRepositoryProtocol

    @Published var currentUser: AppUser?

    init(
        authService: AuthServiceProtocol,
        firestoreService: FirestoreServiceProtocol,
        storageService: StorageServiceProtocol,
        notificationsService: NotificationsServiceProtocol,
        remoteConfigService: RemoteConfigServiceProtocol,
        authRepository: AuthRepositoryProtocol,
        listingsRepository: ListingsRepositoryProtocol
    ) {
        self.authService = authService
        self.firestoreService = firestoreService
        self.storageService = storageService
        self.notificationsService = notificationsService
        self.remoteConfigService = remoteConfigService
        self.authRepository = authRepository
        self.listingsRepository = listingsRepository
    }

    static func bootstrap() -> AppEnvironment {
        let authService = MockAuthService()
        let firestoreService = MockFirestoreService()
        let storageService = MockStorageService()
        let notificationsService = MockNotificationsService()
        let remoteConfigService = MockRemoteConfigService()

        let authRepository = MockAuthRepository(
            authService: authService,
            storageService: storageService
        )
        let listingsRepository = MockListingsRepository()

        return AppEnvironment(
            authService: authService,
            firestoreService: firestoreService,
            storageService: storageService,
            notificationsService: notificationsService,
            remoteConfigService: remoteConfigService,
            authRepository: authRepository,
            listingsRepository: listingsRepository
        )
    }
}
