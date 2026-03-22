import SwiftUI
import VroxalDesign

struct OwnerProfileFormView: View {
    @State private var profile: OwnerProfile
    let isSaving: Bool
    let onSave: (OwnerProfile) -> Void

    init(profile: OwnerProfile, isSaving: Bool, onSave: @escaping (OwnerProfile) -> Void) {
        _profile = State(initialValue: profile)
        self.isSaving = isSaving
        self.onSave = onSave
    }

    var body: some View {
        ScrollView {
            VStack(spacing: VdSpacing.md) {
                ProfilePhotoPickerField(photoURL: $profile.profilePhotoURL)

                ProfileSectionView(title: "Basic Details") {
                    VdTextField(title: "Full Name", text: $profile.fullName, textContentType: .name)
                    VdTextField(title: "Phone", text: $profile.phoneNumber, keyboardType: .phonePad, textContentType: .telephoneNumber)
                    VdTextField(title: "Email", text: $profile.email, keyboardType: .emailAddress, textContentType: .emailAddress, textInputAutocapitalization: .never)
                    VdTextField(title: "Address", text: $profile.address)
                }

                IdentityVerificationIntroView()
                NationalIDUploadView(uploadState: $profile.idDocumentState)

                ProfileSectionView(title: "Bank and Payment Details", subtitle: "Used for monthly invoices, partial payments, and advance tracking") {
                    VdTextField(title: "Bank Name", text: $profile.paymentDetails.bankName)
                    VdTextField(title: "Account Name", text: $profile.paymentDetails.accountName)
                    VdTextField(title: "Account Number", text: $profile.paymentDetails.accountNumber, keyboardType: .numberPad)
                    VdTextField(title: "eSewa ID", text: $profile.paymentDetails.esewaID, keyboardType: .phonePad)
                    VdTextField(title: "Fonepay Number", text: $profile.paymentDetails.fonepayNumber, keyboardType: .phonePad)
                }

                VdButton(
                    title: "Save Owner Profile",
                    style: .primary,
                    isLoading: isSaving,
                    isDisabled: isFormInvalid
                ) {
                    onSave(profile)
                }
            }
            .padding()
        }
    }

    private var isFormInvalid: Bool {
        profile.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        profile.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        profile.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        profile.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        profile.idDocumentState.isComplete == false ||
        profile.paymentDetails.isComplete == false
    }
}

#Preview {
    OwnerProfileFormView(profile: PreviewData.ownerProfile, isSaving: false, onSave: { _ in })
}
