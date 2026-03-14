import SwiftUI

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
                        .frame(height: AppTheme.Spacing.xxLarge)
                    headerContainer
                    Spacer()
                        .frame(height: AppTheme.Spacing.xxLarge)
                    inputContainer
                    if let notice {
                        Spacer()
                            .frame(height: AppTheme.Spacing.large)

                        BaseraInlineMessageView(
                            tone: tone(for: notice.style),
                            message: notice.message
                        )

                        Spacer()
                            .frame(height: AppTheme.Spacing.large)
                    } else {
                        Spacer()
                            .frame(height: AppTheme.Spacing.xxLarge)
                    }
                    buttonContainer
                }
                .frame(maxWidth: 402, minHeight: max(proxy.size.height - 32, 0), alignment: .top)
                .padding(.horizontal, proxy.size.width >= 520 ? 24 : 16)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.Colors.backgroundPrimary.ignoresSafeArea())
        }
    }

    

    private var headerContainer: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
            Text("Verify your email")
                .baseraTextStyle(AppTheme.Typography.headlineLarge)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Enter the code we sent to your email address to continue.")
                .baseraTextStyle(AppTheme.Typography.bodyLarge)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    private var inputContainer: some View {
        BaseraTextField(
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
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            BaseraButton(
                title: "Verify email",
                style: .primary,
                isLoading: isLoading,
                action: onVerify
            )

            HStack(spacing: 4) {
                Text("Didn't receive the code?")
                    .baseraTextStyle(AppTheme.Typography.bodyLarge)
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

            Button(action: onEditEmail) {
                Text("Use a different email")
                    .baseraTextStyle(AppTheme.Typography.labelLarge)
                    .foregroundStyle(AppTheme.Colors.brandPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func tone(for style: AuthStepNotice.Style) -> BaseraInlineMessageView.Tone {
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
