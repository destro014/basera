import Combine
import Foundation

@MainActor
final class AppEnvironment: ObservableObject {
    let authService: AuthServiceProtocol
    let databaseService: DatabaseServiceProtocol
    let storageService: StorageServiceProtocol
    let notificationsService: NotificationsServiceProtocol
    let remoteConfigService: RemoteConfigServiceProtocol
    let agreementConfirmationService: AgreementConfirmationServiceProtocol
    let agreementPDFService: AgreementPDFServiceProtocol
    let paymentGatewayService: PaymentGatewayServiceProtocol
    let biometricLoginManager: BiometricLoginManagerProtocol

    let authRepository: AuthRepositoryProtocol
    let listingsRepository: ListingsRepositoryProtocol
    let profileRepository: ProfileRepositoryProtocol
    let interestsRepository: InterestsRepositoryProtocol
    let agreementsRepository: AgreementsRepositoryProtocol
    let tenancyRepository: TenancyRepositoryProtocol
    let billingRepository: BillingRepositoryProtocol
    let paymentsRepository: PaymentsRepositoryProtocol
    let notificationsRepository: NotificationsRepositoryProtocol
    let reviewsRepository: ReviewsRepositoryProtocol

    @Published var currentUser: AppUser?

    init(
        authService: AuthServiceProtocol,
        databaseService: DatabaseServiceProtocol,
        storageService: StorageServiceProtocol,
        notificationsService: NotificationsServiceProtocol,
        remoteConfigService: RemoteConfigServiceProtocol,
        agreementConfirmationService: AgreementConfirmationServiceProtocol,
        agreementPDFService: AgreementPDFServiceProtocol,
        paymentGatewayService: PaymentGatewayServiceProtocol,
        biometricLoginManager: BiometricLoginManagerProtocol,
        authRepository: AuthRepositoryProtocol,
        listingsRepository: ListingsRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol,
        interestsRepository: InterestsRepositoryProtocol,
        agreementsRepository: AgreementsRepositoryProtocol,
        tenancyRepository: TenancyRepositoryProtocol,
        billingRepository: BillingRepositoryProtocol,
        paymentsRepository: PaymentsRepositoryProtocol,
        notificationsRepository: NotificationsRepositoryProtocol,
        reviewsRepository: ReviewsRepositoryProtocol
    ) {
        self.authService = authService
        self.databaseService = databaseService
        self.storageService = storageService
        self.notificationsService = notificationsService
        self.remoteConfigService = remoteConfigService
        self.agreementConfirmationService = agreementConfirmationService
        self.agreementPDFService = agreementPDFService
        self.paymentGatewayService = paymentGatewayService
        self.biometricLoginManager = biometricLoginManager
        self.authRepository = authRepository
        self.listingsRepository = listingsRepository
        self.profileRepository = profileRepository
        self.interestsRepository = interestsRepository
        self.agreementsRepository = agreementsRepository
        self.tenancyRepository = tenancyRepository
        self.billingRepository = billingRepository
        self.paymentsRepository = paymentsRepository
        self.notificationsRepository = notificationsRepository
        self.reviewsRepository = reviewsRepository
    }

    static func bootstrap() -> AppEnvironment {
        if AppRuntimeConfiguration.useMockInfrastructure {
            return mockEnvironment()
        }

        return supabaseEnvironment()
    }

    private static func supabaseEnvironment() -> AppEnvironment {
        let databaseService = SupabaseDatabaseService()
        let storageService = SupabaseStorageService()
        let notificationsService = SupabaseNotificationsService()
        let remoteConfigService = SupabaseRemoteConfigService(databaseService: databaseService)
        let authService = SupabaseAuthService(databaseService: databaseService)
        let agreementConfirmationService = MockAgreementConfirmationService()
        let agreementPDFService = MockAgreementPDFService()
        let paymentGatewayService = MockPaymentGatewayService()
        let biometricLoginManager = DeviceBiometricLoginManager()

        let authRepository = SupabaseAuthRepository(authService: authService)
        let listingsRepository = SupabaseListingsRepository(databaseService: databaseService)
        let profileRepository = SupabaseProfileRepository(databaseService: databaseService)
        let interestsRepository = MockInterestsRepository()
        let agreementsRepository = MockAgreementsRepository(confirmationService: agreementConfirmationService)
        let tenancyRepository = MockTenancyRepository()
        let billingRepository = MockBillingRepository()
        let paymentsRepository = MockPaymentsRepository(
            billingRepository: billingRepository,
            gatewayService: paymentGatewayService
        )
        let notificationsRepository = SupabaseNotificationsRepository(
            notificationsService: notificationsService,
            databaseService: databaseService
        )
        let reviewsRepository = MockReviewsRepository()

        return AppEnvironment(
            authService: authService,
            databaseService: databaseService,
            storageService: storageService,
            notificationsService: notificationsService,
            remoteConfigService: remoteConfigService,
            agreementConfirmationService: agreementConfirmationService,
            agreementPDFService: agreementPDFService,
            paymentGatewayService: paymentGatewayService,
            biometricLoginManager: biometricLoginManager,
            authRepository: authRepository,
            listingsRepository: listingsRepository,
            profileRepository: profileRepository,
            interestsRepository: interestsRepository,
            agreementsRepository: agreementsRepository,
            tenancyRepository: tenancyRepository,
            billingRepository: billingRepository,
            paymentsRepository: paymentsRepository,
            notificationsRepository: notificationsRepository,
            reviewsRepository: reviewsRepository
        )
    }

    private static func mockEnvironment() -> AppEnvironment {
        let authService = MockAuthService()
        let databaseService = MockDatabaseService()
        let storageService = MockStorageService()
        let notificationsService = MockNotificationsService()
        let remoteConfigService = MockRemoteConfigService()
        let agreementConfirmationService = MockAgreementConfirmationService()
        let agreementPDFService = MockAgreementPDFService()
        let paymentGatewayService = MockPaymentGatewayService()
        let biometricLoginManager = DeviceBiometricLoginManager()

        let authRepository = MockAuthRepository(authService: authService)
        let listingsRepository = MockListingsRepository()
        let profileRepository = MockProfileRepository()
        let interestsRepository = MockInterestsRepository()
        let agreementsRepository = MockAgreementsRepository(confirmationService: agreementConfirmationService)
        let tenancyRepository = MockTenancyRepository()
        let billingRepository = MockBillingRepository()
        let paymentsRepository = MockPaymentsRepository(
            billingRepository: billingRepository,
            gatewayService: paymentGatewayService
        )
        let notificationsRepository = MockNotificationsRepository(service: notificationsService)
        let reviewsRepository = MockReviewsRepository()

        return AppEnvironment(
            authService: authService,
            databaseService: databaseService,
            storageService: storageService,
            notificationsService: notificationsService,
            remoteConfigService: remoteConfigService,
            agreementConfirmationService: agreementConfirmationService,
            agreementPDFService: agreementPDFService,
            paymentGatewayService: paymentGatewayService,
            biometricLoginManager: biometricLoginManager,
            authRepository: authRepository,
            listingsRepository: listingsRepository,
            profileRepository: profileRepository,
            interestsRepository: interestsRepository,
            agreementsRepository: agreementsRepository,
            tenancyRepository: tenancyRepository,
            billingRepository: billingRepository,
            paymentsRepository: paymentsRepository,
            notificationsRepository: notificationsRepository,
            reviewsRepository: reviewsRepository
        )
    }
}
