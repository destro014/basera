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
    let paymentGatewayService: PaymentGatewayServiceProtocol

    let authRepository: AuthRepositoryProtocol
    let listingsRepository: ListingsRepositoryProtocol
    let profileRepository: ProfileRepositoryProtocol
    let interestsRepository: InterestsRepositoryProtocol
    let agreementsRepository: AgreementsRepositoryProtocol
    let tenancyRepository: TenancyRepositoryProtocol
    let billingRepository: BillingRepositoryProtocol
    let paymentsRepository: PaymentsRepositoryProtocol

    @Published var currentUser: AppUser?

    init(
        authService: AuthServiceProtocol,
        firestoreService: FirestoreServiceProtocol,
        storageService: StorageServiceProtocol,
        notificationsService: NotificationsServiceProtocol,
        remoteConfigService: RemoteConfigServiceProtocol,
        agreementConfirmationService: AgreementConfirmationServiceProtocol,
        agreementPDFService: AgreementPDFServiceProtocol,
        paymentGatewayService: PaymentGatewayServiceProtocol,
        authRepository: AuthRepositoryProtocol,
        listingsRepository: ListingsRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol,
        interestsRepository: InterestsRepositoryProtocol,
        agreementsRepository: AgreementsRepositoryProtocol,
        tenancyRepository: TenancyRepositoryProtocol,
        billingRepository: BillingRepositoryProtocol,
        paymentsRepository: PaymentsRepositoryProtocol
    ) {
        self.authService = authService
        self.firestoreService = firestoreService
        self.storageService = storageService
        self.notificationsService = notificationsService
        self.remoteConfigService = remoteConfigService
        self.agreementConfirmationService = agreementConfirmationService
        self.agreementPDFService = agreementPDFService
        self.paymentGatewayService = paymentGatewayService
        self.authRepository = authRepository
        self.listingsRepository = listingsRepository
        self.profileRepository = profileRepository
        self.interestsRepository = interestsRepository
        self.agreementsRepository = agreementsRepository
        self.tenancyRepository = tenancyRepository
        self.billingRepository = billingRepository
        self.paymentsRepository = paymentsRepository
    }

    static func bootstrap() -> AppEnvironment {
        let authService = MockAuthService()
        let firestoreService = MockFirestoreService()
        let storageService = MockStorageService()
        let notificationsService = MockNotificationsService()
        let remoteConfigService = MockRemoteConfigService()
        let agreementConfirmationService = MockAgreementConfirmationService()
        let agreementPDFService = MockAgreementPDFService()
        let paymentGatewayService = MockPaymentGatewayService()

        let authRepository = MockAuthRepository(
            authService: authService,
            storageService: storageService
        )
        let listingsRepository = MockListingsRepository()
        let profileRepository = MockProfileRepository()
        let interestsRepository = MockInterestsRepository()
        let agreementsRepository = MockAgreementsRepository(confirmationService: agreementConfirmationService)
        let tenancyRepository = MockTenancyRepository()
        let billingRepository = MockBillingRepository()
        let paymentsRepository = MockPaymentsRepository(billingRepository: billingRepository, gatewayService: paymentGatewayService)

        return AppEnvironment(
            authService: authService,
            firestoreService: firestoreService,
            storageService: storageService,
            notificationsService: notificationsService,
            remoteConfigService: remoteConfigService,
            agreementConfirmationService: agreementConfirmationService,
            agreementPDFService: agreementPDFService,
            paymentGatewayService: paymentGatewayService,
            authRepository: authRepository,
            listingsRepository: listingsRepository,
            profileRepository: profileRepository,
            interestsRepository: interestsRepository,
            agreementsRepository: agreementsRepository,
            tenancyRepository: tenancyRepository,
            billingRepository: billingRepository,
            paymentsRepository: paymentsRepository
        )
    }
}
