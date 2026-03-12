import Foundation

enum PreviewData {
    static func user(id: String = "preview-user-001", activeRole: UserRole) -> AppUser {
        AppUser(
            id: id,
            fullName: "Sita Basera",
            phoneNumber: "+9779800000000",
            availableRoles: [.renter, .owner],
            activeRole: activeRole,
            profilePhotoURL: nil
        )
    }

    static let featuredListings: [Listing] = {
        [
            listing(id: "L-100", title: "Sunny Family Flat in Jawalakhel", propertyType: .flat, location: "Jawalakhel, Lalitpur", rent: 32_000, rooms: 2, status: .active),
            listing(id: "L-101", title: "Budget Bachelor Room in Boudha", propertyType: .room, location: "Boudha, Kathmandu", rent: 12_000, rooms: 1, furnishing: .unfurnished, tenant: .bachelor, status: .active),
            listing(id: "L-102", title: "Pet-friendly Apartment in Bhaktapur", propertyType: .apartment, location: "Suryabinayak, Bhaktapur", rent: 45_000, rooms: 3, petAllowed: true, status: .active),
            listing(id: "L-103", title: "Compact Family Flat in Pokhara", propertyType: .flat, location: "Lakeside, Pokhara", rent: 26_000, rooms: 2, furnishing: .unfurnished, status: .active),
            listing(id: "L-104", title: "Furnished Room with Parking in Baneshwor", propertyType: .room, location: "New Baneshwor, Kathmandu", rent: 15_000, rooms: 1, status: .active)
        ]
    }()

    static let ownerListings: [Listing] = {
        [
            listing(id: "OL-200", title: "Tulsi Apartment - Full Unit", propertyType: .apartment, scope: .fullProperty, location: "Bhaisepati, Lalitpur", rent: 40_000, rooms: 3, status: .active),
            listing(id: "OL-201", title: "Tulsi Apartment - Room 1", propertyType: .room, scope: .individualRoom, location: "Bhaisepati, Lalitpur", rent: 13_000, rooms: 1, tenant: .bachelor, status: .draft),
            listing(id: "OL-202", title: "Tulsi Apartment - Room 2", propertyType: .room, scope: .individualRoom, location: "Bhaisepati, Lalitpur", rent: 14_000, rooms: 1, status: .paused),
            listing(id: "OL-203", title: "Modern Flat near Chabahil", propertyType: .flat, scope: .fullProperty, location: "Chabahil, Kathmandu", rent: 28_000, rooms: 2, status: .assigned),
            listing(id: "OL-204", title: "Apartment in Butwal", propertyType: .apartment, scope: .fullProperty, location: "Traffic Chowk, Butwal", rent: 38_000, rooms: 3, status: .agreementPending),
            listing(id: "OL-205", title: "Flat in Pokhara Lakeside", propertyType: .flat, scope: .fullProperty, location: "Lakeside, Pokhara", rent: 30_000, rooms: 2, status: .occupied)
        ]
    }()

    static let renterProfile = RenterProfile(
        fullName: "Sita Basera",
        phoneNumber: "+9779800000000",
        email: "sita@example.com",
        profilePhotoURL: nil,
        occupation: "Software Engineer",
        familySize: 3,
        hasPets: false,
        smokingStatus: .nonSmoker
    )

    static let ownerProfile = OwnerProfile(
        fullName: "Sita Basera",
        phoneNumber: "+9779800000000",
        email: "sita-owner@example.com",
        profilePhotoURL: nil,
        address: "Boudha, Kathmandu",
        idDocumentState: DocumentUploadState(frontUploaded: true, backUploaded: false),
        paymentDetails: OwnerPaymentDetails(
            bankName: "Nabil Bank",
            accountName: "Sita Basera",
            accountNumber: "001234567890",
            esewaID: "9800000000",
            fonepayNumber: "9800000000"
        )
    )

    static let profileBundles: [String: UserProfileBundle] = [
        "preview-user-001": UserProfileBundle(
            renterProfile: renterProfile,
            ownerProfile: ownerProfile
        )
    ]

    private static func listing(
        id: String,
        title: String,
        propertyType: Listing.PropertyType,
        scope: Listing.ListingScope = .fullProperty,
        location: String,
        rent: Int,
        rooms: Int,
        furnishing: Listing.Furnishing = .furnished,
        tenant: Listing.TenantPreference = .both,
        petAllowed: Bool = false,
        status: Listing.Status
    ) -> Listing {
        Listing(
            id: id,
            title: title,
            description: "Well-maintained rental with reliable utilities and nearby transit.",
            approximateLocation: location,
            exactAddress: "Ward 5, House 22",
            exactAddressMasked: "Exact address shared only after owner approval",
            monthlyRent: rent,
            securityDeposit: rent,
            bedroomCount: rooms,
            floor: 2,
            propertyType: propertyType,
            listingScope: scope,
            furnishing: furnishing,
            parkingAvailable: true,
            wifiAvailable: true,
            petAllowed: petAllowed,
            tenantPreference: tenant,
            locationRadiusInKM: 5,
            availableFrom: Calendar.current.date(byAdding: .day, value: 10, to: .now) ?? .now,
            minimumStayMonths: 6,
            utilities: .init(electricityIncluded: false, waterIncluded: true, internetIncluded: true),
            media: [
                .init(id: "\(id)-1", kind: .image, title: "Living Area", subtitle: "Preview", systemImageName: "photo.fill"),
                .init(id: "\(id)-2", kind: .videoPreview, title: "Walkthrough", subtitle: "22 sec", systemImageName: "video.fill")
            ],
            status: status,
            similarListingIDs: []
        )
    }
}
