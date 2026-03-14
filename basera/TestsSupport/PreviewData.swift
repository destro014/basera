import Foundation

enum PreviewData {
    static func user(id: String = "preview-user-001", activeRole: UserRole) -> AppUser {
        AppUser(
            id: id,
            fullName: "Sita Basera",
            phoneNumber: "+9779800000000",
            email: "sita@example.com",
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

extension PreviewData {
    static let mockInterests: [InterestRequest] = [
        InterestRequest(
            id: "INT-100",
            listingID: "OL-200",
            ownerID: "preview-user-001",
            renterID: "renter-100",
            renterSnapshot: .init(renterID: "renter-100", fullName: "Nima Sherpa", occupation: "Teacher", familySize: 2, hasPets: false, smokingStatus: "Non-smoker"),
            submittedMessage: "We can move in next month and prefer a long-term stay.",
            submittedAt: Calendar.current.date(byAdding: .hour, value: -10, to: .now) ?? .now,
            status: .pending,
            chatApproval: .unavailable
        ),
        InterestRequest(
            id: "INT-101",
            listingID: "OL-200",
            ownerID: "preview-user-001",
            renterID: "renter-101",
            renterSnapshot: .init(renterID: "renter-101", fullName: "Aarav Karki", occupation: "Bank Officer", familySize: 3, hasPets: true, smokingStatus: "Non-smoker"),
            submittedMessage: "Can we discuss parking and utility split?",
            submittedAt: Calendar.current.date(byAdding: .hour, value: -18, to: .now) ?? .now,
            status: .accepted,
            chatApproval: .awaitingOwnerApproval
        ),
        InterestRequest(
            id: "INT-102",
            listingID: "OL-200",
            ownerID: "preview-user-001",
            renterID: "renter-102",
            renterSnapshot: .init(renterID: "renter-102", fullName: "Riya Lama", occupation: "Designer", familySize: 1, hasPets: false, smokingStatus: "Occasional smoker"),
            submittedMessage: "Interested, but my timeline is flexible.",
            submittedAt: Calendar.current.date(byAdding: .day, value: -2, to: .now) ?? .now,
            status: .rejected,
            chatApproval: .unavailable
        ),
        InterestRequest(
            id: "INT-104",
            listingID: "OL-200",
            ownerID: "preview-user-001",
            renterID: "renter-103",
            renterSnapshot: .init(renterID: "renter-103", fullName: "Bikash Gurung", occupation: "Photographer", familySize: 2, hasPets: false, smokingStatus: "Non-smoker"),
            submittedMessage: "Chat already approved. Ready to confirm visit.",
            submittedAt: Calendar.current.date(byAdding: .hour, value: -6, to: .now) ?? .now,
            status: .accepted,
            chatApproval: .approved
        ),
        InterestRequest(
            id: "INT-103",
            listingID: "L-100",
            ownerID: "owner-xyz",
            renterID: "preview-user-001",
            renterSnapshot: .init(renterID: "preview-user-001", fullName: "Sita Basera", occupation: "Software Engineer", familySize: 3, hasPets: false, smokingStatus: "Non-smoker"),
            submittedMessage: "We need nearby school access.",
            submittedAt: Calendar.current.date(byAdding: .hour, value: -14, to: .now) ?? .now,
            status: .accepted,
            chatApproval: .approved
        )
    ]

    static let mockConversations: [ChatConversation] = [
        ChatConversation(
            id: "CHAT-100",
            listingID: "L-100",
            ownerID: "owner-xyz",
            renterID: "preview-user-001",
            participantName: "Owner: Prakash Shrestha",
            listingTitle: "Sunny Family Flat in Jawalakhel",
            interestID: "INT-103",
            lastMessagePreview: "Please bring your citizenship copy for verification.",
            lastUpdatedAt: Calendar.current.date(byAdding: .hour, value: -1, to: .now) ?? .now,
            unreadCount: 2
        )
    ]

    static let mockMessagesByConversationID: [String: [ChatMessage]] = [
        "CHAT-100": [
            ChatMessage(id: "MSG-1", conversationID: "CHAT-100", senderID: "owner-xyz", body: "Namaste! Your interest is accepted and chat is approved.", sentAt: Calendar.current.date(byAdding: .hour, value: -5, to: .now) ?? .now),
            ChatMessage(id: "MSG-2", conversationID: "CHAT-100", senderID: "preview-user-001", body: "Thank you. Can we schedule a visit on Saturday?", sentAt: Calendar.current.date(byAdding: .hour, value: -4, to: .now) ?? .now),
            ChatMessage(id: "MSG-3", conversationID: "CHAT-100", senderID: "owner-xyz", body: "Yes, Saturday 11 AM works.", sentAt: Calendar.current.date(byAdding: .hour, value: -3, to: .now) ?? .now)
        ]
    ]
}


extension PreviewData {
    static let mockVisits: [PropertyVisitSchedule] = [
        PropertyVisitSchedule(
            id: "VIS-100",
            listingID: "OL-200",
            ownerID: "preview-user-001",
            renterID: "renter-103",
            note: "Please call when you arrive near Gate 2.",
            scheduledAt: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now,
            status: .proposed,
            updatedAt: .now
        ),
        PropertyVisitSchedule(
            id: "VIS-101",
            listingID: "L-100",
            ownerID: "owner-xyz",
            renterID: "preview-user-001",
            note: "Bring ID for building entry.",
            scheduledAt: Calendar.current.date(byAdding: .day, value: 2, to: .now) ?? .now,
            status: .proposed,
            updatedAt: .now
        )
    ]

    static let mockAssignmentsByListingID: [String: ListingAssignment] = [
        "L-100": ListingAssignment(
            id: "ASN-100",
            listingID: "L-100",
            ownerID: "owner-xyz",
            renterID: "preview-user-001",
            interestID: "INT-103",
            requestedAt: Calendar.current.date(byAdding: .hour, value: -2, to: .now) ?? .now,
            status: .requested,
            note: "Confirm within 24 hours so agreement drafting can start."
        )
    ]
}

extension PreviewData {
    static let mockAgreements: [AgreementRecord] = {
        let now = Date()
        let terms = AgreementRecord.Terms(
            monthlyRent: 40000,
            securityDeposit: 40000,
            utilityTerms: "Electricity billed by meter, water included, internet split equally.",
            rulesAndRegulations: "Quiet hours 9PM-6AM. No illegal activity.",
            startDate: Calendar.current.date(byAdding: .day, value: 15, to: now) ?? now,
            endDate: Calendar.current.date(byAdding: .year, value: 1, to: now) ?? now,
            noticePeriodDays: 30,
            lateFeeText: "NPR 500 applies after 5th of each month.",
            repairResponsibility: "Owner handles structural repairs. Renter handles minor wear/tear issues.",
            guestRules: "Guests allowed until 9PM. Overnight guests require prior notice.",
            petRules: "No aggressive pets. Small pets allowed with owner consent."
        )

        return [
            AgreementRecord(
                id: "AGR-200",
                tenancyID: "TEN-200",
                previousAgreementID: nil,
                version: 1,
                owner: .init(userID: "preview-user-001", fullName: "Sita Basera", phoneNumber: "+9779800000000", email: "sita-owner@example.com"),
                renter: .init(userID: "renter-103", fullName: "Bikash Gurung", phoneNumber: "+9779811111111", email: "bikash@example.com"),
                property: .init(listingID: "OL-200", listingTitle: "Tulsi Apartment - Full Unit", approximateLocation: "Bhaisepati, Lalitpur", exactAddress: "Ward 3, House 18", exactAddressVisibleToRenter: true),
                terms: terms,
                status: .pendingOwnerSignature,
                signatures: .init(owner: nil, renter: nil),
                statusHistory: [
                    .init(id: UUID().uuidString, title: "Draft created", happenedAt: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now, detail: "Owner started agreement drafting"),
                    .init(id: UUID().uuidString, title: "Sent for signing", happenedAt: now, detail: "Waiting for owner typed-name + OTP confirmation")
                ],
                createdAt: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now,
                updatedAt: now
            ),
            AgreementRecord(
                id: "AGR-300",
                tenancyID: "TEN-300",
                previousAgreementID: nil,
                version: 1,
                owner: .init(userID: "owner-100", fullName: "Sujan Karki", phoneNumber: "+9779844444444", email: "sujan@example.com"),
                renter: .init(userID: "preview-user-001", fullName: "Sita Basera", phoneNumber: "+9779800000000", email: "sita@example.com"),
                property: .init(listingID: "OL-203", listingTitle: "Modern Flat near Chabahil", approximateLocation: "Chabahil, Kathmandu", exactAddress: "Ward 7, House 12", exactAddressVisibleToRenter: true),
                terms: terms,
                status: .fullySigned,
                signatures: .init(
                    owner: .init(typedName: "Sujan Karki", signedAt: Calendar.current.date(byAdding: .month, value: -2, to: now) ?? now),
                    renter: .init(typedName: "Sita Basera", signedAt: Calendar.current.date(byAdding: .month, value: -2, to: now) ?? now)
                ),
                statusHistory: [
                    .init(id: UUID().uuidString, title: "Agreement signed", happenedAt: Calendar.current.date(byAdding: .month, value: -2, to: now) ?? now, detail: "Both parties signed with OTP verification.")
                ],
                createdAt: Calendar.current.date(byAdding: .month, value: -2, to: now) ?? now,
                updatedAt: Calendar.current.date(byAdding: .month, value: -2, to: now) ?? now
            ),
            AgreementRecord(
                id: "AGR-301",
                tenancyID: "TEN-301",
                previousAgreementID: nil,
                version: 1,
                owner: .init(userID: "preview-user-001", fullName: "Sita Basera", phoneNumber: "+9779800000000", email: "sita-owner@example.com"),
                renter: .init(userID: "renter-103", fullName: "Bikash Gurung", phoneNumber: "+9779811111111", email: "bikash@example.com"),
                property: .init(listingID: "OL-200", listingTitle: "Tulsi Apartment - Full Unit", approximateLocation: "Bhaisepati, Lalitpur", exactAddress: "Ward 3, House 18", exactAddressVisibleToRenter: true),
                terms: terms,
                status: .fullySigned,
                signatures: .init(
                    owner: .init(typedName: "Sita Basera", signedAt: Calendar.current.date(byAdding: .day, value: -20, to: now) ?? now),
                    renter: .init(typedName: "Bikash Gurung", signedAt: Calendar.current.date(byAdding: .day, value: -20, to: now) ?? now)
                ),
                statusHistory: [
                    .init(id: UUID().uuidString, title: "Agreement signed", happenedAt: Calendar.current.date(byAdding: .day, value: -20, to: now) ?? now, detail: "Move-in checklist can now begin.")
                ],
                createdAt: Calendar.current.date(byAdding: .day, value: -21, to: now) ?? now,
                updatedAt: Calendar.current.date(byAdding: .day, value: -20, to: now) ?? now
            )
        ]
    }()
}

extension PreviewData {
    static let mockTenancies: [TenancyRecord] = {
        let now = Date()

        let activeRenterTenancy = TenancyRecord(
            id: "TEN-300",
            listingID: "OL-203",
            agreementID: "AGR-300",
            ownerID: "owner-100",
            renterID: "preview-user-001",
            listingTitle: "Modern Flat near Chabahil",
            approximateLocation: "Chabahil, Kathmandu",
            exactAddress: "Ward 7, House 12",
            exactAddressVisibleToRenter: true,
            monthlyRent: 28000,
            startDate: Calendar.current.date(byAdding: .month, value: -2, to: now) ?? now,
            endDate: Calendar.current.date(byAdding: .month, value: 10, to: now) ?? now,
            status: .moveOutRequested,
            closureState: .requestedByRenter(requestedAt: Calendar.current.date(byAdding: .day, value: -2, to: now) ?? now),
            billSummary: .init(
                currentInvoiceID: "INV-300",
                dueDate: Calendar.current.date(byAdding: .day, value: 5, to: now) ?? now,
                amountDue: 31500,
                carryForward: 1500,
                allowsPartialPayment: true,
                allowsAdvancePayment: true
            ),
            depositSummary: .init(
                totalDeposit: 56000,
                heldAmount: 56000,
                plannedRefundAmount: nil,
                deductionNotes: "Deposit remains locked until formal move-out inspection."
            ),
            moveInChecklist: [
                .init(id: "CHK-1", title: "Bedroom walls and paint", category: .roomCondition, isCompleted: true, note: "Minor scuff near wardrobe.", photoPlaceholders: ["Wall photo"]),
                .init(id: "CHK-2", title: "Kitchen sink and tap", category: .appliance, isCompleted: true, note: "No leakage at move-in.", photoPlaceholders: ["Sink photo"]),
                .init(id: "CHK-3", title: "Electricity meter opening", category: .meterReading, isCompleted: false, note: "Need clear meter close-up.", photoPlaceholders: ["Meter photo pending"])
            ],
            moveOutRequest: nil,
            moveOutChecklist: [],
            finalMeterReading: nil,
            depositSettlement: nil,
            historicalAccess: .init(agreementAvailable: true, invoicesAvailable: true, paymentsAvailable: true),
            listingReactivation: .init(isReady: false, pendingItems: ["Move-out approval pending", "Final inspection pending", "Deposit settlement pending"]),
            ownerContact: .init(fullName: "Sita Basera", phoneNumber: "+9779800000000"),
            renterContact: .init(fullName: "Sita Basera", phoneNumber: "+9779800000000")
        )

        let ownerTenancy = TenancyRecord(
            id: "TEN-301",
            listingID: "OL-200",
            agreementID: "AGR-301",
            ownerID: "preview-user-001",
            renterID: "renter-103",
            listingTitle: "Tulsi Apartment - Full Unit",
            approximateLocation: "Bhaisepati, Lalitpur",
            exactAddress: "Ward 3, House 18",
            exactAddressVisibleToRenter: true,
            monthlyRent: 40000,
            startDate: Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now,
            endDate: Calendar.current.date(byAdding: .month, value: 11, to: now) ?? now,
            status: .moveInPending,
            closureState: .none,
            billSummary: .init(
                currentInvoiceID: "INV-301",
                dueDate: Calendar.current.date(byAdding: .day, value: 12, to: now) ?? now,
                amountDue: 40000,
                carryForward: 0,
                allowsPartialPayment: true,
                allowsAdvancePayment: true
            ),
            depositSummary: .init(
                totalDeposit: 80000,
                heldAmount: 80000,
                plannedRefundAmount: nil,
                deductionNotes: nil
            ),
            moveInChecklist: [
                .init(id: "CHK-4", title: "Living room floor", category: .roomCondition, isCompleted: false, note: "Pending tenant confirmation.", photoPlaceholders: ["Floor photo pending"]),
                .init(id: "CHK-5", title: "Sofa set", category: .furniture, isCompleted: false, note: "Upload armrest photo.", photoPlaceholders: ["Furniture photo pending"])
            ],
            moveOutRequest: nil,
            moveOutChecklist: [],
            finalMeterReading: nil,
            depositSettlement: nil,
            historicalAccess: .init(agreementAvailable: true, invoicesAvailable: true, paymentsAvailable: true),
            listingReactivation: .init(isReady: false, pendingItems: ["Tenancy not yet closed"]),
            ownerContact: .init(fullName: "Sita Basera", phoneNumber: "+9779800000000"),
            renterContact: .init(fullName: "Bikash Gurung", phoneNumber: "+9779811111111")
        )

        let archivedTenancy = TenancyRecord(
            id: "TEN-210",
            listingID: "OL-111",
            agreementID: "AGR-111",
            ownerID: "preview-user-001",
            renterID: "renter-090",
            listingTitle: "Flat near Patan Durbar",
            approximateLocation: "Patan, Lalitpur",
            exactAddress: "Ward 6, House 9",
            exactAddressVisibleToRenter: true,
            monthlyRent: 26000,
            startDate: Calendar.current.date(byAdding: .year, value: -2, to: now) ?? now,
            endDate: Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now,
            status: .archived,
            closureState: .closed(closedAt: Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now),
            billSummary: .init(currentInvoiceID: "INV-210", dueDate: now, amountDue: 0, carryForward: 0, allowsPartialPayment: true, allowsAdvancePayment: true),
            depositSummary: .init(totalDeposit: 52000, heldAmount: 0, plannedRefundAmount: 48000, deductionNotes: "NPR 4,000 deducted for repainting."),
            moveInChecklist: [],
            moveOutRequest: .init(
                requestedByRenterAt: Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now,
                requestedMoveOutDate: Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now,
                reason: "Relocated for work",
                conditionNotes: "No major damage at handover.",
                photoPlaceholders: ["Final condition photos archived"],
                ownerDecision: .approved(approvedAt: Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now, note: "Approved after final inspection")
            ),
            moveOutChecklist: [
                .init(id: "MOC-100", title: "Collect keys", isCompleted: true, notes: "All keys returned", photoPlaceholders: ["Key handover"])
            ],
            finalMeterReading: .init(electricity: "1580", water: "403", internet: "Closed", capturedAt: Calendar.current.date(byAdding: .year, value: -1, to: now)),
            depositSettlement: .init(
                refundType: .partial,
                deductions: [.init(id: "DED-1", title: "Repainting", amount: 4000, note: "Bedroom wall repaint")],
                refundAmount: 48000,
                summaryNote: "NPR 4,000 deducted for repainting."
            ),
            historicalAccess: .init(agreementAvailable: true, invoicesAvailable: true, paymentsAvailable: true),
            listingReactivation: .init(isReady: true, pendingItems: []),
            ownerContact: .init(fullName: "Sita Basera", phoneNumber: "+9779800000000"),
            renterContact: .init(fullName: "Rabin Tamang", phoneNumber: "+9779822222222")
        )

        return [activeRenterTenancy, ownerTenancy, archivedTenancy]
    }()
}

extension PreviewData {
    static let mockBillingSettingsByTenancyID: [String: BillingTenancySettings] = [
        "TEN-300": .init(allowsRenterGeneratedBillDraft: true, allowsPartialPayment: true, allowsAdvancePayment: true),
        "TEN-301": .init(allowsRenterGeneratedBillDraft: false, allowsPartialPayment: true, allowsAdvancePayment: true)
    ]

    static let mockInvoices: [InvoiceRecord] = {
        let calendar = Calendar.current
        let month = calendar.date(from: calendar.dateComponents([.year, .month], from: .now)) ?? .now
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: month) ?? month

        return [
            InvoiceRecord(
                id: "INV-300",
                header: .init(
                    tenancyID: "TEN-300",
                    listingTitle: "Modern Flat near Chabahil",
                    billingMonth: month,
                    issueDate: .now,
                    dueDate: calendar.date(byAdding: .day, value: 5, to: .now) ?? .now,
                    ownerID: "owner-100",
                    renterID: "preview-user-001"
                ),
                createdByRole: .owner,
                status: .pendingPayment,
                items: [
                    .init(id: "IT-1", category: .rent, title: "Monthly rent", detail: nil, amount: 28000),
                    .init(id: "IT-2", category: .electricity, title: "Electricity", detail: "Meter 1120 → 1190 × Rs. 12", amount: 840),
                    .init(id: "IT-3", category: .water, title: "Water", detail: "Flat", amount: 500),
                    .init(id: "IT-4", category: .internet, title: "Internet", detail: "Flat", amount: 1200),
                    .init(id: "IT-5", category: .deduction, title: "Repair inconvenience deduction", detail: nil, amount: 540)
                ],
                carryForwardBalance: 1500,
                paidAmount: 0,
                note: "Monthly combined invoice",
                rejectionReason: nil,
                createdAt: .now,
                updatedAt: .now
            ),
            InvoiceRecord(
                id: "INV-299",
                header: .init(
                    tenancyID: "TEN-300",
                    listingTitle: "Modern Flat near Chabahil",
                    billingMonth: previousMonth,
                    issueDate: calendar.date(byAdding: .month, value: -1, to: .now) ?? .now,
                    dueDate: calendar.date(byAdding: .day, value: -20, to: .now) ?? .now,
                    ownerID: "owner-100",
                    renterID: "preview-user-001"
                ),
                createdByRole: .owner,
                status: .partiallyPaid,
                items: [
                    .init(id: "IT-9", category: .rent, title: "Monthly rent", detail: nil, amount: 28000),
                    .init(id: "IT-10", category: .electricity, title: "Electricity", detail: "Flat fee", amount: 700)
                ],
                carryForwardBalance: 0,
                paidAmount: 27200,
                note: "Previous month",
                rejectionReason: nil,
                createdAt: previousMonth,
                updatedAt: previousMonth
            ),
            InvoiceRecord(
                id: "INV-301",
                header: .init(
                    tenancyID: "TEN-301",
                    listingTitle: "Tulsi Apartment - Full Unit",
                    billingMonth: month,
                    issueDate: .now,
                    dueDate: calendar.date(byAdding: .day, value: 12, to: .now) ?? .now,
                    ownerID: "preview-user-001",
                    renterID: "renter-103"
                ),
                createdByRole: .owner,
                status: .pendingPayment,
                items: [
                    .init(id: "IT-11", category: .rent, title: "Monthly rent", detail: nil, amount: 40000)
                ],
                carryForwardBalance: 0,
                paidAmount: 0,
                note: "First billing month",
                rejectionReason: nil,
                createdAt: .now,
                updatedAt: .now
            )
        ]
    }()
}

extension PreviewData {
    static let mockPaymentMethodsByTenancyID: [String: [PaymentRecord.Method]] = [
        "TEN-300": [.eSewa, .fonepay, .cash],
        "TEN-301": [.eSewa, .fonepay, .cash],
        "TEN-210": [.cash]
    ]

    static let mockPayments: [PaymentRecord] = [
        .init(
            id: "PAY-301",
            tenancyID: "TEN-300",
            invoiceID: "INV-299",
            payerUserID: "preview-user-001",
            receiverUserID: "owner-100",
            method: .eSewa,
            state: .completed,
            kind: .invoice,
            amount: 27200,
            offlineMarkedByOwner: false,
            note: "Partially paid via eSewa",
            createdAt: Calendar.current.date(byAdding: .day, value: -12, to: .now) ?? .now,
            updatedAt: Calendar.current.date(byAdding: .day, value: -12, to: .now) ?? .now
        ),
        .init(
            id: "PAY-302",
            tenancyID: "TEN-300",
            invoiceID: nil,
            payerUserID: "preview-user-001",
            receiverUserID: "owner-100",
            method: .fonepay,
            state: .completed,
            kind: .advance,
            amount: 3000,
            offlineMarkedByOwner: false,
            note: "Advance for next invoice",
            createdAt: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now,
            updatedAt: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now
        ),
        .init(
            id: "PAY-303",
            tenancyID: "TEN-301",
            invoiceID: "INV-301",
            payerUserID: "renter-103",
            receiverUserID: "preview-user-001",
            method: .cash,
            state: .completed,
            kind: .invoice,
            amount: 15000,
            offlineMarkedByOwner: true,
            note: "Owner marked offline cash received",
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now,
            updatedAt: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now
        )
    ]

    static let mockPaymentReceipts: [PaymentReceipt] = [
        .init(
            id: "RCT-301",
            paymentID: "PAY-301",
            tenancyID: "TEN-300",
            invoiceID: "INV-299",
            amount: 27200,
            method: .eSewa,
            issuedToUserID: "preview-user-001",
            issuedByUserID: "owner-100",
            issuedAt: Calendar.current.date(byAdding: .day, value: -12, to: .now) ?? .now,
            lineItems: ["Invoice partial payment", "eSewa placeholder confirmation"]
        ),
        .init(
            id: "RCT-302",
            paymentID: "PAY-302",
            tenancyID: "TEN-300",
            invoiceID: nil,
            amount: 3000,
            method: .fonepay,
            issuedToUserID: "preview-user-001",
            issuedByUserID: "owner-100",
            issuedAt: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now,
            lineItems: ["Advance payment", "Will be adjusted in next combined invoice"]
        )
    ]

    static let mockDepositLedgersByTenancyID: [String: SecurityDepositLedger] = [
        "TEN-300": .init(
            tenancyID: "TEN-300",
            totalDeposit: 56000,
            heldAmount: 56000,
            deductions: [],
            plannedRefundAmount: 56000,
            refundPaidAmount: 0
        ),
        "TEN-210": .init(
            tenancyID: "TEN-210",
            totalDeposit: 52000,
            heldAmount: 52000,
            deductions: [
                .init(id: "DED-1", title: "Repainting", amount: 4000, note: "Bedroom wall repaint")
            ],
            plannedRefundAmount: 48000,
            refundPaidAmount: 48000
        )
    ]
}

extension PreviewData {
    static let mockNotificationsByUserID: [String: [AppNotification]] = {
        let now = Date()
        return [
            "preview-user-001": [
                AppNotification(
                    id: "NOTIF-100",
                    userID: "preview-user-001",
                    audience: .owner,
                    type: .interestReceived,
                    title: "New interest received",
                    message: "Nima Sherpa sent interest for Tulsi Apartment - Full Unit.",
                    createdAt: Calendar.current.date(byAdding: .minute, value: -8, to: now) ?? now,
                    readAt: nil,
                    route: .interests(listingID: "OL-200"),
                    metadata: ["listingID": "OL-200", "interestID": "INT-100"]
                ),
                AppNotification(
                    id: "NOTIF-101",
                    userID: "preview-user-001",
                    audience: .renter,
                    type: .interestAccepted,
                    title: "Interest accepted",
                    message: "Your interest for Modern Flat near Chabahil was accepted.",
                    createdAt: Calendar.current.date(byAdding: .hour, value: -3, to: now) ?? now,
                    readAt: nil,
                    route: .interests(listingID: "OL-203"),
                    metadata: ["listingID": "OL-203"]
                ),
                AppNotification(
                    id: "NOTIF-102",
                    userID: "preview-user-001",
                    audience: .renter,
                    type: .interestRejected,
                    title: "Interest not accepted",
                    message: "Your interest for Tulsi Apartment - Room 2 was not accepted this time.",
                    createdAt: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now,
                    readAt: Calendar.current.date(byAdding: .hour, value: -22, to: now),
                    route: .interests(listingID: "OL-202"),
                    metadata: ["listingID": "OL-202"]
                ),
                AppNotification(
                    id: "NOTIF-103",
                    userID: "preview-user-001",
                    audience: .both,
                    type: .agreementReady,
                    title: "Agreement ready",
                    message: "Agreement AGR-200 is ready for review before signing.",
                    createdAt: Calendar.current.date(byAdding: .hour, value: -10, to: now) ?? now,
                    readAt: nil,
                    route: .agreement(agreementID: "AGR-200"),
                    metadata: ["agreementID": "AGR-200"]
                ),
                AppNotification(
                    id: "NOTIF-104",
                    userID: "preview-user-001",
                    audience: .both,
                    type: .agreementSigned,
                    title: "Agreement signed",
                    message: "Agreement AGR-300 is now locked and active.",
                    createdAt: Calendar.current.date(byAdding: .day, value: -4, to: now) ?? now,
                    readAt: Calendar.current.date(byAdding: .day, value: -3, to: now),
                    route: .agreement(agreementID: "AGR-300"),
                    metadata: ["agreementID": "AGR-300"]
                ),
                AppNotification(
                    id: "NOTIF-105",
                    userID: "preview-user-001",
                    audience: .both,
                    type: .billGenerated,
                    title: "Bill generated",
                    message: "May invoice generated with rent and utility totals combined.",
                    createdAt: Calendar.current.date(byAdding: .day, value: -2, to: now) ?? now,
                    readAt: nil,
                    route: .billing(invoiceID: "INV-501"),
                    metadata: ["invoiceID": "INV-501"]
                ),
                AppNotification(
                    id: "NOTIF-106",
                    userID: "preview-user-001",
                    audience: .renter,
                    type: .paymentDueReminder,
                    title: "Payment reminder",
                    message: "Invoice INV-501 is due in 2 days.",
                    createdAt: Calendar.current.date(byAdding: .hour, value: -6, to: now) ?? now,
                    readAt: nil,
                    route: .payments(invoiceID: "INV-501"),
                    metadata: ["invoiceID": "INV-501"]
                ),
                AppNotification(
                    id: "NOTIF-107",
                    userID: "preview-user-001",
                    audience: .owner,
                    type: .paymentReceived,
                    title: "Payment received",
                    message: "Partial payment of NPR 15,000 was received for INV-501.",
                    createdAt: Calendar.current.date(byAdding: .hour, value: -12, to: now) ?? now,
                    readAt: nil,
                    route: .payments(invoiceID: "INV-501"),
                    metadata: ["invoiceID": "INV-501", "amount": "15000", "paymentMode": "partial"]
                ),
                AppNotification(
                    id: "NOTIF-108",
                    userID: "preview-user-001",
                    audience: .owner,
                    type: .moveOutRequest,
                    title: "Move-out request",
                    message: "A renter requested move-out. Start checklist and inspection flow.",
                    createdAt: Calendar.current.date(byAdding: .minute, value: -45, to: now) ?? now,
                    readAt: nil,
                    route: .moveOut(tenancyID: "TEN-300"),
                    metadata: ["tenancyID": "TEN-300"]
                ),
                AppNotification(
                    id: "NOTIF-109",
                    userID: "preview-user-001",
                    audience: .both,
                    type: .reviewReminder,
                    title: "Leave a review",
                    message: "You can now leave a review for the completed tenancy.",
                    createdAt: Calendar.current.date(byAdding: .day, value: -5, to: now) ?? now,
                    readAt: nil,
                    route: .review(tenancyID: "TEN-300"),
                    metadata: ["tenancyID": "TEN-300"]
                )
            ]
        ]
    }()

    static let mockPushPayloadsByUserID: [String: [PushNotificationPayload]] = [
        "preview-user-001": [
            PushNotificationPayload(
                id: "PUSH-900",
                userID: "preview-user-001",
                type: .paymentDueReminder,
                title: "Upcoming due date",
                message: "Invoice INV-502 is due tomorrow.",
                route: .payments(invoiceID: "INV-502"),
                metadata: ["invoiceID": "INV-502"],
                createdAt: Date()
            )
        ]
    ]
}

extension PreviewData {
    static let mockReviews: [ReviewRecord] = [
        ReviewRecord(
            id: "REV-100",
            tenancyID: "TEN-300",
            stage: .duringStay,
            reviewerID: "owner-xyz",
            reviewerName: "Prakash Shrestha",
            reviewerRole: .owner,
            revieweeID: "preview-user-001",
            revieweeName: "Sita Basera",
            rating: 5,
            comment: "Paid monthly invoices on time and kept the flat in excellent condition.",
            createdAt: Calendar.current.date(byAdding: .day, value: -20, to: .now) ?? .now
        ),
        ReviewRecord(
            id: "REV-101",
            tenancyID: "TEN-301",
            stage: .postMoveOut,
            reviewerID: "preview-user-001",
            reviewerName: "Sita Basera",
            reviewerRole: .owner,
            revieweeID: "renter-legacy-02",
            revieweeName: "Anjali Karki",
            rating: 4,
            comment: "Smooth move-out process and meter readings were settled quickly.",
            createdAt: Calendar.current.date(byAdding: .day, value: -5, to: .now) ?? .now
        )
    ]

    static let mockReviewReports: [ReviewReportRecord] = [
        ReviewReportRecord(
            id: "RPT-100",
            reviewID: "REV-101",
            reporterID: "renter-legacy-02",
            reason: .falseInformation,
            note: "Please verify utility statements context.",
            createdAt: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now
        )
    ]
}
