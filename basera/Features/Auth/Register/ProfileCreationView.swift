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
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                        .frame(height: VdSpacing.xl)
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
                .frame(maxWidth: 402, minHeight: max(proxy.size.height - 32, 0), alignment: .top)
                .padding(.horizontal, proxy.size.width >= 520 ? 24 : 16)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
            }
            .background(Color.vdBackgroundDefaultBase.ignoresSafeArea())
        }
    }

    private var logoContainer: some View {
        Image("logo-horizontal")
            .resizable()
            .scaledToFit()
            .frame(height: 40)
            .accessibilityHidden(true)
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

    private func noticeContainer(_ notice: AuthStepNotice) -> some View {
        VdAlert(
            color: alertColor(for: notice.style),
            title: alertTitle(for: notice.style),
            description: notice.message
        )
    }

    private func alertColor(for style: AuthStepNotice.Style) -> VdAlertColor {
        switch style {
        case .info:
            return .info
        case .success:
            return .success
        case .error:
            return .error
        }
    }

    private func alertTitle(for style: AuthStepNotice.Style) -> String {
        switch style {
        case .info:
            return "Info"
        case .success:
            return "Success"
        case .error:
            return "Please Check"
        }
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
