import Foundation

@MainActor
final class AgreementFlowViewModel: ObservableObject {
    @Published private(set) var agreements: [AgreementRecord] = []
    @Published var selectedAgreement: AgreementRecord?
    @Published var editableTerms: AgreementRecord.Terms = .placeholder
    @Published var typedName = ""
    @Published var otpCode = ""
    @Published private(set) var otpChallenge: AgreementOTPChallenge?
    @Published var errorMessage: String?
    @Published var successMessage: String?

    let currentUserID: String
    let currentParty: AgreementRecord.Party

    init(currentUserID: String, currentParty: AgreementRecord.Party) {
        self.currentUserID = currentUserID
        self.currentParty = currentParty
    }

    func load(using repository: AgreementsRepositoryProtocol) async {
        do {
            agreements = try await repository.fetchAgreements(for: currentUserID, as: currentParty)
            if selectedAgreement == nil {
                selectedAgreement = agreements.first
                editableTerms = selectedAgreement?.terms ?? .placeholder
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createOwnerDraft(using repository: AgreementsRepositoryProtocol) async {
        do {
            let draft = AgreementDraftInput(
                tenancyID: "TEN-\(UUID().uuidString.prefix(6))",
                listingID: "OL-200",
                owner: .init(userID: currentUserID, fullName: "Sita Basera", phoneNumber: "+9779800000000", email: "sita-owner@example.com"),
                renter: .init(userID: "renter-103", fullName: "Bikash Gurung", phoneNumber: "+9779811111111", email: "bikash@example.com"),
                property: .init(listingID: "OL-200", listingTitle: "Tulsi Apartment - Full Unit", approximateLocation: "Bhaisepati, Lalitpur", exactAddress: "Ward 3, House 18", exactAddressVisibleToRenter: true),
                terms: editableTerms
            )
            let created = try await repository.createAgreementDraft(draft)
            selectedAgreement = created
            agreements.insert(created, at: 0)
            successMessage = "Draft created"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveEdits(using repository: AgreementsRepositoryProtocol) async {
        guard let agreement = selectedAgreement else { return }
        do {
            let updated = try await repository.updateAgreementTerms(agreementID: agreement.id, editorID: currentUserID, terms: editableTerms)
            selectedAgreement = updated
            agreements = agreements.map { $0.id == updated.id ? updated : $0 }
            successMessage = "Agreement sections updated"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func submitForSigning(using repository: AgreementsRepositoryProtocol) async {
        guard let agreement = selectedAgreement else { return }
        do {
            let updated = try await repository.submitForSignature(agreementID: agreement.id, ownerID: currentUserID)
            update(updated)
            successMessage = "Agreement is ready for typed-name + OTP confirmation"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func requestOTP(using repository: AgreementsRepositoryProtocol) async {
        guard let agreement = selectedAgreement else { return }
        do {
            let party = try await repository.confirmTypedName(agreementID: agreement.id, userID: currentUserID, typedName: typedName)
            otpChallenge = try await repository.requestAgreementOTP(agreementID: agreement.id, userID: currentUserID, party: party)
            successMessage = "OTP sent (mock code: 123456)"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func verifyOTPAndSign(using repository: AgreementsRepositoryProtocol) async {
        guard let agreement = selectedAgreement, let challenge = otpChallenge else { return }
        do {
            let updated = try await repository.verifyAgreementOTP(agreementID: agreement.id, userID: currentUserID, challengeID: challenge.challengeID, code: otpCode)
            update(updated)
            successMessage = updated.signatures.isFullySigned ? "Agreement signed successfully" : "Signature recorded"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createRenewal(using repository: AgreementsRepositoryProtocol) async {
        guard let agreement = selectedAgreement else { return }
        do {
            let renewed = try await repository.createRenewalDraft(from: agreement.id, ownerID: currentUserID)
            update(renewed)
            successMessage = "Renewal draft v\(renewed.version) created"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func update(_ agreement: AgreementRecord) {
        selectedAgreement = agreement
        editableTerms = agreement.terms
        agreements = agreements.map { $0.id == agreement.id ? agreement : $0 }
    }
}
