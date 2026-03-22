import SwiftUI
import VroxalDesign

struct PasswordRecoveryEmailView: View {
    @Binding var email: String

    let notice: AuthStepNotice?
    let emailValidationMessage: String?
    let isLoading: Bool
    let onSubmit: () -> Void
    let onBackToLogin: () -> Void

    var body: some View {
        AuthFormScreenLayout(
            headerContent: { headerContainer },
            inputContent: { inputContainer },
            noticeContent: { noticeSection },
            actionContent: { buttonContainer },
            footerContent: { backToLoginSection }
        )
    }

    private var headerContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.xs) {
            Text("Recover password")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text("Enter your account email to receive a verification code for password recovery.")
                .vdFont(VdFont.bodyLarge)
                .foregroundStyle(Color.vdContentDefaultSecondary)
        }
    }

    private var inputContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.md) {
            VdTextField(
                "Email",
                text: $email,
                placeholder: "you@example.com",
                state: inputState(for: emailValidationMessage),
                leadingIcon: "envelope",
                helperText: emailValidationMessage
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
        }
    }

    private var buttonContainer: some View {
        VdButton("Send code", fullWidth: true, isLoading: isLoading, action: onSubmit)
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

    private var backToLoginSection: some View {
        VStack(alignment: .leading, spacing: VdSpacing.none) {
            Spacer()
                .frame(height: VdSpacing.md)

            HStack(spacing: VdSpacing.xs) {
                Text("Remember your password?")
                    .vdFont(VdFont.bodyMedium)
                    .foregroundStyle(Color.vdContentDefaultSecondary)

                Button(action: onBackToLogin) {
                    Text("Login")
                        .vdFont(VdFont.labelMedium)
                        .foregroundStyle(Color.vdContentPrimaryBase)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func inputState(for validationMessage: String?) -> VdInputState {
        validationMessage == nil ? .default : .error
    }
}

#Preview {
    PasswordRecoveryEmailView(
        email: .constant(""),
        notice: nil,
        emailValidationMessage: nil,
        isLoading: false,
        onSubmit: {},
        onBackToLogin: {}
    )
}
