import Foundation

struct MockAuthRepository: AuthRepositoryProtocol {
    private let authService: AuthServiceProtocol
    private let storageService: StorageServiceProtocol

    init(authService: AuthServiceProtocol, storageService: StorageServiceProtocol) {
        self.authService = authService
        self.storageService = storageService
    }

    func restoreSession() async throws -> AppUser? {
        try await authService.currentUser()
    }

    func requestOTP(for phoneNumber: String) async throws -> AuthOTPChallenge {
        try await authService.requestOTP(for: phoneNumber)
    }

    func resendOTP(for challengeID: String) async throws -> AuthOTPChallenge {
        try await authService.resendOTP(for: challengeID)
    }

    func verifyOTP(_ code: String, challengeID: String) async throws -> AuthVerificationResult {
        try await authService.verifyOTP(code, challengeID: challengeID)
    }

    func signIn(withPassword password: String, for session: AuthenticatedPhoneSession) async throws -> AppUser {
        try await authService.signIn(withPassword: password, for: session)
    }

    func completeOnboarding(_ submission: AuthOnboardingSubmission, for session: AuthenticatedPhoneSession) async throws -> AppUser {
        let profilePhotoURL: URL?
        if let profilePhotoData = submission.profilePhotoData {
            profilePhotoURL = try await storageService.upload(
                data: profilePhotoData,
                path: "profile-photos/\(session.userID).jpg"
            )
        } else {
            profilePhotoURL = nil
        }

        return try await authService.completeOnboarding(
            for: session,
            fullName: submission.fullName,
            passwordHash: submission.passwordHash,
            roles: submission.selectedRoles,
            acceptsTerms: submission.acceptsTerms,
            acceptsPrivacy: submission.acceptsPrivacy,
            profilePhotoURL: profilePhotoURL
        )
    }

    func signOut() async throws {
        try await authService.signOut()
    }
}

actor MockListingsRepository: ListingsRepositoryProtocol {
    private var listings: [Listing]

    init(seedListings: [Listing] = PreviewData.featuredListings + PreviewData.ownerListings) {
        self.listings = seedListings
    }

    func fetchExploreListings() async throws -> [Listing] {
        listings.filter { $0.status == .active || $0.status == .assigned || $0.status == .agreementPending || $0.status == .occupied }
    }

    func fetchOwnerListings(ownerID: String) async throws -> [Listing] {
        listings
            .filter { $0.ownerID == ownerID }
            .sorted { $0.availableFrom < $1.availableFrom }
    }

    func createListing(_ listing: Listing) async throws {
        listings.insert(listing, at: 0)
    }

    func updateListing(_ listing: Listing) async throws {
        guard let index = listings.firstIndex(where: { $0.id == listing.id && $0.ownerID == listing.ownerID }) else { return }
        listings[index] = listing
    }

    func pauseListing(id: String, ownerID: String) async throws {
        guard let index = listings.firstIndex(where: { $0.id == id && $0.ownerID == ownerID }) else { return }
        let original = listings[index]
        listings[index] = Listing(
            id: original.id,
            ownerID: original.ownerID,
            title: original.title,
            description: original.description,
            approximateLocation: original.approximateLocation,
            exactAddress: original.location.exactAddress,
            exactAddressMasked: original.exactAddressMasked,
            monthlyRent: original.monthlyRent,
            securityDeposit: original.pricing.securityDeposit,
            bedroomCount: original.roomCount,
            floor: original.floor,
            propertyType: original.propertyType,
            listingScope: original.listingScope,
            furnishing: original.furnishing,
            parkingAvailable: original.parkingAvailable,
            wifiAvailable: original.wifiAvailable,
            petAllowed: original.petAllowed,
            tenantPreference: original.tenantPreference,
            locationRadiusInKM: original.locationRadiusInKM,
            availableFrom: original.availableFrom,
            minimumStayMonths: original.minimumStayMonths,
            utilities: original.utilities,
            smokingAllowed: original.rules.smokingAllowed,
            visitorsAllowed: original.rules.visitorsAllowed,
            quietHours: original.rules.quietHours,
            latitude: original.location.latitude,
            longitude: original.location.longitude,
            media: original.media,
            status: .paused,
            similarListingIDs: original.similarListingIDs
        )
    }

    func duplicateListing(id: String, ownerID: String) async throws -> Listing {
        guard let listing = listings.first(where: { $0.id == id && $0.ownerID == ownerID }) else {
            return PreviewData.ownerListings[0]
        }

        let duplicated = Listing(
            id: "\(listing.id)-COPY-\(Int.random(in: 100...999))",
            ownerID: ownerID,
            title: "Copy of \(listing.title)",
            description: listing.description,
            approximateLocation: listing.approximateLocation,
            exactAddress: listing.location.exactAddress,
            exactAddressMasked: listing.exactAddressMasked,
            monthlyRent: listing.monthlyRent,
            securityDeposit: listing.pricing.securityDeposit,
            bedroomCount: listing.roomCount,
            floor: listing.floor,
            propertyType: listing.propertyType,
            listingScope: listing.listingScope,
            furnishing: listing.furnishing,
            parkingAvailable: listing.parkingAvailable,
            wifiAvailable: listing.wifiAvailable,
            petAllowed: listing.petAllowed,
            tenantPreference: listing.tenantPreference,
            locationRadiusInKM: listing.locationRadiusInKM,
            availableFrom: listing.availableFrom,
            minimumStayMonths: listing.minimumStayMonths,
            utilities: listing.utilities,
            smokingAllowed: listing.rules.smokingAllowed,
            visitorsAllowed: listing.rules.visitorsAllowed,
            quietHours: listing.rules.quietHours,
            latitude: listing.location.latitude,
            longitude: listing.location.longitude,
            media: listing.media,
            status: .draft,
            similarListingIDs: listing.similarListingIDs
        )

        listings.insert(duplicated, at: 0)
        return duplicated
    }
}

actor MockProfileRepository: ProfileRepositoryProtocol {
    private var bundlesByUserID: [String: UserProfileBundle]

    init(seedData: [String: UserProfileBundle] = PreviewData.profileBundles) {
        self.bundlesByUserID = seedData
    }

    func fetchProfiles(for userID: String) async throws -> UserProfileBundle {
        bundlesByUserID[userID, default: .init(renterProfile: nil, ownerProfile: nil)]
    }

    func saveRenterProfile(_ profile: RenterProfile, for userID: String) async throws {
        let current = bundlesByUserID[userID, default: .init(renterProfile: nil, ownerProfile: nil)]
        bundlesByUserID[userID] = UserProfileBundle(renterProfile: profile, ownerProfile: current.ownerProfile)
    }

    func saveOwnerProfile(_ profile: OwnerProfile, for userID: String) async throws {
        let current = bundlesByUserID[userID, default: .init(renterProfile: nil, ownerProfile: nil)]
        bundlesByUserID[userID] = UserProfileBundle(renterProfile: current.renterProfile, ownerProfile: profile)
    }
}
