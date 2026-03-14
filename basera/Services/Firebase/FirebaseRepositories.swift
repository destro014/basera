import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

struct FirebaseAuthRepository: AuthRepositoryProtocol {
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func restoreSession() async throws -> AppUser? {
        try await authService.currentUser()
    }

    func signIn(email: String, password: String) async throws -> AuthSignInResult {
        try await authService.signIn(email: email, password: password)
    }

    func startEmailRegistration(email: String) async throws -> AuthEmailVerificationChallenge {
        try await authService.startEmailRegistration(email: email)
    }

    func resendEmailRegistrationCode(for challengeID: String) async throws -> AuthEmailVerificationChallenge {
        try await authService.resendEmailRegistrationCode(for: challengeID)
    }

    func verifyEmailRegistrationCode(_ code: String, challengeID: String) async throws -> AuthenticatedEmailSession {
        try await authService.verifyEmailRegistrationCode(code, challengeID: challengeID)
    }

    func setRegistrationPassword(_ password: String, for session: AuthenticatedEmailSession) async throws -> AuthenticatedEmailSession {
        try await authService.setRegistrationPassword(password, for: session)
    }

    func completeProfileSetup(_ submission: AuthProfileSetupSubmission, for session: AuthenticatedEmailSession) async throws -> AppUser {
        let profilePhotoURL: URL? = nil
        return try await authService.completeProfileSetup(submission, for: session, profilePhotoURL: profilePhotoURL)
    }

    func startPasswordRecovery(email: String) async throws -> AuthPasswordRecoveryChallenge {
        try await authService.startPasswordRecovery(email: email)
    }

    func resendPasswordRecoveryCode(for challengeID: String) async throws -> AuthPasswordRecoveryChallenge {
        try await authService.resendPasswordRecoveryCode(for: challengeID)
    }

    func verifyPasswordRecoveryCode(_ code: String, challengeID: String) async throws -> AuthPasswordResetSession {
        try await authService.verifyPasswordRecoveryCode(code, challengeID: challengeID)
    }

    func completePasswordRecovery(newPassword: String, for session: AuthPasswordResetSession) async throws {
        try await authService.completePasswordRecovery(newPassword: newPassword, for: session)
    }

    func signOut() async throws {
        try await authService.signOut()
    }
}

actor FirebaseListingsRepository: ListingsRepositoryProtocol {
    private let firestoreService: FirestoreServiceProtocol

    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }

    func fetchExploreListings() async throws -> [Listing] {
        let rows = try await firestoreService.fetchCollection(path: "listings")
        return rows
            .compactMap(FirebaseListingMapper.listing(from:))
            .filter { Listing.Status.discoverableStatuses.contains($0.status) }
    }

    func fetchOwnerListings(ownerID: String) async throws -> [Listing] {
        let rows = try await firestoreService.queryCollection(path: "listings", field: "ownerID", isEqualTo: ownerID)
        return rows.compactMap(FirebaseListingMapper.listing(from:)).sorted { $0.availableFrom < $1.availableFrom }
    }

    func createListing(_ listing: Listing) async throws {
        try await firestoreService.setDocument(path: "listings/\(listing.id)", data: FirebaseListingMapper.payload(from: listing))
        // TODO: Persist listing photos/videos to Firebase Storage once binary media pipeline is introduced.
    }

    func updateListing(_ listing: Listing) async throws {
        try await firestoreService.setDocument(path: "listings/\(listing.id)", data: FirebaseListingMapper.payload(from: listing))
    }

    func pauseListing(id: String, ownerID: String) async throws {
        try await updateListingStatus(id: id, ownerID: ownerID, status: .paused)
    }

    func duplicateListing(id: String, ownerID: String) async throws -> Listing {
        guard let original = try await fetchOwnerListings(ownerID: ownerID).first(where: { $0.id == id }) else {
            throw FirebaseServiceError.missingDocument("listings/\(id)")
        }

        let duplicate = original.duplicating(
            for: ownerID,
            id: "\(original.id)-COPY-\(Int.random(in: 100...999))",
            status: .draft
        )
        try await createListing(duplicate)
        return duplicate
    }

    func updateListingStatus(id: String, ownerID: String, status: Listing.Status) async throws {
        guard let listing = try await fetchOwnerListings(ownerID: ownerID).first(where: { $0.id == id }) else { return }
        let updated = listing.updating(status: status)
        try await updateListing(updated)
    }
}

actor FirebaseProfileRepository: ProfileRepositoryProtocol {
    private let firestoreService: FirestoreServiceProtocol

    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }

    func fetchProfiles(for userID: String) async throws -> UserProfileBundle {
        let renter = try? await firestoreService.fetchDocument(path: "renter_profiles/\(userID)")
        let owner = try? await firestoreService.fetchDocument(path: "owner_profiles/\(userID)")
        return UserProfileBundle(
            renterProfile: renter.flatMap(FirebaseProfileMapper.renterProfile(from:)),
            ownerProfile: owner.flatMap(FirebaseProfileMapper.ownerProfile(from:))
        )
    }

    func saveRenterProfile(_ profile: RenterProfile, for userID: String) async throws {
        try await firestoreService.setDocument(path: "renter_profiles/\(userID)", data: FirebaseProfileMapper.payload(from: profile))
    }

    func saveOwnerProfile(_ profile: OwnerProfile, for userID: String) async throws {
        try await firestoreService.setDocument(path: "owner_profiles/\(userID)", data: FirebaseProfileMapper.payload(from: profile))
        // TODO: Add dedicated upload endpoints for front/back national ID images and write resulting URLs here.
    }
}

actor FirebaseNotificationsRepository: NotificationsRepositoryProtocol {
    private let notificationsService: NotificationsServiceProtocol
    private let firestoreService: FirestoreServiceProtocol

    init(notificationsService: NotificationsServiceProtocol, firestoreService: FirestoreServiceProtocol) {
        self.notificationsService = notificationsService
        self.firestoreService = firestoreService
    }

    func registerForPushNotifications() async {
        await notificationsService.registerForPushNotifications()
    }

    func syncIncomingNotifications(for userID: String) async {
        let payloads = await notificationsService.fetchPendingPayloads(for: userID)
        for payload in payloads {
            let data: [String: Any] = [
                "id": payload.id,
                "userID": payload.userID,
                "audience": NotificationAudience.both.rawValue,
                "type": payload.type.rawValue,
                "title": payload.title,
                "message": payload.message,
                "createdAt": payload.createdAt,
                "route": payload.route.id,
                "metadata": payload.metadata
            ]
            try? await firestoreService.setDocument(path: "notifications/\(payload.id)", data: data)
        }
    }

    func fetchNotifications(for userID: String) async throws -> [AppNotification] {
        let rows = try await firestoreService.queryCollection(path: "notifications", field: "userID", isEqualTo: userID)
        return rows.compactMap(FirebaseNotificationMapper.notification(from:)).sorted { $0.createdAt > $1.createdAt }
    }

    func fetchBadgeState(for userID: String) async throws -> NotificationBadgeState {
        let unread = try await fetchNotifications(for: userID).filter(\.isUnread).count
        return NotificationBadgeState(unreadCount: unread)
    }

    func markAsRead(notificationID: String, userID: String) async throws {
        _ = userID
        try await firestoreService.setDocument(path: "notifications/\(notificationID)", data: ["readAt": Date()])
    }

    func markAllAsRead(for userID: String) async throws {
        let notifications = try await fetchNotifications(for: userID)
        for notification in notifications where notification.isUnread {
            try await markAsRead(notificationID: notification.id, userID: userID)
        }
    }
}


private enum FirebaseFieldValueDecoder {
    static func date(_ value: Any?) -> Date? {
        if let date = value as? Date { return date }
        #if canImport(FirebaseFirestore)
        if let timestamp = value as? Timestamp { return timestamp.dateValue() }
        #endif
        return nil
    }
}

enum FirebaseListingMapper {
    static func listing(from payload: [String: Any]) -> Listing? {
        guard
            let id = payload["id"] as? String,
            let ownerID = payload["ownerID"] as? String,
            let title = payload["title"] as? String,
            let description = payload["description"] as? String,
            let approximate = payload["approximateAddress"] as? String,
            let exactMasked = payload["exactAddressMasked"] as? String,
            let monthlyRent = payload["monthlyRent"] as? Int,
            let roomCount = payload["roomCount"] as? Int,
            let propertyTypeRaw = payload["propertyType"] as? String,
            let propertyType = Listing.PropertyType(rawValue: propertyTypeRaw),
            let furnishingRaw = payload["furnishing"] as? String,
            let furnishing = Listing.Furnishing(rawValue: furnishingRaw),
            let tenantPrefRaw = payload["tenantPreference"] as? String,
            let tenantPreference = Listing.TenantPreference(rawValue: tenantPrefRaw)
        else { return nil }

        let listingScope = Listing.ListingScope(rawValue: payload["listingScope"] as? String ?? "") ?? .fullProperty
        let status = Listing.Status(rawValue: payload["status"] as? String ?? "") ?? .draft

        return Listing(
            id: id,
            ownerID: ownerID,
            title: title,
            description: description,
            approximateLocation: approximate,
            exactAddress: payload["exactAddress"] as? String ?? "",
            exactAddressMasked: exactMasked,
            monthlyRent: monthlyRent,
            securityDeposit: payload["securityDeposit"] as? Int ?? 0,
            bedroomCount: roomCount,
            floor: payload["floor"] as? Int ?? 1,
            propertyType: propertyType,
            listingScope: listingScope,
            furnishing: furnishing,
            parkingAvailable: payload["parkingAvailable"] as? Bool ?? false,
            wifiAvailable: payload["wifiAvailable"] as? Bool ?? false,
            petAllowed: payload["petAllowed"] as? Bool ?? false,
            tenantPreference: tenantPreference,
            locationRadiusInKM: payload["locationRadiusInKM"] as? Int ?? 3,
            availableFrom: FirebaseFieldValueDecoder.date(payload["availableFrom"]) ?? .now,
            minimumStayMonths: payload["minimumStayMonths"] as? Int ?? 6,
            utilities: Listing.Utilities(
                electricityIncluded: payload["electricityIncluded"] as? Bool ?? false,
                waterIncluded: payload["waterIncluded"] as? Bool ?? false,
                internetIncluded: payload["internetIncluded"] as? Bool ?? false
            ),
            smokingAllowed: payload["smokingAllowed"] as? Bool ?? false,
            visitorsAllowed: payload["visitorsAllowed"] as? Bool ?? true,
            quietHours: payload["quietHours"] as? String ?? "10 PM - 6 AM",
            latitude: payload["latitude"] as? Double ?? 27.7172,
            longitude: payload["longitude"] as? Double ?? 85.3240,
            media: [],
            status: status,
            similarListingIDs: payload["similarListingIDs"] as? [String] ?? []
        )
    }

    static func payload(from listing: Listing) -> [String: Any] {
        [
            "id": listing.id,
            "ownerID": listing.ownerID,
            "title": listing.title,
            "description": listing.description,
            "propertyType": listing.propertyType.rawValue,
            "listingScope": listing.listingScope.rawValue,
            "approximateAddress": listing.approximateLocation,
            "exactAddress": listing.location.exactAddress,
            "exactAddressMasked": listing.exactAddressMasked,
            "monthlyRent": listing.monthlyRent,
            "securityDeposit": listing.pricing.securityDeposit,
            "roomCount": listing.roomCount,
            "floor": listing.floor,
            "furnishing": listing.furnishing.rawValue,
            "parkingAvailable": listing.parkingAvailable,
            "wifiAvailable": listing.wifiAvailable,
            "petAllowed": listing.petAllowed,
            "tenantPreference": listing.tenantPreference.rawValue,
            "locationRadiusInKM": listing.locationRadiusInKM,
            "availableFrom": listing.availableFrom,
            "minimumStayMonths": listing.minimumStayMonths,
            "electricityIncluded": listing.utilities.electricityIncluded,
            "waterIncluded": listing.utilities.waterIncluded,
            "internetIncluded": listing.utilities.internetIncluded,
            "smokingAllowed": listing.rules.smokingAllowed,
            "visitorsAllowed": listing.rules.visitorsAllowed,
            "quietHours": listing.rules.quietHours,
            "latitude": listing.location.latitude,
            "longitude": listing.location.longitude,
            "status": listing.status.rawValue,
            "similarListingIDs": listing.similarListingIDs,
            "updatedAt": Date()
        ]
    }
}

enum FirebaseProfileMapper {
    static func renterProfile(from payload: [String: Any]) -> RenterProfile? {
        guard
            let fullName = payload["fullName"] as? String,
            let phoneNumber = payload["phoneNumber"] as? String,
            let email = payload["email"] as? String,
            let occupation = payload["occupation"] as? String,
            let familySize = payload["familySize"] as? Int,
            let hasPets = payload["hasPets"] as? Bool,
            let smokingRaw = payload["smokingStatus"] as? String,
            let smokingStatus = SmokingStatus(rawValue: smokingRaw)
        else { return nil }

        return RenterProfile(
            fullName: fullName,
            phoneNumber: phoneNumber,
            email: email,
            profilePhotoURL: (payload["profilePhotoURL"] as? String).flatMap(URL.init(string:)),
            occupation: occupation,
            familySize: familySize,
            hasPets: hasPets,
            smokingStatus: smokingStatus
        )
    }

    static func ownerProfile(from payload: [String: Any]) -> OwnerProfile? {
        guard
            let fullName = payload["fullName"] as? String,
            let phoneNumber = payload["phoneNumber"] as? String,
            let email = payload["email"] as? String,
            let address = payload["address"] as? String
        else { return nil }

        let paymentDetails = OwnerPaymentDetails(
            bankName: payload["bankName"] as? String ?? "",
            accountName: payload["accountName"] as? String ?? "",
            accountNumber: payload["accountNumber"] as? String ?? "",
            esewaID: payload["esewaID"] as? String ?? "",
            fonepayNumber: payload["fonepayNumber"] as? String ?? ""
        )

        return OwnerProfile(
            fullName: fullName,
            phoneNumber: phoneNumber,
            email: email,
            profilePhotoURL: (payload["profilePhotoURL"] as? String).flatMap(URL.init(string:)),
            address: address,
            idDocumentState: DocumentUploadState(
                frontUploaded: payload["idFrontUploaded"] as? Bool ?? false,
                backUploaded: payload["idBackUploaded"] as? Bool ?? false
            ),
            paymentDetails: paymentDetails
        )
    }

    static func payload(from profile: RenterProfile) -> [String: Any] {
        [
            "fullName": profile.fullName,
            "phoneNumber": profile.phoneNumber,
            "email": profile.email,
            "profilePhotoURL": profile.profilePhotoURL?.absoluteString ?? NSNull(),
            "occupation": profile.occupation,
            "familySize": profile.familySize,
            "hasPets": profile.hasPets,
            "smokingStatus": profile.smokingStatus.rawValue,
            "updatedAt": Date()
        ]
    }

    static func payload(from profile: OwnerProfile) -> [String: Any] {
        [
            "fullName": profile.fullName,
            "phoneNumber": profile.phoneNumber,
            "email": profile.email,
            "profilePhotoURL": profile.profilePhotoURL?.absoluteString ?? NSNull(),
            "address": profile.address,
            "idFrontUploaded": profile.idDocumentState.frontUploaded,
            "idBackUploaded": profile.idDocumentState.backUploaded,
            "bankName": profile.paymentDetails.bankName,
            "accountName": profile.paymentDetails.accountName,
            "accountNumber": profile.paymentDetails.accountNumber,
            "esewaID": profile.paymentDetails.esewaID,
            "fonepayNumber": profile.paymentDetails.fonepayNumber,
            "updatedAt": Date()
        ]
    }
}

enum FirebaseNotificationMapper {
    static func notification(from payload: [String: Any]) -> AppNotification? {
        guard
            let id = payload["id"] as? String,
            let userID = payload["userID"] as? String,
            let audienceRaw = payload["audience"] as? String,
            let audience = NotificationAudience(rawValue: audienceRaw),
            let typeRaw = payload["type"] as? String,
            let type = NotificationType(rawValue: typeRaw),
            let title = payload["title"] as? String,
            let message = payload["message"] as? String
        else { return nil }

        return AppNotification(
            id: id,
            userID: userID,
            audience: audience,
            type: type,
            title: title,
            message: message,
            createdAt: FirebaseFieldValueDecoder.date(payload["createdAt"]) ?? .now,
            readAt: FirebaseFieldValueDecoder.date(payload["readAt"]),
            route: .interests(listingID: nil),
            metadata: payload["metadata"] as? [String: String] ?? [:]
        )
    }
}
