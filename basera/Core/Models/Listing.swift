import Foundation

struct Listing: Identifiable, Equatable {
    enum PropertyType: String, CaseIterable, Identifiable {
        case room = "Room"
        case flat = "Flat"
        case apartment = "Apartment"

        var id: String { rawValue }
    }

    enum Furnishing: String, CaseIterable, Identifiable {
        case furnished = "Furnished"
        case unfurnished = "Unfurnished"

        var id: String { rawValue }
    }

    enum TenantPreference: String, CaseIterable, Identifiable {
        case family = "Family"
        case bachelor = "Bachelor"
        case both = "Any"

        var id: String { rawValue }
    }

    struct Utilities: Equatable {
        let electricityIncluded: Bool
        let waterIncluded: Bool
        let internetIncluded: Bool
    }

    struct MediaItem: Identifiable, Equatable {
        enum Kind: Equatable {
            case image
            case videoPreview
        }

        let id: String
        let kind: Kind
        let title: String
        let subtitle: String
        let systemImageName: String
    }

    enum InterestState: Equatable {
        case none
        case requested
        case approved
        case declined

        var label: String {
            switch self {
            case .none: "I'm Interested"
            case .requested: "Interest Requested"
            case .approved: "Interest Approved"
            case .declined: "Request Declined"
            }
        }
    }

    let id: String
    let title: String
    let description: String
    let approximateLocation: String
    let exactAddressMasked: String
    let monthlyRent: Int
    let bedroomCount: Int
    let propertyType: PropertyType
    let furnishing: Furnishing
    let parkingAvailable: Bool
    let wifiAvailable: Bool
    let petAllowed: Bool
    let tenantPreference: TenantPreference
    let locationRadiusInKM: Int
    let availableFrom: Date
    let utilities: Utilities
    let media: [MediaItem]
    let similarListingIDs: [String]
}
