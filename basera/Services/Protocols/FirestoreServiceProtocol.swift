import Foundation

protocol FirestoreServiceProtocol {
    func fetchDocument(path: String) async throws -> [String: Any]
    func setDocument(path: String, data: [String: Any]) async throws
}
