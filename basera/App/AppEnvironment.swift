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
    let profileRepository: ProfileRepositoryProtocol
    let interestsRepository: InterestsRepositoryProtocol

    @Published var currentUser: AppUser?

    init(
        authService: AuthServiceProtocol,
        firestoreService: FirestoreServiceProtocol,
        storageService: StorageServiceProtocol,
        notificationsService: NotificationsServiceProtocol,
        remoteConfigService: RemoteConfigServiceProtocol,
        authRepository: AuthRepositoryProtocol,
        listingsRepository: ListingsRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol,
        interestsRepository: InterestsRepositoryProtocol
    ) {
        self.authService = authService
        self.firestoreService = firestoreService
        self.storageService = storageService
        self.notificationsService = notificationsService
        self.remoteConfigService = remoteConfigService
        self.authRepository = authRepository
        self.listingsRepository = listingsRepository
        self.profileRepository = profileRepository
        self.interestsRepository = interestsRepository
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
        let profileRepository = MockProfileRepository()
        let interestsRepository = MockInterestsRepository()

        return AppEnvironment(
            authService: authService,
            firestoreService: firestoreService,
            storageService: storageService,
            notificationsService: notificationsService,
            remoteConfigService: remoteConfigService,
            authRepository: authRepository,
            listingsRepository: listingsRepository,
            profileRepository: profileRepository,
            interestsRepository: interestsRepository
        )
    }
}
