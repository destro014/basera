import Foundation

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
