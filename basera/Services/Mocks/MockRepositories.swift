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

    func updateListingStatus(id: String, ownerID: String, status: Listing.Status) async throws {
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
            status: status,
            similarListingIDs: original.similarListingIDs
        )
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

actor MockInterestsRepository: InterestsRepositoryProtocol {
    private var interests: [InterestRequest]
    private var conversations: [ChatConversation]
    private var messagesByConversationID: [String: [ChatMessage]]
    private var visits: [PropertyVisitSchedule]
    private var assignmentsByListingID: [String: ListingAssignment]

    init(
        interests: [InterestRequest] = PreviewData.mockInterests,
        conversations: [ChatConversation] = PreviewData.mockConversations,
        messagesByConversationID: [String: [ChatMessage]] = PreviewData.mockMessagesByConversationID,
        visits: [PropertyVisitSchedule] = PreviewData.mockVisits,
        assignmentsByListingID: [String: ListingAssignment] = PreviewData.mockAssignmentsByListingID
    ) {
        self.interests = interests
        self.conversations = conversations
        self.messagesByConversationID = messagesByConversationID
        self.visits = visits
        self.assignmentsByListingID = assignmentsByListingID
    }

    func submitInterest(_ draft: InterestSubmissionDraft) async throws -> InterestRequest {
        let request = InterestRequest(
            id: "INT-\(UUID().uuidString.prefix(8))",
            listingID: draft.listingID,
            ownerID: draft.ownerID,
            renterID: draft.renterID,
            renterSnapshot: draft.renterSnapshot,
            submittedMessage: draft.optionalMessage,
            submittedAt: .now,
            status: .pending,
            chatApproval: .unavailable
        )
        interests.insert(request, at: 0)
        return request
    }

    func fetchInterests(for listingID: String, ownerID: String) async throws -> [InterestRequest] {
        interests
            .filter { $0.listingID == listingID && $0.ownerID == ownerID }
            .sorted { $0.submittedAt > $1.submittedAt }
    }

    func fetchInterests(for renterID: String) async throws -> [InterestRequest] {
        interests
            .filter { $0.renterID == renterID }
            .sorted { $0.submittedAt > $1.submittedAt }
    }

    func updateInterestStatus(interestID: String, ownerID: String, status: InterestRequest.Status) async throws {
        guard let idx = interests.firstIndex(where: { $0.id == interestID && $0.ownerID == ownerID }) else { return }
        interests[idx].status = status
        if status == .rejected {
            interests[idx].chatApproval = .unavailable
        }
        if status == .accepted, interests[idx].chatApproval == .unavailable {
            interests[idx].chatApproval = .awaitingOwnerApproval
        }
    }

    func approveChat(interestID: String, ownerID: String) async throws {
        guard let idx = interests.firstIndex(where: { $0.id == interestID && $0.ownerID == ownerID }) else { return }
        guard interests[idx].status == .accepted else { return }

        interests[idx].chatApproval = .approved
        let interest = interests[idx]

        guard !conversations.contains(where: { $0.interestID == interestID }) else { return }

        let conversation = ChatConversation(
            id: "CHAT-\(UUID().uuidString.prefix(6))",
            listingID: interest.listingID,
            ownerID: interest.ownerID,
            renterID: interest.renterID,
            participantName: interest.renterSnapshot.fullName,
            listingTitle: "Listing \(interest.listingID)",
            interestID: interest.id,
            lastMessagePreview: "Chat approved. You can now coordinate visit details.",
            lastUpdatedAt: .now,
            unreadCount: 1
        )
        conversations.insert(conversation, at: 0)
        messagesByConversationID[conversation.id] = [
            ChatMessage(
                id: "MSG-\(UUID().uuidString.prefix(6))",
                conversationID: conversation.id,
                senderID: ownerID,
                body: "Hi, chat is now approved. Let us coordinate a visit.",
                sentAt: .now
            )
        ]
    }

    func scheduleVisit(_ draft: VisitScheduleDraft) async throws -> PropertyVisitSchedule {
        let visit = PropertyVisitSchedule(
            id: "VIS-\(UUID().uuidString.prefix(8))",
            listingID: draft.listingID,
            ownerID: draft.ownerID,
            renterID: draft.renterID,
            note: draft.note,
            scheduledAt: draft.scheduledAt,
            status: .proposed,
            updatedAt: .now
        )
        visits.removeAll { $0.listingID == draft.listingID && $0.renterID == draft.renterID && $0.status == .proposed }
        visits.insert(visit, at: 0)
        return visit
    }

    func fetchVisits(listingID: String, ownerID: String) async throws -> [PropertyVisitSchedule] {
        visits
            .filter { $0.listingID == listingID && $0.ownerID == ownerID }
            .sorted { $0.scheduledAt < $1.scheduledAt }
    }

    func fetchVisits(renterID: String) async throws -> [PropertyVisitSchedule] {
        visits
            .filter { $0.renterID == renterID }
            .sorted { $0.scheduledAt < $1.scheduledAt }
    }

    func confirmVisit(visitID: String, renterID: String) async throws {
        guard let idx = visits.firstIndex(where: { $0.id == visitID && $0.renterID == renterID }) else { return }
        let existing = visits[idx]
        visits[idx] = PropertyVisitSchedule(
            id: existing.id,
            listingID: existing.listingID,
            ownerID: existing.ownerID,
            renterID: existing.renterID,
            note: existing.note,
            scheduledAt: existing.scheduledAt,
            status: .confirmed,
            updatedAt: .now
        )
    }

    func requestAssignment(_ draft: AssignmentRequestDraft) async throws -> ListingAssignment {
        guard assignmentsByListingID[draft.listingID] == nil || assignmentsByListingID[draft.listingID]?.status != .requested else {
            return assignmentsByListingID[draft.listingID]!
        }

        let assignment = ListingAssignment(
            id: "ASN-\(UUID().uuidString.prefix(8))",
            listingID: draft.listingID,
            ownerID: draft.ownerID,
            renterID: draft.renterID,
            interestID: draft.interestID,
            requestedAt: .now,
            status: .requested,
            note: draft.note
        )
        assignmentsByListingID[draft.listingID] = assignment
        return assignment
    }

    func fetchAssignment(listingID: String, ownerID: String) async throws -> ListingAssignment? {
        guard let assignment = assignmentsByListingID[listingID], assignment.ownerID == ownerID else { return nil }
        return assignment
    }

    func fetchAssignment(renterID: String) async throws -> ListingAssignment? {
        assignmentsByListingID.values.first(where: { $0.renterID == renterID })
    }

    func respondToAssignment(assignmentID: String, renterID: String, accept: Bool) async throws {
        guard let listingID = assignmentsByListingID.values.first(where: { $0.id == assignmentID && $0.renterID == renterID })?.listingID,
              let assignment = assignmentsByListingID[listingID] else { return }
        assignmentsByListingID[listingID] = ListingAssignment(
            id: assignment.id,
            listingID: assignment.listingID,
            ownerID: assignment.ownerID,
            renterID: assignment.renterID,
            interestID: assignment.interestID,
            requestedAt: assignment.requestedAt,
            status: accept ? .accepted : .declined,
            note: assignment.note
        )
    }

    func fetchConversations(for userID: String) async throws -> [ChatConversation] {
        conversations
            .filter { $0.ownerID == userID || $0.renterID == userID }
            .sorted { $0.lastUpdatedAt > $1.lastUpdatedAt }
    }

    func fetchMessages(conversationID: String, userID: String) async throws -> [ChatMessage] {
        guard let conversation = conversations.first(where: { $0.id == conversationID }) else { return [] }
        guard conversation.ownerID == userID || conversation.renterID == userID else { return [] }
        return messagesByConversationID[conversationID, default: []].sorted { $0.sentAt < $1.sentAt }
    }

    func sendMessage(conversationID: String, senderID: String, body: String) async throws {
        guard !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard let idx = conversations.firstIndex(where: { $0.id == conversationID }) else { return }
        guard conversations[idx].ownerID == senderID || conversations[idx].renterID == senderID else { return }

        let message = ChatMessage(
            id: "MSG-\(UUID().uuidString.prefix(6))",
            conversationID: conversationID,
            senderID: senderID,
            body: body,
            sentAt: .now
        )
        messagesByConversationID[conversationID, default: []].append(message)

        let existing = conversations[idx]
        conversations[idx] = ChatConversation(
            id: existing.id,
            listingID: existing.listingID,
            ownerID: existing.ownerID,
            renterID: existing.renterID,
            participantName: existing.participantName,
            listingTitle: existing.listingTitle,
            interestID: existing.interestID,
            lastMessagePreview: body,
            lastUpdatedAt: .now,
            unreadCount: existing.unreadCount + 1
        )
    }

    func fetchNotificationBadges(userID: String) async throws -> InterestNotificationBadge {
        InterestNotificationBadge(
            ownerPendingInterests: interests.filter { $0.ownerID == userID && $0.status == .pending }.count,
            renterPendingResponses: interests.filter { $0.renterID == userID && $0.status == .pending }.count,
            renterChatApprovals: interests.filter { $0.renterID == userID && $0.chatApproval == .approved }.count
        )
    }
}
