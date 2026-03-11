import Foundation

protocol AuthRepositoryProtocol {
    func restoreSession() async throws -> AppUser?
    func signInPreviewUser(activeRole: UserRole) async throws -> AppUser
    func signOut() async throws
}
