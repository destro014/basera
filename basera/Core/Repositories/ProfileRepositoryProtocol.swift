import Foundation

protocol ProfileRepositoryProtocol {
    func fetchProfiles(for userID: String) async throws -> UserProfileBundle
    func saveRenterProfile(_ profile: RenterProfile, for userID: String) async throws
    func saveOwnerProfile(_ profile: OwnerProfile, for userID: String) async throws
}
