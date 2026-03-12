import Foundation

struct PropertyVisitSchedule: Identifiable, Equatable {
    enum Status: String, Equatable {
        case proposed
        case confirmed
        case completed
        case cancelled

        var label: String {
            switch self {
            case .proposed: "Awaiting confirmation"
            case .confirmed: "Visit confirmed"
            case .completed: "Visit completed"
            case .cancelled: "Visit cancelled"
            }
        }
    }

    let id: String
    let listingID: String
    let ownerID: String
    let renterID: String
    let note: String
    let scheduledAt: Date
    var status: Status
    let updatedAt: Date
}

struct ListingAssignment: Identifiable, Equatable {
    enum Status: String, Equatable {
        case none
        case requested
        case accepted
        case declined

        var label: String {
            switch self {
            case .none: "Not assigned"
            case .requested: "Assignment requested"
            case .accepted: "Assigned renter confirmed"
            case .declined: "Assignment declined"
            }
        }
    }

    let id: String
    let listingID: String
    let ownerID: String
    let renterID: String
    let interestID: String
    let requestedAt: Date
    var status: Status
    let note: String

    var isPendingRenterAction: Bool {
        status == .requested
    }
}
