import Foundation

protocol RemoteConfigServiceProtocol {
    func refresh() async
    func value(for key: String) -> String?
}
