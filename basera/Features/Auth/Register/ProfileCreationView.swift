import SwiftUI
import VroxalDesign

struct ProfileCreationView: View {
    @Binding var fullName: String
    @Binding var phoneNumber: String

    let notice: AuthStepNotice?
    let fullNameValidationMessage: String?
    let phoneNumberValidationMessage: String?
    let isLoading: Bool
    let onSubmit: () -> Void

    var body: some View {
        AuthFormScreenLayout(
            headerContent: { headerContainer },
            inputContent: { inputContainer },
            noticeContent: { noticeSection },
            actionContent: { buttonContainer },
            footerContent: { EmptyView() }
        )
    }

    private var headerContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.xs) {
            Text("Complete your profile")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text("Tell us your full name and phone number so owners and renters can trust account records.")
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

    @ViewBuilder
    private var noticeSection: some View {
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
}

#Preview {
    ProfileCreationView(
        fullName: .constant(""),
        phoneNumber: .constant(""),
        notice: AuthStepNotice(style: .error, message: "Enter your full name to continue."),
        fullNameValidationMessage: nil,
        phoneNumberValidationMessage: nil,
        isLoading: false,
        onSubmit: {}
    )
}
