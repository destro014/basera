import Foundation

@MainActor
final class RenterActiveTenancyViewModel: ObservableObject {
    @Published private(set) var activeTenancy: TenancyRecord?
    @Published private(set) var archivedTenancies: [TenancyRecord] = []

    func load(renterID: String, tenancyRepository: TenancyRepositoryProtocol) async {
        activeTenancy = try? await tenancyRepository.fetchActiveTenancy(for: renterID)
        archivedTenancies = (try? await tenancyRepository.fetchArchivedTenancies(for: renterID, party: .renter)) ?? []
    }
}
