import SwiftUI
import VroxalDesign

struct PasswordResetView: View {
    @Binding var newPassword: String
    @Binding var confirmPassword: String
    @State private var isNewPasswordSecure = true
    @State private var isConfirmPasswordSecure = true
    @State private var previousPasswordValue = ""

    let notice: AuthStepNotice?
    let newPasswordValidationMessage: String?
    let confirmPasswordValidationMessage: String?
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
            Text("Create new password")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text("Create a secure password for your account before you return to login.")
                .vdFont(VdFont.bodyLarge)
                .foregroundStyle(Color.vdContentDefaultSecondary)
        }
    }

    private var inputContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.md) {
            VdTextField(
                "New Password",
                text: $newPassword,
                placeholder: "Minimum 8 characters",
                state: inputState(for: newPasswordValidationMessage),
                isSecure: isNewPasswordSecure,
                leadingIcon: "lock",
                helperText: newPasswordValidationMessage,
                trailingIcon: isNewPasswordSecure ? "eye" : "eye.slash",
                onTrailingAction: { isNewPasswordSecure.toggle() }
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .textContentType(.newPassword)
            .onChange(of: newPassword) { newValue in
                syncConfirmPasswordIfNeeded(with: newValue)
            }

            VdTextField(
                "Confirm Password",
                text: $confirmPassword,
                placeholder: "Re-enter password",
                state: inputState(for: confirmPasswordValidationMessage),
                isSecure: isConfirmPasswordSecure,
                leadingIcon: "lock",
                helperText: confirmPasswordValidationMessage,
                trailingIcon: isConfirmPasswordSecure ? "eye" : "eye.slash",
                onTrailingAction: { isConfirmPasswordSecure.toggle() }
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .textContentType(.newPassword)
        }
    }

    private var buttonContainer: some View {
        VdButton(
            "Update Password",
            size: .large,
            fullWidth: true,
            isLoading: isLoading,
            action: onSubmit
        )
    }

    private func noticeContainer(_ notice: AuthStepNotice) -> some View {
        AuthNoticeBanner(notice: notice)
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
    PasswordResetView(
        newPassword: .constant(""),
        confirmPassword: .constant(""),
        notice: nil,
        newPasswordValidationMessage: nil,
        confirmPasswordValidationMessage: nil,
        isLoading: false,
        onSubmit: {}
    )
}
