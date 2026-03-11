import SwiftUI

struct RenterProfileFormView: View {
    @State private var profile: RenterProfile
    let isSaving: Bool
    let onSave: (RenterProfile) -> Void

    init(profile: RenterProfile, isSaving: Bool, onSave: @escaping (RenterProfile) -> Void) {
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
                    BaseraTextField(title: "Occupation", text: $profile.occupation)
                }

                ProfileSectionView(title: "Household Preferences") {
                    Stepper("Family Size: \(profile.familySize)", value: $profile.familySize, in: 1...20)
                    Toggle("Pets", isOn: $profile.hasPets)
                    Picker("Smoking Status", selection: $profile.smokingStatus) {
                        ForEach(SmokingStatus.allCases) { status in
                            Text(status.title).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                BaseraButton(
                    title: "Save Renter Profile",
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
        profile.occupation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    RenterProfileFormView(profile: PreviewData.renterProfile, isSaving: false, onSave: { _ in })
}
