import Foundation

protocol DatabaseServiceProtocol {
    func fetchDocument(path: String) async throws -> [String: Any]
    func setDocument(path: String, data: [String: Any]) async throws
    func fetchCollection(path: String) async throws -> [[String: Any]]
    func queryCollection(path: String, field: String, isEqualTo value: Any) async throws -> [[String: Any]]
}
