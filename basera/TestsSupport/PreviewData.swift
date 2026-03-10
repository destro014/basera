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
}
