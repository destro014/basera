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

    static let featuredListings: [Listing] = [
        Listing(id: "L-100", title: "Sunny Flat in Lalitpur", approximateLocation: "Near Jawalakhel", monthlyRent: 28000, bedroomCount: 2),
        Listing(id: "L-101", title: "Cozy Room in Kathmandu", approximateLocation: "Near Boudha", monthlyRent: 12000, bedroomCount: 1)
    ]

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
}
