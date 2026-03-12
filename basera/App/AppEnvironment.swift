import Combine
import Foundation

@MainActor
final class AppEnvironment: ObservableObject {
    let authService: AuthServiceProtocol
    let firestoreService: FirestoreServiceProtocol
    let storageService: StorageServiceProtocol
    let notificationsService: NotificationsServiceProtocol
    let remoteConfigService: RemoteConfigServiceProtocol
    let agreementConfirmationService: AgreementConfirmationServiceProtocol
    let agreementPDFService: AgreementPDFServiceProtocol

    let authRepository: AuthRepositoryProtocol
    let listingsRepository: ListingsRepositoryProtocol
    let profileRepository: ProfileRepositoryProtocol
    let interestsRepository: InterestsRepositoryProtocol
    let agreementsRepository: AgreementsRepositoryProtocol
    let tenancyRepository: TenancyRepositoryProtocol

    @Published var currentUser: AppUser?

    init(
        authService: AuthServiceProtocol,
        firestoreService: FirestoreServiceProtocol,
        storageService: StorageServiceProtocol,
        notificationsService: NotificationsServiceProtocol,
        remoteConfigService: RemoteConfigServiceProtocol,
        agreementConfirmationService: AgreementConfirmationServiceProtocol,
        agreementPDFService: AgreementPDFServiceProtocol,
        authRepository: AuthRepositoryProtocol,
        listingsRepository: ListingsRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol,
        interestsRepository: InterestsRepositoryProtocol,
        agreementsRepository: AgreementsRepositoryProtocol,
        tenancyRepository: TenancyRepositoryProtocol
    ) {
        self.authService = authService
        self.firestoreService = firestoreService
        self.storageService = storageService
        self.notificationsService = notificationsService
        self.remoteConfigService = remoteConfigService
        self.agreementConfirmationService = agreementConfirmationService
        self.agreementPDFService = agreementPDFService
        self.authRepository = authRepository
        self.listingsRepository = listingsRepository
        self.profileRepository = profileRepository
        self.interestsRepository = interestsRepository
        self.agreementsRepository = agreementsRepository
        self.tenancyRepository = tenancyRepository
    }

    static func bootstrap() -> AppEnvironment {
        let authService = MockAuthService()
        let firestoreService = MockFirestoreService()
        let storageService = MockStorageService()
        let notificationsService = MockNotificationsService()
        let remoteConfigService = MockRemoteConfigService()
        let agreementConfirmationService = MockAgreementConfirmationService()
        let agreementPDFService = MockAgreementPDFService()

        let authRepository = MockAuthRepository(
            authService: authService,
            storageService: storageService
        )
        let listingsRepository = MockListingsRepository()
        let profileRepository = MockProfileRepository()
        let interestsRepository = MockInterestsRepository()
        let agreementsRepository = MockAgreementsRepository(confirmationService: agreementConfirmationService)
        let tenancyRepository = MockTenancyRepository()

        return AppEnvironment(
            authService: authService,
            firestoreService: firestoreService,
            storageService: storageService,
            notificationsService: notificationsService,
            remoteConfigService: remoteConfigService,
            agreementConfirmationService: agreementConfirmationService,
            agreementPDFService: agreementPDFService,
            authRepository: authRepository,
            listingsRepository: listingsRepository,
            profileRepository: profileRepository,
            interestsRepository: interestsRepository,
            agreementsRepository: agreementsRepository,
            tenancyRepository: tenancyRepository
        )
    }
}
