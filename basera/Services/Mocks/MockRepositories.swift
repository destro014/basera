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

actor MockAgreementsRepository: AgreementsRepositoryProtocol {
    private var agreements: [AgreementRecord]
    private var pendingTypedNames: [String: [AgreementRecord.Party: String]] = [:]

    private let confirmationService: AgreementConfirmationServiceProtocol

    init(
        confirmationService: AgreementConfirmationServiceProtocol,
        seed: [AgreementRecord] = PreviewData.mockAgreements
    ) {
        self.confirmationService = confirmationService
        self.agreements = seed
    }

    func fetchAgreements(for userID: String, as party: AgreementRecord.Party) async throws -> [AgreementRecord] {
        agreements
            .filter { agreement in
                switch party {
                case .owner: agreement.owner.userID == userID
                case .renter: agreement.renter.userID == userID
                }
            }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    func fetchAgreement(id: String, userID: String) async throws -> AgreementRecord? {
        agreements.first { $0.id == id && ($0.owner.userID == userID || $0.renter.userID == userID) }
    }

    func createAgreementDraft(_ draft: AgreementDraftInput) async throws -> AgreementRecord {
        let now = Date()
        let agreement = AgreementRecord(
            id: "AGR-\(UUID().uuidString.prefix(8))",
            tenancyID: draft.tenancyID,
            previousAgreementID: nil,
            version: 1,
            owner: draft.owner,
            renter: draft.renter,
            property: draft.property,
            terms: draft.terms,
            status: .draft,
            signatures: .init(owner: nil, renter: nil),
            statusHistory: [
                .init(id: UUID().uuidString, title: "Draft created", happenedAt: now, detail: "Owner started drafting agreement")
            ],
            createdAt: now,
            updatedAt: now
        )
        agreements.insert(agreement, at: 0)
        return agreement
    }

    func updateAgreementTerms(agreementID: String, editorID: String, terms: AgreementRecord.Terms) async throws -> AgreementRecord {
        guard let index = agreements.firstIndex(where: { $0.id == agreementID }) else { throw AgreementRepositoryError.notFound }
        guard agreements[index].isLocked == false else { throw AgreementRepositoryError.locked }
        guard agreements[index].owner.userID == editorID else { throw AgreementRepositoryError.forbidden }
        agreements[index].terms = terms
        agreements[index].updatedAt = Date()
        return agreements[index]
    }

    func submitForSignature(agreementID: String, ownerID: String) async throws -> AgreementRecord {
        guard let index = agreements.firstIndex(where: { $0.id == agreementID }) else { throw AgreementRepositoryError.notFound }
        guard agreements[index].owner.userID == ownerID else { throw AgreementRepositoryError.forbidden }
        agreements[index].status = .pendingOwnerSignature
        agreements[index].updatedAt = Date()
        agreements[index].statusHistory.append(
            .init(id: UUID().uuidString, title: "Sent for signing", happenedAt: .now, detail: "Owner submitted agreement for digital confirmation")
        )
        return agreements[index]
    }

    func confirmTypedName(agreementID: String, userID: String, typedName: String) async throws -> AgreementRecord.Party {
        guard let agreement = agreements.first(where: { $0.id == agreementID }) else { throw AgreementRepositoryError.notFound }
        let party: AgreementRecord.Party
        if agreement.owner.userID == userID {
            guard typedName.caseInsensitiveCompare(agreement.owner.fullName) == .orderedSame else { throw AgreementRepositoryError.invalidTypedName }
            party = .owner
        } else if agreement.renter.userID == userID {
            guard typedName.caseInsensitiveCompare(agreement.renter.fullName) == .orderedSame else { throw AgreementRepositoryError.invalidTypedName }
            party = .renter
        } else {
            throw AgreementRepositoryError.forbidden
        }
        pendingTypedNames[agreementID, default: [:]][party] = typedName
        return party
    }

    func requestAgreementOTP(agreementID: String, userID: String, party: AgreementRecord.Party) async throws -> AgreementOTPChallenge {
        guard let agreement = agreements.first(where: { $0.id == agreementID }) else { throw AgreementRepositoryError.notFound }
        guard party == .owner ? agreement.owner.userID == userID : agreement.renter.userID == userID else {
            throw AgreementRepositoryError.forbidden
        }
        return try await confirmationService.requestOTP(agreementID: agreementID, party: party)
    }

    func verifyAgreementOTP(agreementID: String, userID: String, challengeID: String, code: String) async throws -> AgreementRecord {
        guard let index = agreements.firstIndex(where: { $0.id == agreementID }) else { throw AgreementRepositoryError.notFound }
        guard try await confirmationService.verifyOTP(challengeID: challengeID, code: code) else {
            throw AgreementRepositoryError.invalidOTP
        }

        if agreements[index].owner.userID == userID {
            guard let typedName = pendingTypedNames[agreementID]?[.owner] else { throw AgreementRepositoryError.typedNameRequired }
            agreements[index].signatures.owner = .init(typedName: typedName, signedAt: .now)
            agreements[index].status = .pendingRenterSignature
        } else if agreements[index].renter.userID == userID {
            guard let typedName = pendingTypedNames[agreementID]?[.renter] else { throw AgreementRepositoryError.typedNameRequired }
            agreements[index].signatures.renter = .init(typedName: typedName, signedAt: .now)
            agreements[index].status = agreements[index].signatures.isFullySigned ? .fullySigned : .pendingOwnerSignature
        } else {
            throw AgreementRepositoryError.forbidden
        }

        if agreements[index].signatures.isFullySigned {
            agreements[index].status = .fullySigned
            agreements[index].statusHistory.append(
                .init(id: UUID().uuidString, title: "Agreement signed", happenedAt: .now, detail: "Both parties completed typed-name and OTP confirmation")
            )
        }

        agreements[index].updatedAt = Date()
        return agreements[index]
    }

    func createRenewalDraft(from agreementID: String, ownerID: String) async throws -> AgreementRecord {
        guard let original = agreements.first(where: { $0.id == agreementID }) else { throw AgreementRepositoryError.notFound }
        guard original.owner.userID == ownerID else { throw AgreementRepositoryError.forbidden }

        let now = Date()
        let renewed = AgreementRecord(
            id: "AGR-\(UUID().uuidString.prefix(8))",
            tenancyID: original.tenancyID,
            previousAgreementID: original.id,
            version: original.version + 1,
            owner: original.owner,
            renter: original.renter,
            property: original.property,
            terms: original.terms,
            status: .draft,
            signatures: .init(owner: nil, renter: nil),
            statusHistory: [
                .init(id: UUID().uuidString, title: "Renewal draft created", happenedAt: now, detail: "Created from signed agreement v\(original.version)")
            ],
            createdAt: now,
            updatedAt: now
        )
        agreements.insert(renewed, at: 0)
        return renewed
    }
}

enum AgreementRepositoryError: LocalizedError {
    case notFound
    case forbidden
    case locked
    case invalidTypedName
    case typedNameRequired
    case invalidOTP

    var errorDescription: String? {
        switch self {
        case .notFound: "Agreement not found."
        case .forbidden: "You are not allowed to perform this action."
        case .locked: "Agreement is locked after signing."
        case .invalidTypedName: "Typed name does not match account name."
        case .typedNameRequired: "Typed name confirmation is required before OTP verification."
        case .invalidOTP: "Invalid OTP. Please try again."
        }
    }
}

actor MockTenancyRepository: TenancyRepositoryProtocol {
    private var tenancies: [TenancyRecord]
    private let signedAgreementIDs: Set<String>

    init(
        seed: [TenancyRecord] = PreviewData.mockTenancies,
        signedAgreementIDs: Set<String> = Set(PreviewData.mockAgreements.filter { $0.status == .fullySigned }.map(\.id))
    ) {
        self.tenancies = seed
        self.signedAgreementIDs = signedAgreementIDs
    }

    func fetchActiveTenancy(for renterID: String) async throws -> TenancyRecord? {
        tenancies.first { tenancy in
            tenancy.renterID == renterID &&
            signedAgreementIDs.contains(tenancy.agreementID) &&
            (tenancy.status == .active || tenancy.status == .moveInPending || tenancy.status == .moveOutRequested || tenancy.status == .moveOutUnderReview || tenancy.status == .closureInProgress)
        }
    }

    func fetchActiveTenancies(ownerID: String) async throws -> [TenancyRecord] {
        tenancies
            .filter {
                $0.ownerID == ownerID &&
                signedAgreementIDs.contains($0.agreementID) &&
                ($0.status == .active || $0.status == .moveInPending || $0.status == .moveOutRequested || $0.status == .moveOutUnderReview || $0.status == .closureInProgress)
            }
            .sorted { $0.startDate > $1.startDate }
    }

    func fetchTenancy(id: String, userID: String) async throws -> TenancyRecord? {
        tenancies.first { $0.id == id && ($0.ownerID == userID || $0.renterID == userID) }
    }

    func fetchArchivedTenancies(for userID: String, party: AgreementRecord.Party) async throws -> [TenancyRecord] {
        switch party {
        case .owner:
            tenancies.filter { $0.ownerID == userID && $0.status == .archived }
        case .renter:
            tenancies.filter { $0.renterID == userID && $0.status == .archived }
        }
    }

    func updateMoveInChecklist(tenancyID: String, userID: String, items: [TenancyRecord.MoveInChecklistItem]) async throws -> TenancyRecord {
        guard let index = tenancies.firstIndex(where: { $0.id == tenancyID && ($0.ownerID == userID || $0.renterID == userID) }) else {
            throw AgreementRepositoryError.notFound
        }
        tenancies[index].moveInChecklist = items
        if tenancies[index].status == .moveInPending && items.allSatisfy(\.isCompleted) {
            tenancies[index].status = .active
        }
        return tenancies[index]
    }

    func submitMoveOutRequest(
        tenancyID: String,
        renterID: String,
        requestedDate: Date,
        reason: String,
        conditionNotes: String,
        photoPlaceholders: [String]
    ) async throws -> TenancyRecord {
        guard let index = tenancies.firstIndex(where: { $0.id == tenancyID }) else { throw AgreementRepositoryError.notFound }
        guard tenancies[index].renterID == renterID else { throw AgreementRepositoryError.forbidden }
        guard tenancies[index].status == .active else { throw AgreementRepositoryError.locked }

        tenancies[index].moveOutRequest = .init(
            requestedByRenterAt: .now,
            requestedMoveOutDate: requestedDate,
            reason: reason,
            conditionNotes: conditionNotes,
            photoPlaceholders: photoPlaceholders,
            ownerDecision: .pending
        )
        tenancies[index].closureState = .requestedByRenter(requestedAt: .now)
        tenancies[index].status = .moveOutRequested
        return tenancies[index]
    }

    func decideMoveOutRequest(tenancyID: String, ownerID: String, approve: Bool, note: String) async throws -> TenancyRecord {
        guard let index = tenancies.firstIndex(where: { $0.id == tenancyID }) else { throw AgreementRepositoryError.notFound }
        guard tenancies[index].ownerID == ownerID else { throw AgreementRepositoryError.forbidden }
        guard var request = tenancies[index].moveOutRequest else { throw AgreementRepositoryError.notFound }

        if approve {
            request.ownerDecision = .approved(approvedAt: .now, note: note)
            tenancies[index].closureState = .ownerApproved(approvedAt: .now)
            tenancies[index].status = .moveOutUnderReview
            if tenancies[index].moveOutChecklist.isEmpty {
                tenancies[index].moveOutChecklist = [
                    .init(id: "MOC-1", title: "Collect keys", isCompleted: false, notes: "", photoPlaceholders: ["Key handover photo"]),
                    .init(id: "MOC-2", title: "Inspect walls, floors, and fixtures", isCompleted: false, notes: "", photoPlaceholders: ["Living room photo", "Kitchen photo"]),
                    .init(id: "MOC-3", title: "Verify appliance condition", isCompleted: false, notes: "", photoPlaceholders: ["Appliance photo"])
                ]
            }
        } else {
            request.ownerDecision = .declined(declinedAt: .now, reason: note)
            tenancies[index].closureState = .none
            tenancies[index].status = .active
        }

        tenancies[index].moveOutRequest = request
        return tenancies[index]
    }

    func updateMoveOutChecklist(
        tenancyID: String,
        userID: String,
        items: [TenancyRecord.MoveOutChecklistItem],
        finalMeterReading: TenancyRecord.FinalMeterReading
    ) async throws -> TenancyRecord {
        guard let index = tenancies.firstIndex(where: { $0.id == tenancyID }) else { throw AgreementRepositoryError.notFound }
        guard tenancies[index].ownerID == userID || tenancies[index].renterID == userID else { throw AgreementRepositoryError.forbidden }
        guard case .approved = tenancies[index].moveOutRequest?.ownerDecision else { throw AgreementRepositoryError.locked }

        tenancies[index].moveOutChecklist = items
        tenancies[index].finalMeterReading = finalMeterReading
        tenancies[index].closureState = .checklistInProgress
        tenancies[index].status = .closureInProgress
        return tenancies[index]
    }

    func submitDepositSettlement(
        tenancyID: String,
        ownerID: String,
        settlement: TenancyRecord.DepositSettlement
    ) async throws -> TenancyRecord {
        guard let index = tenancies.firstIndex(where: { $0.id == tenancyID }) else { throw AgreementRepositoryError.notFound }
        guard tenancies[index].ownerID == ownerID else { throw AgreementRepositoryError.forbidden }
        guard tenancies[index].moveOutChecklist.allSatisfy(\.isCompleted), tenancies[index].moveOutChecklist.isEmpty == false else {
            throw AgreementRepositoryError.locked
        }

        tenancies[index].depositSettlement = settlement
        tenancies[index].depositSummary.plannedRefundAmount = settlement.refundAmount
        tenancies[index].depositSummary.heldAmount = settlement.refundAmount
        tenancies[index].depositSummary.deductionNotes = settlement.summaryNote
        tenancies[index].closureState = .refundPending
        tenancies[index].status = .closureInProgress
        return tenancies[index]
    }

    func closeTenancy(tenancyID: String, ownerID: String) async throws -> TenancyRecord {
        guard let index = tenancies.firstIndex(where: { $0.id == tenancyID }) else { throw AgreementRepositoryError.notFound }
        guard tenancies[index].ownerID == ownerID else { throw AgreementRepositoryError.forbidden }
        guard tenancies[index].canOwnerCloseTenancy else { throw AgreementRepositoryError.locked }

        tenancies[index].status = .archived
        tenancies[index].closureState = .closed(closedAt: .now)
        tenancies[index].historicalAccess = .init(agreementAvailable: true, invoicesAvailable: true, paymentsAvailable: true)
        tenancies[index].listingReactivation = .init(isReady: true, pendingItems: [])
        return tenancies[index]
    }
}


actor MockBillingRepository: BillingRepositoryProtocol {
    private var tenancies: [TenancyRecord]
    private var settingsByTenancyID: [String: BillingTenancySettings]
    private var invoices: [InvoiceRecord]

    init(
        tenancies: [TenancyRecord] = PreviewData.mockTenancies,
        settingsByTenancyID: [String: BillingTenancySettings] = PreviewData.mockBillingSettingsByTenancyID,
        invoices: [InvoiceRecord] = PreviewData.mockInvoices
    ) {
        self.tenancies = tenancies
        self.settingsByTenancyID = settingsByTenancyID
        self.invoices = invoices
    }

    func fetchSettings(tenancyID: String, userID: String) async throws -> BillingTenancySettings? {
        guard let tenancy = tenancy(for: tenancyID) else { return nil }
        guard tenancy.ownerID == userID || tenancy.renterID == userID else { throw BillingRepositoryError.forbidden }
        return settingsByTenancyID[tenancyID] ?? .init(allowsRenterGeneratedBillDraft: false, allowsPartialPayment: true, allowsAdvancePayment: true)
    }

    func updateSettings(tenancyID: String, ownerID: String, settings: BillingTenancySettings) async throws -> BillingTenancySettings {
        guard let tenancy = tenancy(for: tenancyID) else { throw BillingRepositoryError.tenancyNotFound }
        guard tenancy.ownerID == ownerID else { throw BillingRepositoryError.forbidden }
        settingsByTenancyID[tenancyID] = settings
        return settings
    }

    func fetchInvoices(tenancyID: String, userID: String) async throws -> [InvoiceRecord] {
        guard let tenancy = tenancy(for: tenancyID) else { throw BillingRepositoryError.tenancyNotFound }
        guard tenancy.ownerID == userID || tenancy.renterID == userID else { throw BillingRepositoryError.forbidden }
        return invoices
            .filter { $0.header.tenancyID == tenancyID }
            .sorted { $0.header.billingMonth > $1.header.billingMonth }
    }

    func fetchInvoice(id: String, userID: String) async throws -> InvoiceRecord? {
        guard let invoice = invoices.first(where: { $0.id == id }) else { return nil }
        guard invoice.header.ownerID == userID || invoice.header.renterID == userID else { throw BillingRepositoryError.forbidden }
        return invoice
    }

    func previewInvoice(from draft: InvoiceDraftInput, userID: String) async throws -> InvoiceRecord {
        try validateMonthly(draft: draft)
        guard draft.ownerID == userID || draft.renterID == userID else { throw BillingRepositoryError.forbidden }
        let carryForward = currentCarryForward(tenancyID: draft.tenancyID)
        return buildInvoice(id: "PREVIEW", draft: draft, status: statusForDraftCreator(draft), carryForward: carryForward)
    }

    func createInvoice(from draft: InvoiceDraftInput, userID: String) async throws -> InvoiceRecord {
        try validateMonthly(draft: draft)
        guard let tenancy = tenancy(for: draft.tenancyID) else { throw BillingRepositoryError.tenancyNotFound }
        guard draft.ownerID == tenancy.ownerID, draft.renterID == tenancy.renterID else { throw BillingRepositoryError.forbidden }
        guard draft.ownerID == userID || draft.renterID == userID else { throw BillingRepositoryError.forbidden }
        if monthExists(tenancyID: draft.tenancyID, billingMonth: draft.billingMonth) { throw BillingRepositoryError.alreadyExistsForMonth }

        if userID == draft.renterID {
            let settings = settingsByTenancyID[draft.tenancyID] ?? .init(allowsRenterGeneratedBillDraft: false, allowsPartialPayment: true, allowsAdvancePayment: true)
            guard settings.allowsRenterGeneratedBillDraft else { throw BillingRepositoryError.renterDraftDisabled }
        }

        let invoice = buildInvoice(
            id: "INV-\(Int.random(in: 500...999))",
            draft: draft,
            status: statusForDraftCreator(draft),
            carryForward: currentCarryForward(tenancyID: draft.tenancyID)
        )
        invoices.append(invoice)
        return invoice
    }

    func approveInvoice(invoiceID: String, ownerID: String) async throws -> InvoiceRecord {
        guard let index = invoices.firstIndex(where: { $0.id == invoiceID }) else { throw BillingRepositoryError.invoiceNotFound }
        guard invoices[index].header.ownerID == ownerID else { throw BillingRepositoryError.forbidden }
        guard invoices[index].status == .pendingOwnerApproval else { throw BillingRepositoryError.invalidTransition }
        invoices[index].status = .pendingPayment
        invoices[index].updatedAt = .now
        return invoices[index]
    }

    func rejectInvoice(invoiceID: String, ownerID: String, reason: String) async throws -> InvoiceRecord {
        guard let index = invoices.firstIndex(where: { $0.id == invoiceID }) else { throw BillingRepositoryError.invoiceNotFound }
        guard invoices[index].header.ownerID == ownerID else { throw BillingRepositoryError.forbidden }
        guard invoices[index].status == .pendingOwnerApproval else { throw BillingRepositoryError.invalidTransition }
        invoices[index].status = .rejectedByOwner
        invoices[index].rejectionReason = reason
        invoices[index].updatedAt = .now
        return invoices[index]
    }

    func applyPayment(invoiceID: String, amount: Decimal, recordedBy userID: String) async throws -> InvoiceRecord {
        guard amount > 0 else { throw PaymentsRepositoryError.invalidAmount }
        guard let index = invoices.firstIndex(where: { $0.id == invoiceID }) else { throw BillingRepositoryError.invoiceNotFound }
        guard invoices[index].header.ownerID == userID || invoices[index].header.renterID == userID else { throw BillingRepositoryError.forbidden }
        guard invoices[index].status == .pendingPayment || invoices[index].status == .partiallyPaid else { throw BillingRepositoryError.invalidTransition }

        let remainingBefore = invoices[index].amountRemaining
        guard amount <= remainingBefore else { throw PaymentsRepositoryError.invalidAmount }

        invoices[index].paidAmount += amount
        invoices[index].status = invoices[index].amountRemaining == 0 ? .paid : .partiallyPaid
        invoices[index].updatedAt = .now
        return invoices[index]
    }

    private func tenancy(for tenancyID: String) -> TenancyRecord? {
        tenancies.first(where: { $0.id == tenancyID })
    }

    private func monthExists(tenancyID: String, billingMonth: Date) -> Bool {
        let components = Calendar.current.dateComponents([.year, .month], from: billingMonth)
        return invoices.contains { invoice in
            guard invoice.header.tenancyID == tenancyID else { return false }
            let invoiceMonth = Calendar.current.dateComponents([.year, .month], from: invoice.header.billingMonth)
            return invoiceMonth.year == components.year && invoiceMonth.month == components.month
        }
    }

    private func validateMonthly(draft: InvoiceDraftInput) throws {
        let comps = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: draft.billingMonth)
        if (comps.day ?? 1) != 1 || (comps.hour ?? 0) != 0 || (comps.minute ?? 0) != 0 {
            throw BillingRepositoryError.invalidMonth
        }
    }

    private func currentCarryForward(tenancyID: String) -> Decimal {
        invoices
            .filter { $0.header.tenancyID == tenancyID }
            .reduce(Decimal.zero) { partial, invoice in
                partial + invoice.amountRemaining
            }
    }

    private func statusForDraftCreator(_ draft: InvoiceDraftInput) -> InvoiceRecord.Status {
        draft.createdByRole == .owner ? .pendingPayment : .pendingOwnerApproval
    }

    private func buildInvoice(id: String, draft: InvoiceDraftInput, status: InvoiceRecord.Status, carryForward: Decimal) -> InvoiceRecord {
        var items: [InvoiceRecord.Item] = [
            .init(id: UUID().uuidString, category: .rent, title: "Monthly rent", detail: nil, amount: draft.rentAmount)
        ]

        if let electricity = draft.electricityMode {
            items.append(.init(
                id: UUID().uuidString,
                category: .electricity,
                title: "Electricity",
                detail: electricity.detailText,
                amount: electricity.computedAmount
            ))
        }

        items.append(contentsOf: draft.utilityCharges.map {
            .init(
                id: $0.id,
                category: $0.category,
                title: $0.category.title,
                detail: $0.mode.detailText,
                amount: $0.mode.computedAmount
            )
        })

        items.append(contentsOf: draft.otherCharges.map {
            .init(id: $0.id, category: .other, title: $0.title, detail: nil, amount: $0.amount)
        })

        items.append(contentsOf: draft.deductions.map {
            .init(id: $0.id, category: .deduction, title: $0.title, detail: nil, amount: $0.amount)
        })

        items.append(contentsOf: draft.credits.map {
            .init(id: $0.id, category: .credit, title: $0.title, detail: nil, amount: $0.amount)
        })

        return InvoiceRecord(
            id: id,
            header: .init(
                tenancyID: draft.tenancyID,
                listingTitle: draft.listingTitle,
                billingMonth: draft.billingMonth,
                issueDate: .now,
                dueDate: draft.dueDate,
                ownerID: draft.ownerID,
                renterID: draft.renterID
            ),
            createdByRole: draft.createdByRole,
            status: status,
            items: items,
            carryForwardBalance: carryForward,
            paidAmount: 0,
            note: draft.note,
            rejectionReason: nil,
            createdAt: .now,
            updatedAt: .now
        )
    }
}

actor MockPaymentsRepository: PaymentsRepositoryProtocol {
    private let billingRepository: BillingRepositoryProtocol
    private let gatewayService: PaymentGatewayServiceProtocol
    private let tenancies: [TenancyRecord]
    private var paymentMethodsByTenancyID: [String: [PaymentRecord.Method]]
    private var payments: [PaymentRecord]
    private var receipts: [PaymentReceipt]
    private var ledgers: [String: SecurityDepositLedger]

    init(
        billingRepository: BillingRepositoryProtocol,
        gatewayService: PaymentGatewayServiceProtocol,
        tenancies: [TenancyRecord] = PreviewData.mockTenancies,
        paymentMethodsByTenancyID: [String: [PaymentRecord.Method]] = PreviewData.mockPaymentMethodsByTenancyID,
        payments: [PaymentRecord] = PreviewData.mockPayments,
        receipts: [PaymentReceipt] = PreviewData.mockPaymentReceipts,
        ledgers: [String: SecurityDepositLedger] = PreviewData.mockDepositLedgersByTenancyID
    ) {
        self.billingRepository = billingRepository
        self.gatewayService = gatewayService
        self.tenancies = tenancies
        self.paymentMethodsByTenancyID = paymentMethodsByTenancyID
        self.payments = payments
        self.receipts = receipts
        self.ledgers = ledgers
    }

    func fetchPaymentMethods(tenancyID: String, userID: String) async throws -> [PaymentRecord.Method] {
        let tenancy = try authorizedTenancy(tenancyID: tenancyID, userID: userID)
        let _ = tenancy
        return paymentMethodsByTenancyID[tenancyID] ?? PaymentRecord.Method.allCases
    }

    func fetchPayments(tenancyID: String, userID: String) async throws -> [PaymentRecord] {
        let tenancy = try authorizedTenancy(tenancyID: tenancyID, userID: userID)
        let _ = tenancy
        return payments
            .filter { $0.tenancyID == tenancyID }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func fetchReceipts(tenancyID: String, userID: String) async throws -> [PaymentReceipt] {
        let tenancy = try authorizedTenancy(tenancyID: tenancyID, userID: userID)
        let _ = tenancy
        return receipts
            .filter { $0.tenancyID == tenancyID }
            .sorted { $0.issuedAt > $1.issuedAt }
    }

    func fetchDepositLedger(tenancyID: String, userID: String) async throws -> SecurityDepositLedger {
        let tenancy = try authorizedTenancy(tenancyID: tenancyID, userID: userID)
        guard let ledger = ledgers[tenancyID] else {
            return SecurityDepositLedger(
                tenancyID: tenancyID,
                totalDeposit: tenancy.depositSummary.totalDeposit,
                heldAmount: tenancy.depositSummary.heldAmount,
                deductions: [],
                plannedRefundAmount: tenancy.depositSummary.plannedRefundAmount ?? 0,
                refundPaidAmount: 0
            )
        }
        return ledger
    }

    func makeGatewayPayment(
        tenancyID: String,
        invoiceID: String,
        payerUserID: String,
        method: PaymentRecord.Method,
        amount: Decimal,
        note: String
    ) async throws -> PaymentGatewayIntent {
        let tenancy = try authorizedTenancy(tenancyID: tenancyID, userID: payerUserID)
        guard payerUserID == tenancy.renterID else { throw PaymentsRepositoryError.forbidden }
        guard method == .eSewa || method == .fonepay else { throw PaymentsRepositoryError.invalidMethod }
        try await validateInvoiceAmount(invoiceID: invoiceID, tenancyID: tenancyID, amount: amount, userID: payerUserID)

        let paymentID = "PAY-\(Int.random(in: 500...999))"
        let payment = PaymentRecord(
            id: paymentID,
            tenancyID: tenancyID,
            invoiceID: invoiceID,
            payerUserID: payerUserID,
            receiverUserID: tenancy.ownerID,
            method: method,
            state: .initiated,
            kind: .invoice,
            amount: amount,
            offlineMarkedByOwner: false,
            note: note,
            createdAt: .now,
            updatedAt: .now
        )
        payments.append(payment)
        return try await gatewayService.createIntent(paymentID: paymentID, method: method, amount: amount)
    }

    func completeGatewayPayment(paymentID: String, userID: String) async throws -> PaymentRecord {
        guard let index = payments.firstIndex(where: { $0.id == paymentID }) else { throw PaymentsRepositoryError.paymentNotFound }
        guard payments[index].payerUserID == userID else { throw PaymentsRepositoryError.forbidden }
        guard payments[index].state == .initiated || payments[index].state == .pendingVerification else { throw PaymentsRepositoryError.invalidPaymentState }

        payments[index].state = .completed
        payments[index].updatedAt = .now

        if let invoiceID = payments[index].invoiceID {
            _ = try await billingRepository.applyPayment(invoiceID: invoiceID, amount: payments[index].amount, recordedBy: userID)
        }

        receipts.append(buildReceipt(from: payments[index], issuedBy: payments[index].receiverUserID))
        return payments[index]
    }

    func markCashPayment(
        tenancyID: String,
        invoiceID: String,
        ownerID: String,
        amount: Decimal,
        note: String,
        happenedOffline: Bool
    ) async throws -> PaymentRecord {
        let tenancy = try authorizedTenancy(tenancyID: tenancyID, userID: ownerID)
        guard tenancy.ownerID == ownerID else { throw PaymentsRepositoryError.forbidden }
        try await validateInvoiceAmount(invoiceID: invoiceID, tenancyID: tenancyID, amount: amount, userID: ownerID)

        let payment = PaymentRecord(
            id: "PAY-\(Int.random(in: 900...1200))",
            tenancyID: tenancyID,
            invoiceID: invoiceID,
            payerUserID: tenancy.renterID,
            receiverUserID: ownerID,
            method: .cash,
            state: .completed,
            kind: .invoice,
            amount: amount,
            offlineMarkedByOwner: happenedOffline,
            note: note,
            createdAt: .now,
            updatedAt: .now
        )
        payments.append(payment)
        _ = try await billingRepository.applyPayment(invoiceID: invoiceID, amount: amount, recordedBy: ownerID)
        receipts.append(buildReceipt(from: payment, issuedBy: ownerID))
        return payment
    }

    func createAdvancePayment(tenancyID: String, payerUserID: String, method: PaymentRecord.Method, amount: Decimal, note: String) async throws -> PaymentRecord {
        let tenancy = try authorizedTenancy(tenancyID: tenancyID, userID: payerUserID)
        guard payerUserID == tenancy.renterID else { throw PaymentsRepositoryError.forbidden }
        guard method != .cash else { throw PaymentsRepositoryError.invalidMethod }
        guard amount > 0 else { throw PaymentsRepositoryError.invalidAmount }

        let payment = PaymentRecord(
            id: "PAY-ADV-\(Int.random(in: 500...999))",
            tenancyID: tenancyID,
            invoiceID: nil,
            payerUserID: payerUserID,
            receiverUserID: tenancy.ownerID,
            method: method,
            state: .completed,
            kind: .advance,
            amount: amount,
            offlineMarkedByOwner: false,
            note: note,
            createdAt: .now,
            updatedAt: .now
        )
        payments.append(payment)
        receipts.append(buildReceipt(from: payment, issuedBy: tenancy.ownerID))
        return payment
    }

    func recordDepositDeductionsAndRefund(
        tenancyID: String,
        ownerID: String,
        deductions: [SecurityDepositLedger.Deduction],
        refundAmount: Decimal,
        note: String
    ) async throws -> SecurityDepositLedger {
        let tenancy = try authorizedTenancy(tenancyID: tenancyID, userID: ownerID)
        guard tenancy.ownerID == ownerID else { throw PaymentsRepositoryError.forbidden }
        guard refundAmount >= 0 else { throw PaymentsRepositoryError.invalidAmount }

        let totalDeductions = deductions.reduce(Decimal.zero) { $0 + $1.amount }
        let held = tenancy.depositSummary.heldAmount
        let plannedRefund = max(held - totalDeductions, 0)
        guard refundAmount <= plannedRefund else { throw PaymentsRepositoryError.invalidAmount }

        var ledger = SecurityDepositLedger(
            tenancyID: tenancyID,
            totalDeposit: tenancy.depositSummary.totalDeposit,
            heldAmount: held,
            deductions: deductions,
            plannedRefundAmount: plannedRefund,
            refundPaidAmount: refundAmount
        )

        ledgers[tenancyID] = ledger

        if refundAmount > 0 {
            let refundPayment = PaymentRecord(
                id: "PAY-REF-\(Int.random(in: 100...499))",
                tenancyID: tenancyID,
                invoiceID: nil,
                payerUserID: ownerID,
                receiverUserID: tenancy.renterID,
                method: .cash,
                state: .completed,
                kind: .depositRefund,
                amount: refundAmount,
                offlineMarkedByOwner: true,
                note: note,
                createdAt: .now,
                updatedAt: .now
            )
            payments.append(refundPayment)
            receipts.append(buildReceipt(from: refundPayment, issuedBy: ownerID))
        }

        return ledger
    }

    private func authorizedTenancy(tenancyID: String, userID: String) throws -> TenancyRecord {
        guard let tenancy = tenancies.first(where: { $0.id == tenancyID }) else { throw PaymentsRepositoryError.tenancyNotFound }
        guard tenancy.ownerID == userID || tenancy.renterID == userID else { throw PaymentsRepositoryError.forbidden }
        return tenancy
    }

    private func validateInvoiceAmount(invoiceID: String, tenancyID: String, amount: Decimal, userID: String) async throws {
        guard amount > 0 else { throw PaymentsRepositoryError.invalidAmount }

        guard let invoice = try await billingRepository.fetchInvoice(id: invoiceID, userID: userID) else {
            throw PaymentsRepositoryError.invoiceNotFound
        }
        guard invoice.header.tenancyID == tenancyID else { throw PaymentsRepositoryError.invoiceNotFound }
        guard amount <= invoice.amountRemaining else { throw PaymentsRepositoryError.invalidAmount }
    }

    private func buildReceipt(from payment: PaymentRecord, issuedBy: String) -> PaymentReceipt {
        PaymentReceipt(
            id: "RCT-\(UUID().uuidString.prefix(6))",
            paymentID: payment.id,
            tenancyID: payment.tenancyID,
            invoiceID: payment.invoiceID,
            amount: payment.amount,
            method: payment.method,
            issuedToUserID: payment.payerUserID,
            issuedByUserID: issuedBy,
            issuedAt: .now,
            lineItems: [
                "Type: \(payment.kind.title)",
                "State: \(payment.state.title)",
                payment.note.isEmpty ? "No note" : payment.note
            ]
        )
    }
}

