import SwiftUI

struct AuthOTPVerificationView: View {
    @Binding var otpCode: String

    let validationMessage: String?
    let isLoading: Bool
    let canResendCode: Bool
    let resendButtonTitle: String
    let onVerify: () -> Void
    let onResend: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            BaseraTextField(
                title: "Verification code",
                prompt: "6-digit OTP",
                text: $otpCode,
                keyboardType: .numberPad,
                textContentType: .oneTimeCode,
                textInputAutocapitalization: .never,
                errorMessage: validationMessage
            )

            VStack(spacing: AppTheme.Spacing.small) {
                BaseraButton(
                    title: "Continue",
                    style: .primary,
                    isLoading: isLoading,
                    action: onVerify
                )

                HStack(spacing: 4) {
                    Text("Didn't receive the code")
                        .baseraTextStyle(AppTheme.Typography.bodyMedium)
                        .foregroundStyle(AppTheme.Colors.textSecondary)

                    Button {
                        if canResendCode && !isLoading {
                            onResend()
                        }
                    } label: {
                        Text(resendButtonTitle)
                            .baseraTextStyle(AppTheme.Typography.labelLarge)
                            .foregroundStyle(canResendCode && !isLoading ? AppTheme.Colors.brandPrimary : AppTheme.Colors.textSecondary.opacity(0.7))
                    }
                    .disabled(!canResendCode || isLoading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview("Ready") {
    AuthOTPVerificationView(
        otpCode: .constant(""),
        validationMessage: nil,
        isLoading: false,
        canResendCode: false,
        resendButtonTitle: "Resend in 30s",
        onVerify: {},
        onResend: {}
    )
    .padding()
}

#Preview("Loading") {
    AuthOTPVerificationView(
        otpCode: .constant("246810"),
        validationMessage: nil,
        isLoading: true,
        canResendCode: false,
        resendButtonTitle: "Resend in 18s",
        onVerify: {},
        onResend: {}
    )
    .padding()
}

#Preview("Error") {
    AuthOTPVerificationView(
        otpCode: .constant("000000"),
        validationMessage: "That OTP did not match. Check the 6-digit code and try again.",
        isLoading: false,
        canResendCode: true,
        resendButtonTitle: "Resend code",
        onVerify: {},
        onResend: {}
    )
    .padding()
}
