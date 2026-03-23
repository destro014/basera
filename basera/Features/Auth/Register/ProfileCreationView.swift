import SwiftUI
import VroxalDesign

struct ProfileCreationView: View {
    @Binding var fullName: String
    @Binding var phoneNumber: String
    let selectedRole: UserRole

    let notice: AuthStepNotice?
    let fullNameValidationMessage: String?
    let phoneNumberValidationMessage: String?
    let isLoading: Bool
    let onSubmit: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VdSpacing.none) {
                    Spacer()
                        .frame(height: VdSpacing.xxl)

                    
                    headerContainer

                    Spacer()
                        .frame(height: VdSpacing.xl)

                    inputContainer

                    if let notice {
                        Spacer()
                            .frame(height: VdSpacing.md)

                        noticeContainer(notice)

                        Spacer()
                            .frame(height: VdSpacing.md)
                    } else {
                        Spacer()
                            .frame(height: VdSpacing.xl)
                    }

                    buttonContainer
                }
                .frame(
                    maxWidth: 420,
                    minHeight: max(proxy.size.height - 32, 0),
                    alignment: .top
                )
                .padding(.horizontal, proxy.size.width >= 520 ? VdSpacing.lg : VdSpacing.md)
                .padding(.bottom, VdSpacing.sm)
                .frame(maxWidth: .infinity)
            }
            .baseraScreenBackground()
        }
    }

    private var logoContainer: some View {
        Image("logo-horizontal")
            .resizable()
            .scaledToFit()
            .frame(height: 44)
            .accessibilityHidden(true)
    }

    private var headerContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.xs) {
            Text("Complete your profile")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text(roleDescription)
                .vdFont(VdFont.bodyLarge)
                .foregroundStyle(Color.vdContentDefaultSecondary)
        }
    }

    private var inputContainer: some View {
        VStack(spacing: VdSpacing.md) {
            VdTextField(
                "Full Name",
                text: $fullName,
                placeholder: "Full Name",
                state: inputState(for: fullNameValidationMessage),
                leadingIcon: "person.fill",
                helperText: fullNameValidationMessage
            )

            VdTextField(
                "Phone Number",
                text: $phoneNumber,
                placeholder: "+97798XXXXXXXX",
                state: inputState(for: phoneNumberValidationMessage),
                leadingIcon: "phone.fill",
                helperText: phoneNumberValidationMessage
            )
        }
    }

    private var buttonContainer: some View {
        VdButton("Complete Profile",fullWidth:true, isLoading: isLoading, action: onSubmit)
            .frame(maxWidth: .infinity)
    }

    private func noticeContainer(_ notice: AuthStepNotice) -> some View {
        VdAlert(
            color: notice.style.authAlertColor,
            title: notice.style.authAlertTitle,
            description: notice.message
        )
    }

    private func inputState(for validationMessage: String?) -> VdInputState {
        validationMessage?.isEmpty == false ? .error : .default
    }

    private var roleDescription: String {
        switch selectedRole {
        case .renter:
            return "Tell us your full name and phone number so owners can trust account records. You can add occupation, family details, and preferences later."
        case .owner:
            return "Tell us your full name and phone number so renters can trust account records. You can add address, ID documents, and payment details later."
        }
    }
}

#Preview {
    ProfileCreationView(
        fullName: .constant(""),
        phoneNumber: .constant(""),
        selectedRole: .renter,
        notice: AuthStepNotice(style: .error, message: "Enter your full name to continue."),
        fullNameValidationMessage: nil,
        phoneNumberValidationMessage: nil,
        isLoading: false,
        onSubmit: {}
    )
}
