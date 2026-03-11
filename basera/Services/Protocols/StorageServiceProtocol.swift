import Foundation

protocol StorageServiceProtocol {
    func upload(data: Data, path: String) async throws -> URL
}
