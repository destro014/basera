import SwiftUI
import VroxalDesign

struct OTPVerificationView: View {
    @Binding var code: String

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
        }
    }

    

    private var headerContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.xs) {
            Text("Verify your email")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text("Enter the code we sent to your email address to continue.")
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
            if let validationMessage, validationMessage.isEmpty == false {
                Text(validationMessage)
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentErrorBase)
            }
        }
    }

    private var buttonContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.smMd) {
            VdButton("Verify email", fullWidth: true, isLoading: isLoading, action: onVerify)
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
}

#Preview {
    OTPVerificationView(
        code: .constant(""),
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
