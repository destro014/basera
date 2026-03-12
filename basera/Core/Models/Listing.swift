import Foundation

struct Listing: Identifiable, Equatable {
    enum PropertyType: String, CaseIterable, Identifiable {
        case room = "Room"
        case flat = "Flat"
        case apartment = "Apartment"

        var id: String { rawValue }
    }

    enum ListingScope: String, CaseIterable, Identifiable {
        case fullProperty = "Full Property"
        case individualRoom = "Individual Room"

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

    enum Status: String, CaseIterable, Identifiable {
        case draft
        case active
        case paused
        case assigned
        case agreementPending = "agreement_pending"
        case occupied

        var id: String { rawValue }

        var label: String {
            switch self {
            case .draft: "Draft"
            case .active: "Active"
            case .paused: "Paused"
            case .assigned: "Assigned"
            case .agreementPending: "Agreement Pending"
            case .occupied: "Occupied"
            }
        }
    }

    struct Utilities: Equatable {
        let electricityIncluded: Bool
        let waterIncluded: Bool
        let internetIncluded: Bool
    }

    struct Pricing: Equatable {
        let monthlyRent: Int
        let securityDeposit: Int
        let utilities: Utilities
    }

    struct Amenities: Equatable {
        let parkingAvailable: Bool
        let wifiAvailable: Bool
        let petAllowed: Bool
    }

    struct ListingRules: Equatable {
        let smokingAllowed: Bool
        let visitorsAllowed: Bool
        let quietHours: String
    }

    struct Location: Equatable {
        let approximateAddress: String
        let exactAddress: String
        let exactAddressMasked: String
        let latitude: Double
        let longitude: Double
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
    let ownerID: String
    let title: String
    let description: String
    let listingScope: ListingScope
    let propertyType: PropertyType
    let location: Location
    let pricing: Pricing
    let amenities: Amenities
    let rules: ListingRules
    let roomCount: Int
    let floor: Int
    let furnishing: Furnishing
    let tenantPreference: TenantPreference
    let availableFrom: Date
    let minimumStayMonths: Int
    let locationRadiusInKM: Int
    let media: [MediaItem]
    let status: Status
    let similarListingIDs: [String]

    init(
        id: String,
        ownerID: String = "preview-user-001",
        title: String,
        description: String,
        approximateLocation: String,
        exactAddress: String = "",
        exactAddressMasked: String,
        monthlyRent: Int,
        securityDeposit: Int = 0,
        bedroomCount: Int,
        floor: Int = 1,
        propertyType: PropertyType,
        listingScope: ListingScope = .fullProperty,
        furnishing: Furnishing,
        parkingAvailable: Bool,
        wifiAvailable: Bool,
        petAllowed: Bool,
        tenantPreference: TenantPreference,
        locationRadiusInKM: Int,
        availableFrom: Date,
        minimumStayMonths: Int = 6,
        utilities: Utilities,
        smokingAllowed: Bool = false,
        visitorsAllowed: Bool = true,
        quietHours: String = "10 PM - 6 AM",
        latitude: Double = 27.7172,
        longitude: Double = 85.3240,
        media: [MediaItem],
        status: Status = .active,
        similarListingIDs: [String]
    ) {
        self.id = id
        self.ownerID = ownerID
        self.title = title
        self.description = description
        self.listingScope = listingScope
        self.propertyType = propertyType
        self.location = Location(
            approximateAddress: approximateLocation,
            exactAddress: exactAddress,
            exactAddressMasked: exactAddressMasked,
            latitude: latitude,
            longitude: longitude
        )
        self.pricing = Pricing(monthlyRent: monthlyRent, securityDeposit: securityDeposit, utilities: utilities)
        self.amenities = Amenities(
            parkingAvailable: parkingAvailable,
            wifiAvailable: wifiAvailable,
            petAllowed: petAllowed
        )
        self.rules = ListingRules(
            smokingAllowed: smokingAllowed,
            visitorsAllowed: visitorsAllowed,
            quietHours: quietHours
        )
        self.roomCount = bedroomCount
        self.floor = floor
        self.furnishing = furnishing
        self.tenantPreference = tenantPreference
        self.availableFrom = availableFrom
        self.minimumStayMonths = minimumStayMonths
        self.locationRadiusInKM = locationRadiusInKM
        self.media = media
        self.status = status
        self.similarListingIDs = similarListingIDs
    }
}

extension Listing {
    var approximateLocation: String { location.approximateAddress }
    var exactAddressMasked: String { location.exactAddressMasked }
    var monthlyRent: Int { pricing.monthlyRent }
    var bedroomCount: Int { roomCount }
    var parkingAvailable: Bool { amenities.parkingAvailable }
    var wifiAvailable: Bool { amenities.wifiAvailable }
    var petAllowed: Bool { amenities.petAllowed }
    var utilities: Utilities { pricing.utilities }
}
