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
        let calendar = Calendar.current

        return [
            Listing(
                id: "L-100",
                title: "Sunny Family Flat in Jawalakhel",
                description: "Bright 2BHK flat with balcony, close to schools and grocery stores.",
                approximateLocation: "Jawalakhel, Lalitpur",
                exactAddressMasked: "Exact ward and street shared after owner approval",
                monthlyRent: 32000,
                bedroomCount: 2,
                propertyType: .flat,
                furnishing: .furnished,
                parkingAvailable: true,
                wifiAvailable: true,
                petAllowed: false,
                tenantPreference: .family,
                locationRadiusInKM: 2,
                availableFrom: calendar.date(byAdding: .day, value: 7, to: .now) ?? .now,
                utilities: .init(electricityIncluded: false, waterIncluded: true, internetIncluded: true),
                media: [
                    .init(id: "M-100-1", kind: .image, title: "Living Room", subtitle: "Natural light", systemImageName: "sofa.fill"),
                    .init(id: "M-100-2", kind: .image, title: "Kitchen", subtitle: "Modular setup", systemImageName: "fork.knife"),
                    .init(id: "M-100-3", kind: .videoPreview, title: "Walkthrough", subtitle: "35 sec preview", systemImageName: "play.rectangle.fill")
                ],
                similarListingIDs: ["L-101", "L-106"]
            ),
            Listing(
                id: "L-101",
                title: "Budget Bachelor Room in Boudha",
                description: "Single room on first floor with attached bathroom and shared terrace.",
                approximateLocation: "Boudha, Kathmandu",
                exactAddressMasked: "Exact tole and house number shared after owner approval",
                monthlyRent: 12000,
                bedroomCount: 1,
                propertyType: .room,
                furnishing: .unfurnished,
                parkingAvailable: false,
                wifiAvailable: true,
                petAllowed: false,
                tenantPreference: .bachelor,
                locationRadiusInKM: 4,
                availableFrom: calendar.date(byAdding: .day, value: 3, to: .now) ?? .now,
                utilities: .init(electricityIncluded: false, waterIncluded: true, internetIncluded: false),
                media: [
                    .init(id: "M-101-1", kind: .image, title: "Room", subtitle: "Fresh paint", systemImageName: "bed.double.fill"),
                    .init(id: "M-101-2", kind: .videoPreview, title: "Entrance", subtitle: "15 sec preview", systemImageName: "play.tv.fill")
                ],
                similarListingIDs: ["L-107", "L-104"]
            ),
            Listing(
                id: "L-102",
                title: "Pet-friendly Apartment near Bhaktapur Durbar",
                description: "Three-bedroom apartment with elevator access and quiet surroundings.",
                approximateLocation: "Suryabinayak, Bhaktapur",
                exactAddressMasked: "Exact apartment block shared after owner approval",
                monthlyRent: 45000,
                bedroomCount: 3,
                propertyType: .apartment,
                furnishing: .furnished,
                parkingAvailable: true,
                wifiAvailable: true,
                petAllowed: true,
                tenantPreference: .both,
                locationRadiusInKM: 6,
                availableFrom: calendar.date(byAdding: .day, value: 20, to: .now) ?? .now,
                utilities: .init(electricityIncluded: false, waterIncluded: false, internetIncluded: true),
                media: [
                    .init(id: "M-102-1", kind: .image, title: "Master Bedroom", subtitle: "Wood flooring", systemImageName: "house.fill"),
                    .init(id: "M-102-2", kind: .image, title: "Balcony", subtitle: "City view", systemImageName: "building.2.crop.circle")
                ],
                similarListingIDs: ["L-105", "L-108"]
            ),
            Listing(
                id: "L-103",
                title: "Compact Family Flat in Pokhara Lakeside",
                description: "Two-bedroom top floor flat ideal for small family.",
                approximateLocation: "Lakeside, Pokhara",
                exactAddressMasked: "Exact lane shared after owner approval",
                monthlyRent: 26000,
                bedroomCount: 2,
                propertyType: .flat,
                furnishing: .unfurnished,
                parkingAvailable: true,
                wifiAvailable: false,
                petAllowed: true,
                tenantPreference: .family,
                locationRadiusInKM: 5,
                availableFrom: calendar.date(byAdding: .day, value: 12, to: .now) ?? .now,
                utilities: .init(electricityIncluded: false, waterIncluded: true, internetIncluded: false),
                media: [
                    .init(id: "M-103-1", kind: .image, title: "Front View", subtitle: "Third floor", systemImageName: "building.fill")
                ],
                similarListingIDs: ["L-100", "L-108"]
            ),
            Listing(
                id: "L-104",
                title: "Furnished Room with Parking in Baneshwor",
                description: "Ready-to-move room with bed, wardrobe and bike parking.",
                approximateLocation: "New Baneshwor, Kathmandu",
                exactAddressMasked: "Exact chowk and house number shared after owner approval",
                monthlyRent: 18000,
                bedroomCount: 1,
                propertyType: .room,
                furnishing: .furnished,
                parkingAvailable: true,
                wifiAvailable: true,
                petAllowed: false,
                tenantPreference: .both,
                locationRadiusInKM: 3,
                availableFrom: calendar.date(byAdding: .day, value: 1, to: .now) ?? .now,
                utilities: .init(electricityIncluded: true, waterIncluded: true, internetIncluded: true),
                media: [
                    .init(id: "M-104-1", kind: .image, title: "Room Setup", subtitle: "With study table", systemImageName: "lamp.table.fill")
                ],
                similarListingIDs: ["L-101", "L-107"]
            ),
            Listing(
                id: "L-105",
                title: "Large Apartment for Family in Butwal",
                description: "Spacious apartment with 24/7 water and separate utility meters.",
                approximateLocation: "Traffic Chowk, Butwal",
                exactAddressMasked: "Exact street shared after owner approval",
                monthlyRent: 38000,
                bedroomCount: 3,
                propertyType: .apartment,
                furnishing: .unfurnished,
                parkingAvailable: true,
                wifiAvailable: false,
                petAllowed: true,
                tenantPreference: .family,
                locationRadiusInKM: 8,
                availableFrom: calendar.date(byAdding: .day, value: 25, to: .now) ?? .now,
                utilities: .init(electricityIncluded: false, waterIncluded: false, internetIncluded: false),
                media: [
                    .init(id: "M-105-1", kind: .image, title: "Hall", subtitle: "Open plan", systemImageName: "rectangle.3.group.fill")
                ],
                similarListingIDs: ["L-102", "L-103"]
            ),
            Listing(
                id: "L-106",
                title: "Modern Flat with Lift in Chitwan",
                description: "Two-bed flat in newly built block with lift access and security.",
                approximateLocation: "Bharatpur, Chitwan",
                exactAddressMasked: "Exact complex name shared after owner approval",
                monthlyRent: 30000,
                bedroomCount: 2,
                propertyType: .flat,
                furnishing: .furnished,
                parkingAvailable: false,
                wifiAvailable: true,
                petAllowed: true,
                tenantPreference: .both,
                locationRadiusInKM: 7,
                availableFrom: calendar.date(byAdding: .day, value: 14, to: .now) ?? .now,
                utilities: .init(electricityIncluded: false, waterIncluded: true, internetIncluded: true),
                media: [
                    .init(id: "M-106-1", kind: .videoPreview, title: "Building Tour", subtitle: "28 sec preview", systemImageName: "video.fill")
                ],
                similarListingIDs: ["L-100", "L-103"]
            ),
            Listing(
                id: "L-107",
                title: "Affordable Unfurnished Room in Hetauda",
                description: "Ground-floor room for students or working bachelors.",
                approximateLocation: "Huprachaur, Hetauda",
                exactAddressMasked: "Exact house location shared after owner approval",
                monthlyRent: 9000,
                bedroomCount: 1,
                propertyType: .room,
                furnishing: .unfurnished,
                parkingAvailable: false,
                wifiAvailable: false,
                petAllowed: false,
                tenantPreference: .bachelor,
                locationRadiusInKM: 4,
                availableFrom: calendar.date(byAdding: .day, value: 5, to: .now) ?? .now,
                utilities: .init(electricityIncluded: false, waterIncluded: true, internetIncluded: false),
                media: [
                    .init(id: "M-107-1", kind: .image, title: "Room", subtitle: "Simple layout", systemImageName: "bed.double.circle")
                ],
                similarListingIDs: ["L-101", "L-104"]
            ),
            Listing(
                id: "L-108",
                title: "Pet-Friendly Apartment in Dharan",
                description: "Two-bedroom apartment with nearby market and bus stop.",
                approximateLocation: "Putali Line, Dharan",
                exactAddressMasked: "Exact apartment number shared after owner approval",
                monthlyRent: 27000,
                bedroomCount: 2,
                propertyType: .apartment,
                furnishing: .furnished,
                parkingAvailable: true,
                wifiAvailable: false,
                petAllowed: true,
                tenantPreference: .both,
                locationRadiusInKM: 6,
                availableFrom: calendar.date(byAdding: .day, value: 9, to: .now) ?? .now,
                utilities: .init(electricityIncluded: true, waterIncluded: true, internetIncluded: false),
                media: [
                    .init(id: "M-108-1", kind: .image, title: "Kitchen", subtitle: "Semi-open", systemImageName: "cup.and.saucer.fill"),
                    .init(id: "M-108-2", kind: .videoPreview, title: "Neighborhood", subtitle: "20 sec preview", systemImageName: "film.fill")
                ],
                similarListingIDs: ["L-102", "L-103"]
            )
        ]
    }()
}
