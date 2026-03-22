import SwiftUI
import VroxalDesign

struct RegistrationPasswordView: View {
    @Binding var password: String
    @Binding var confirmPassword: String
    @State private var previousPasswordValue = ""

    let notice: AuthStepNotice?
    let passwordValidationMessage: String?
    let confirmPasswordValidationMessage: String?
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

    

    private var headerContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.xs) {
            Text("Create password")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text("Create a secure password before you complete your profile.")
                .vdFont(VdFont.bodyLarge)
                .foregroundStyle(Color.vdContentDefaultSecondary)
        }
    }

    private var inputContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.md) {
            VdTextField(
                "Password",
                text: $password,
                placeholder: "Minimum 8 characters",
                state: inputState(for: passwordValidationMessage),
                isSecure: true,
                leadingIcon: "lock",
                helperText: passwordValidationMessage
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .textContentType(.newPassword)
            .onChange(of: password) { newValue in
                syncConfirmPasswordIfNeeded(with: newValue)
            }

            VdTextField(
                "Confirm Password",
                text: $confirmPassword,
                placeholder: "Re-enter password",
                state: inputState(for: confirmPasswordValidationMessage),
                isSecure: true,
                leadingIcon: "lock",
                helperText: confirmPasswordValidationMessage
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .textContentType(.newPassword)
        }
    }

    private var buttonContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.sm) {
            VdButton("Create Password", fullWidth: true, isLoading: isLoading, action: onSubmit)
                .frame(maxWidth: .infinity)

            Text("By continuing, you agree to [Terms and Conditions](https://pramodpoudel.com.np/) and [Privacy Policy](https://pramodpoudel.com.np/).")
                .vdFont(VdFont.bodyMedium)
                .foregroundStyle(Color.vdContentDefaultSecondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .tint(Color.vdContentPrimaryBase)
        }
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

    private func syncConfirmPasswordIfNeeded(with newValue: String) {
        defer { previousPasswordValue = newValue }

        guard newValue.isEmpty == false else { return }
        guard confirmPassword.isEmpty || confirmPassword == previousPasswordValue else { return }

        let grewBy = newValue.count - previousPasswordValue.count
        let appearsToBeAutoFill = grewBy > 1 || (previousPasswordValue.isEmpty && newValue.count >= 8)

        if appearsToBeAutoFill {
            confirmPassword = newValue
        }
    }
}

#Preview {
    RegistrationPasswordView(
        password: .constant(""),
        confirmPassword: .constant(""),
        notice: nil,
        passwordValidationMessage: nil,
        confirmPasswordValidationMessage: nil,
        isLoading: false,
        onSubmit: {}
    )
}
