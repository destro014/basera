import Foundation

protocol AuthServiceProtocol {
    func currentUserID() async throws -> String?
    func signInPreviewUser() async throws -> String
    func signOut() async throws
}
