import SwiftUI

struct AuthOTPVerificationView: View {
    @Binding var otpCode: String

    let maskedPhoneNumber: String
    let validationMessage: String?
    let isLoading: Bool
    let canResendCode: Bool
    let resendButtonTitle: String
    let onVerify: () -> Void
    let onResend: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            Text("Use the latest code sent to \(maskedPhoneNumber).")
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            BaseraTextField(
                title: "Verification code",
                prompt: "6-digit OTP",
                text: $otpCode,
                keyboardType: .numberPad,
                textContentType: .oneTimeCode,
                textInputAutocapitalization: .never,
                errorMessage: validationMessage
            )

            VStack(spacing: AppTheme.Spacing.medium) {
                BaseraButton(
                    title: "Verify code",
                    style: .primary,
                    isLoading: isLoading,
                    action: onVerify
                )

                BaseraButton(
                    title: resendButtonTitle,
                    style: .secondary,
                    isDisabled: canResendCode == false || isLoading,
                    action: onResend
                )
            }
        }
    }
}

#Preview("Ready") {
    AuthOTPVerificationView(
        otpCode: .constant(""),
        maskedPhoneNumber: "+977 98******00",
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
        maskedPhoneNumber: "+977 98******00",
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
        maskedPhoneNumber: "+977 98******00",
        validationMessage: "That OTP did not match. Check the 6-digit code and try again.",
        isLoading: false,
        canResendCode: true,
        resendButtonTitle: "Resend code",
        onVerify: {},
        onResend: {}
    )
    .padding()
}
