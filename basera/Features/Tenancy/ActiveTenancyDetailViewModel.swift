import Foundation

@MainActor
final class ActiveTenancyDetailViewModel: ObservableObject {
    @Published private(set) var tenancy: TenancyRecord?
    @Published private(set) var agreement: AgreementRecord?

    func load(tenancyID: String, userID: String, tenancyRepository: TenancyRepositoryProtocol, agreementsRepository: AgreementsRepositoryProtocol) async {
        tenancy = try? await tenancyRepository.fetchTenancy(id: tenancyID, userID: userID)
        guard let agreementID = tenancy?.agreementID else { return }
        agreement = try? await agreementsRepository.fetchAgreement(id: agreementID, userID: userID)
    }
}
