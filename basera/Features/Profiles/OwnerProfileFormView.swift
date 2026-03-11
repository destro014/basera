import SwiftUI

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
            VStack(spacing: AppTheme.Spacing.large) {
                ProfilePhotoPickerField(photoURL: $profile.profilePhotoURL)

                ProfileSectionView(title: "Basic Details") {
                    BaseraTextField(title: "Full Name", text: $profile.fullName, textContentType: .name)
                    BaseraTextField(title: "Phone", text: $profile.phoneNumber, keyboardType: .phonePad, textContentType: .telephoneNumber)
                    BaseraTextField(title: "Email", text: $profile.email, keyboardType: .emailAddress, textContentType: .emailAddress, textInputAutocapitalization: .never)
                    BaseraTextField(title: "Address", text: $profile.address)
                }

                IdentityVerificationIntroView()
                NationalIDUploadView(uploadState: $profile.idDocumentState)

                ProfileSectionView(title: "Bank and Payment Details", subtitle: "Used for monthly invoices, partial payments, and advance tracking") {
                    BaseraTextField(title: "Bank Name", text: $profile.paymentDetails.bankName)
                    BaseraTextField(title: "Account Name", text: $profile.paymentDetails.accountName)
                    BaseraTextField(title: "Account Number", text: $profile.paymentDetails.accountNumber, keyboardType: .numberPad)
                    BaseraTextField(title: "eSewa ID", text: $profile.paymentDetails.esewaID, keyboardType: .phonePad)
                    BaseraTextField(title: "Fonepay Number", text: $profile.paymentDetails.fonepayNumber, keyboardType: .phonePad)
                }

                BaseraButton(
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
