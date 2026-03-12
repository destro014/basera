import SwiftUI

struct AuthOnboardingContainerView<Content: View>: View {
    let step: AuthFlowStep
    let notice: AuthStepNotice?
    @ViewBuilder let content: () -> Content

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xLarge) {
                    if step.showsProductOverview {
                        introHeader
                    }

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                        Text(step.title)
                            .baseraTextStyle(AppTheme.Typography.headlineLarge)
                            .foregroundStyle(AppTheme.Colors.textPrimary)

                        Text(step.subtitle)
                            .baseraTextStyle(AppTheme.Typography.bodyLarge)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }

                    if step != .otpVerification, let notice {
                        BaseraInlineMessageView(tone: tone(for: notice.style), message: notice.message)
                    }

                    content()

                    if step == .introduction {
                        Spacer(minLength: 0)
                    }
                }
                .frame(maxWidth: 402, minHeight: max(proxy.size.height - 32, 0), alignment: .top)
                .padding(.horizontal, proxy.size.width >= 520 ? 24 : 16)
                .padding(.top, 24)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity)
            }
            .background(backgroundView)
        }
    }

    private var introHeader: some View {
        Image("logo-horizontal")
            .resizable()
            .scaledToFit()
            .frame(width: 245, height: 62)
            .accessibilityHidden(true)
    }

    private var backgroundView: some View {
        AppTheme.Colors.backgroundPrimary
            .ignoresSafeArea()
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

#Preview("Compact") {
    AuthOnboardingContainerView(
        step: .introduction,
        notice: AuthStepNotice(style: .info, message: "We will only use your number for OTP verification.")
    ) {
        Text("Auth content goes here.")
            .baseraTextStyle(AppTheme.Typography.bodyLarge)
            .foregroundStyle(AppTheme.Colors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("iPad") {
    AuthOnboardingContainerView(
        step: .phoneNumber,
        notice: AuthStepNotice(style: .success, message: "Profile photo selected and ready to upload.")
    ) {
        Text("Large-screen preview content.")
            .baseraTextStyle(AppTheme.Typography.bodyLarge)
            .foregroundStyle(AppTheme.Colors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    .frame(width: 1112, height: 834)
}
