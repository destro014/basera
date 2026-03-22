import SwiftUI
import VroxalDesign

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
            VStack(spacing: VdSpacing.md) {
                ProfilePhotoPickerField(photoURL: $profile.profilePhotoURL)

                ProfileSectionView(title: "Basic Details") {
                    VdTextField(title: "Full Name", text: $profile.fullName, textContentType: .name)
                    VdTextField(title: "Phone", text: $profile.phoneNumber, keyboardType: .phonePad, textContentType: .telephoneNumber)
                    VdTextField(title: "Email", text: $profile.email, keyboardType: .emailAddress, textContentType: .emailAddress, textInputAutocapitalization: .never)
                    VdTextField(title: "Occupation", text: $profile.occupation)
                }

                ProfileSectionView(title: "Household Preferences") {
                    Stepper(value: $profile.familySize, in: 1...20) {
                        Text("Family Size: \(profile.familySize)")
                            .vdFont(VdFont.bodyLarge)
                            .foregroundStyle(Color.vdContentDefaultBase)
                    }
                    .tint(Color.vdContentPrimaryBase)

                    Toggle(isOn: $profile.hasPets) {
                        Text("Pets")
                            .vdFont(VdFont.bodyLarge)
                            .foregroundStyle(Color.vdContentDefaultBase)
                    }
                    .tint(Color.vdContentPrimaryBase)

                    Picker(selection: $profile.smokingStatus) {
                        ForEach(SmokingStatus.allCases) { status in
                            Text(status.title)
                                .vdFont(VdFont.labelMedium)
                                .tag(status)
                        }
                    } label: {
                        Text("Smoking Status")
                            .vdFont(VdFont.labelLarge)
                            .foregroundStyle(Color.vdContentDefaultBase)
                    }
                    .pickerStyle(.segmented)
                    .tint(Color.vdContentPrimaryBase)
                }

                VdButton(
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
