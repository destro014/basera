import SwiftUI

struct AuthOnboardingContainerView<Content: View>: View {
    let step: AuthFlowStep
    let notice: AuthStepNotice?
    let canGoBack: Bool
    let onBack: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        GeometryReader { proxy in
            let usesWideLayout = proxy.size.width >= 900

            ZStack {
                backgroundView

                if step.showsProductOverview {
                    if usesWideLayout {
                        introductionWideLayout
                            .padding(32)
                    } else {
                        introductionCompactLayout
                    }
                } else {
                    standardLayout(isWideLayout: usesWideLayout)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private var introductionWideLayout: some View {
        HStack(spacing: 32) {
            heroPanel(centered: false)
                .frame(maxWidth: 340, alignment: .leading)

            ScrollView(showsIndicators: false) {
                contentCard
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            }
        }
    }

    private var introductionCompactLayout: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                heroPanel(centered: true)
                    .padding(.top, 24)

                contentCard
                    .padding(.bottom, 24)
            }
            .frame(maxWidth: 560)
            .padding(.horizontal, 20)
        }
    }

    private func standardLayout(isWideLayout: Bool) -> some View {
        ScrollView(showsIndicators: false) {
            VStack {
                contentCard
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, isWideLayout ? 32 : 20)
            .padding(.vertical, isWideLayout ? 48 : 24)
            .frame(maxWidth: .infinity, minHeight: isWideLayout ? 0 : nil)
        }
    }

    private var contentCard: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                if step.countsTowardsProgress {
                    header
                }

                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    Text(step.title)
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text(step.subtitle)
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }

                if let notice {
                    BaseraInlineMessageView(tone: tone(for: notice.style), message: notice.message)
                }

                content()
            }
        }
        .shadow(color: Color.black.opacity(0.08), radius: 24, y: 12)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            HStack {
                if canGoBack {
                    Button(action: onBack) {
                        Label("Back", systemImage: "chevron.left")
                            .font(AppTheme.Typography.body.weight(.semibold))
                            .foregroundStyle(AppTheme.Colors.brandPrimary)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Text("Step \((step.progressIndex ?? 0) + 1) of \(AuthFlowStep.progressSteps.count)")
                    .font(AppTheme.Typography.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            HStack(spacing: AppTheme.Spacing.small) {
                ForEach(AuthFlowStep.progressSteps) { item in
                    Capsule()
                        .fill((item.progressIndex ?? 0) <= (step.progressIndex ?? -1) ? AppTheme.Colors.brandPrimary : AppTheme.Colors.border.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .frame(height: 6)
                }
            }
        }
    }

    private func heroPanel(centered: Bool) -> some View {
        let alignment: HorizontalAlignment = centered ? .center : .leading

        return VStack(alignment: alignment, spacing: AppTheme.Spacing.large) {
            BaseraAvatar(initials: "BA", size: 72)

            VStack(alignment: alignment, spacing: AppTheme.Spacing.small) {
                Text("Basera")
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .foregroundStyle(AppTheme.Colors.onPrimary)

                Text("Rental records that stay organised from day one.")
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.onPrimary)

                Text("Use one account for renter and owner work, keep exact property addresses private until approval, and manage agreements and monthly billing in one place.")
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.onPrimary.opacity(0.86))
                    .multilineTextAlignment(centered ? .center : .leading)
            }

            VStack(alignment: alignment, spacing: AppTheme.Spacing.medium) {
                heroPoint(iconName: "person.2.fill", text: "Choose renter, owner, or both roles under one account.")
                heroPoint(iconName: "lock.shield.fill", text: "Exact property addresses stay hidden until owner approval.")
                heroPoint(iconName: "calendar.badge.clock", text: "Agreements and monthly invoices remain accessible through move-out.")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: centered ? .center : .leading)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.Colors.brandPrimary,
                            AppTheme.Colors.info,
                            AppTheme.Colors.brandSecondary
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private func heroPoint(iconName: String, text: String) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.small) {
            Image(systemName: iconName)
                .foregroundStyle(AppTheme.Colors.onPrimary)
                .frame(width: 20)

            Text(text)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.onPrimary.opacity(0.92))
        }
    }

    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.Colors.backgroundLight,
                    AppTheme.Colors.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(AppTheme.Colors.brandPrimary.opacity(0.08))
                .frame(width: 280, height: 280)
                .blur(radius: 4)
                .offset(x: -180, y: -260)

            Circle()
                .fill(AppTheme.Colors.brandSecondary.opacity(0.1))
                .frame(width: 220, height: 220)
                .blur(radius: 8)
                .offset(x: 180, y: 260)
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

#Preview("Compact") {
    AuthOnboardingContainerView(
        step: .introduction,
        notice: AuthStepNotice(style: .info, message: "We will only use your number for OTP verification."),
        canGoBack: false,
        onBack: {}
    ) {
        Text("Auth content goes here.")
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("iPad") {
    AuthOnboardingContainerView(
        step: .phoneNumber,
        notice: AuthStepNotice(style: .success, message: "Profile photo selected and ready to upload."),
        canGoBack: true,
        onBack: {}
    ) {
        Text("Large-screen preview content.")
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    .frame(width: 1112, height: 834)
}
