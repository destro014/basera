import SwiftUI
import VroxalDesign

struct PasswordResetView: View {
    @Binding var newPassword: String
    @Binding var confirmPassword: String

    let notice: AuthStepNotice?
    let newPasswordValidationMessage: String?
    let confirmPasswordValidationMessage: String?
    let isLoading: Bool
    let onSubmit: () -> Void

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
                title: "New Password",
                prompt: "Minimum 8 characters",
                text: $newPassword,
                textContentType: .newPassword,
                textInputAutocapitalization: .never,
                isSecure: true,
                allowsSecureTextToggle: true,
                errorMessage: newPasswordValidationMessage
            )

            VdTextField(
                title: "Confirm Password",
                prompt: "Re-enter password",
                text: $confirmPassword,
                textContentType: .newPassword,
                textInputAutocapitalization: .never,
                isSecure: true,
                allowsSecureTextToggle: true,
                errorMessage: confirmPasswordValidationMessage
            )
        }
    }

    private var buttonContainer: some View {
        VdButton(
            title: "Update Password",
            style: .primary,
            isLoading: isLoading,
            action: onSubmit
        )
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
