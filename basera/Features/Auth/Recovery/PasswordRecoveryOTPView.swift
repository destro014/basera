import SwiftUI
import VroxalDesign

struct PasswordRecoveryOTPView: View {
    @Binding var code: String

    let maskedEmail: String?
    let notice: AuthStepNotice?
    let validationMessage: String?
    let isLoading: Bool
    let canResendCode: Bool
    let resendButtonTitle: String
    let onVerify: () -> Void
    let onResend: () -> Void
    let onEditEmail: () -> Void

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
            Text("Verify your email")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text(descriptionText)
                .vdFont(VdFont.bodyLarge)
                .foregroundStyle(Color.vdContentDefaultSecondary)
        }
    }

    private var inputContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.xs) {
            VdCodeInput(
                code: $code,
                length: 6,
                state: validationMessage?.isEmpty == false ? .error : .default
            )
            .textContentType(.oneTimeCode)

            if let validationMessage, validationMessage.isEmpty == false {
                Text(validationMessage)
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentErrorBase)
            }
        }
    }

    private var buttonContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.smMd) {
            VdButton("Verify email", size: .medium, fullWidth: true, isLoading: isLoading, action: onVerify)
                .frame(maxWidth: .infinity)

            HStack(spacing: 4) {
                Text("Didn't receive the code?")
                    .vdFont(VdFont.bodyLarge)
                    .foregroundStyle(Color.vdContentDefaultSecondary)

                Button {
                    if canResendCode && !isLoading {
                        onResend()
                    }
                } label: {
                    Text(resendButtonTitle)
                        .vdFont(VdFont.labelLarge)
                        .foregroundStyle(canResendCode && !isLoading ? Color.vdContentPrimaryBase : Color.vdContentDefaultSecondary.opacity(0.7))
                }
                .disabled(!canResendCode || isLoading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onEditEmail) {
                Text("Use a different email")
                    .vdFont(.labelLarge)
                    .foregroundStyle(Color.vdContentPrimaryBase)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var descriptionText: String {
        if let maskedEmail, maskedEmail.isEmpty == false {
            return "Enter the 6-digit code we sent to \(maskedEmail) to continue."
        }

        return "Enter the 6-digit code we sent to your email address to continue."
    }

    private func noticeContainer(_ notice: AuthStepNotice) -> some View {
        VdAlert(
            color: notice.style.authAlertColor,
            title: notice.style.authAlertTitle,
            description: notice.message
        )
    }
}

#Preview {
    PasswordRecoveryOTPView(
        code: .constant(""),
        maskedEmail: "pr*****@example.com",
        notice: AuthStepNotice(style: .info, message: "A new code was sent to your email."),
        validationMessage: nil,
        isLoading: false,
        canResendCode: false,
        resendButtonTitle: "Resend in 30s",
        onVerify: {},
        onResend: {},
        onEditEmail: {}
    )
}
