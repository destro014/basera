import SwiftUI
import VroxalDesign

struct PasswordRecoveryOTPView: View {
    @Binding var code: String

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
                        .frame(height: VdSpacing.xxl)
                    headerContainer
                    Spacer()
                        .frame(height: VdSpacing.xxl)
                    inputContainer
                    Spacer()
                        .frame(height: VdSpacing.xxl)
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
            Text("Verify your email")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text("Enter the code we sent you to your email address")
                .vdFont(VdFont.bodyLarge)
                .foregroundStyle(Color.vdContentDefaultSecondary)
        }
    }

    private var inputContainer: some View {
        VdTextField(
            title: "Verification code",
            prompt: "6-digit code",
            text: $code,
            keyboardType: .numberPad,
            textContentType: .oneTimeCode,
            textInputAutocapitalization: .never,
            errorMessage: validationMessage
        )
    }

    private var buttonContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.smMd) {
            VdButton(
                title: "Verify code",
                style: .primary,
                isLoading: isLoading,
                action: onVerify
            )

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
                        .foregroundStyle(canResendCode && !isLoading ? Color.vdBackgroundPrimaryBase : Color.vdContentDefaultSecondary.opacity(0.7))
                }
                .disabled(!canResendCode || isLoading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onEditEmail) {
                Text("Use a different email")
                    .vdFont(VdFont.labelLarge)
                    .foregroundStyle(Color.vdContentPrimaryBase)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

}

#Preview {
    PasswordRecoveryOTPView(
        code: .constant(""),
        validationMessage: nil,
        isLoading: false,
        canResendCode: false,
        resendButtonTitle: "Resend in 30s",
        onVerify: {},
        onResend: {},
        onEditEmail: {}
    )
}
