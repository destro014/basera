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
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                        .frame(height: VdSpacing.xxl)
                    headerContainer
                    Spacer()
                        .frame(height: VdSpacing.xxl)
                    inputContainer
                    if let notice {
                        Spacer()
                            .frame(height: VdSpacing.md)

                        VdAlert(
                            tone: tone(for: notice.style),
                            message: notice.message
                        )

                        Spacer()
                            .frame(height: VdSpacing.md)
                    } else {
                        Spacer()
                            .frame(height: VdSpacing.xxl)
                    }
                    buttonContainer
                    Spacer()
                        .frame(height: VdSpacing.md)
                    backToLoginContainer
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
            Text("Recover password")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text("Enter your account email to receive a verification code for password recovery.")
                .vdFont(VdFont.bodyLarge)
                .foregroundStyle(Color.vdContentDefaultSecondary)
        }
    }

    private var inputContainer: some View {
        VdTextField(
            title: "Email",
            prompt: "you@example.com",
            text: $email,
            keyboardType: .emailAddress,
            textContentType: .emailAddress,
            textInputAutocapitalization: .never,
            errorMessage: emailValidationMessage
        )
    }

    private var buttonContainer: some View {
        VdButton(
            title: "Send code",
            style: .primary,
            isLoading: isLoading,
            action: onSubmit
        )
    }

    private var backToLoginContainer: some View {
        HStack(spacing: VdSpacing.xs) {
            Text("Remember your password?")
                .vdFont(VdFont.bodyLarge)
                .foregroundStyle(Color.vdContentDefaultSecondary)

            Button(action: onBackToLogin) {
                Text("Login")
                    .vdFont(VdFont.labelLarge)
                    .foregroundStyle(Color.vdContentPrimaryBase)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func tone(for style: AuthStepNotice.Style) -> BaseraVdAlertTone {
        switch style {
        case .info:
            .info
        case .success:
            .success
        case .error:
            .error
        }
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
