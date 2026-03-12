import Combine
import Foundation

@MainActor
final class OwnerTenantOverviewViewModel: ObservableObject {
    @Published private(set) var activeTenancies: [TenancyRecord] = []
    @Published private(set) var archivedTenancies: [TenancyRecord] = []

    func load(ownerID: String, tenancyRepository: TenancyRepositoryProtocol) async {
        activeTenancies = (try? await tenancyRepository.fetchActiveTenancies(ownerID: ownerID)) ?? []
        archivedTenancies = (try? await tenancyRepository.fetchArchivedTenancies(for: ownerID, party: .owner)) ?? []
    }
}
