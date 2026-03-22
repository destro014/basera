import SwiftUI
import VroxalDesign

struct PasswordResetView: View {
    @Binding var newPassword: String
    @Binding var confirmPassword: String
    @State private var isNewPasswordSecure = true
    @State private var isConfirmPasswordSecure = true

    let notice: AuthStepNotice?
    let newPasswordValidationMessage: String?
    let confirmPasswordValidationMessage: String?
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
            Text("Create new password")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text("Set a new password for your account. Use at least 8 characters.")
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
        VdButton("Update Password", fullWidth: true, isLoading: isLoading, action: onSubmit)
    }

    @ViewBuilder
    private var noticeSection: some View {
        if let notice {
            Spacer()
                .frame(height: VdSpacing.md)

            VdAlert(
                color: notice.style.authAlertColor,
                title: notice.style.authAlertTitle,
                description: notice.message
            )

            Spacer()
                .frame(height: VdSpacing.md)
        } else {
            Spacer()
                .frame(height: VdSpacing.xl)
        }
    }

    private func inputState(for validationMessage: String?) -> VdInputState {
        validationMessage == nil ? .default : .error
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
