import Foundation

enum UserRole: String, CaseIterable, Identifiable, Codable {
    case renter
    case owner

    var id: String { rawValue }

    var title: String {
        switch self {
        case .renter: "Renter"
        case .owner: "Owner"
        }
    }

    var iconName: String {
        switch self {
        case .renter: "person.fill"
        case .owner: "building.2.fill"
        }
    }
}
