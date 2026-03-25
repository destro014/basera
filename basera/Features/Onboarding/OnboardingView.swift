import Combine
import SwiftUI
import VroxalDesign

struct OnboardingView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = OnboardingViewModel()

    let notice: AuthStepNotice?
    let onLogin: () -> Void
    let onRegister: () -> Void

    private let progressBarHeight: CGFloat = 4
    private let progressSpacing: CGFloat = 8
    private let autoplayTimer = Timer.publish(
        every: OnboardingViewModel.timerStep,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding = proxy.size.width >= 520 ? 24.0 : 16.0

            VStack(spacing: 0) {
                header(horizontalPadding: horizontalPadding)

                storyPager(horizontalPadding: horizontalPadding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                footer(horizontalPadding: horizontalPadding, bottomInset: proxy.safeAreaInsets.bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(OnboardingPalette.screenBackground.ignoresSafeArea())
        }
        .onAppear {
            viewModel.setPlaybackActive(true)
        }
        .onDisappear {
            viewModel.setPlaybackActive(false)
        }
        .onChange(of: scenePhase) { newValue in
            viewModel.setPlaybackActive(newValue == .active)
        }
        .onReceive(autoplayTimer) { _ in
            viewModel.tick()
        }
    }

    private func header(horizontalPadding: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Image("logo-horizontal")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                .accessibilityHidden(true)

            progressIndicator
        }
        .frame(maxWidth: 402, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 16)
    }

    private var progressIndicator: some View {
        HStack(spacing: progressSpacing) {
            ForEach(Array(viewModel.progressValues.enumerated()), id: \.offset) { index, progress in
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(OnboardingPalette.progressTrack)

                        Capsule()
                            .fill(index <= viewModel.currentIndex ? OnboardingPalette.progressFill : .clear)
                            .frame(width: proxy.size.width * progress)
                    }
                }
                .frame(height: progressBarHeight)
            }
        }
        .frame(height: progressBarHeight)
    }

    private func storyPager(horizontalPadding: CGFloat) -> some View {
        TabView(
            selection: Binding(
                get: { viewModel.currentIndex },
                set: { newValue in
                    viewModel.selectSlide(newValue)
                }
            )
        ) {
            ForEach(Array(viewModel.slides.enumerated()), id: \.element.id) { index, slide in
                OnboardingSlidePage(slide: slide)
                    .padding(.top, 24)
                    .padding(.horizontal, horizontalPadding)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.26), value: viewModel.currentIndex)
    }

    private func footer(horizontalPadding: CGFloat, bottomInset: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let notice {
                VdAlert(tone: tone(for: notice.style), message: notice.message)
            }

            HStack(spacing: 16) {
                VdButton(title: "Login", style: .subtle, action: onLogin)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: 87)

                VdButton(title: "Create account", style: .primary, action: onRegister)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: 402, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, max(bottomInset, 8))
        .padding(.top, 16)
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

private struct OnboardingSlidePage: View {
    let slide: OnboardingViewModel.Slide

    var body: some View {
        GeometryReader { proxy in
            let imageHeight = min(320, max(160, proxy.size.height * 0.52))

            VStack(alignment: .leading, spacing: 24) {
                OnboardingIllustrationCard(slide: slide)
                    .frame(height: imageHeight)

                VStack(alignment: .leading, spacing: 8) {
                    Text(slide.title)
                        .vdFont(VdFont.headlineLarge)
                        .foregroundStyle(OnboardingPalette.title)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(slide.message)
                        .vdFont(VdFont.bodyLarge)
                        .foregroundStyle(OnboardingPalette.body)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: 402, maxHeight: .infinity, alignment: .top)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

private struct OnboardingIllustrationCard: View {
    let slide: OnboardingViewModel.Slide

    var body: some View {
        Image(slide.imageAssetName)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .background(OnboardingPalette.illustrationBackground)
            .accessibilityHidden(true)
    }
}

private enum OnboardingPalette {
    static let screenBackground = Color(red: 231 / 255, green: 230 / 255, blue: 245 / 255)
    static let illustrationBackground = Color(red: 215 / 255, green: 213 / 255, blue: 229 / 255)
    static let progressTrack = Color(red: 159 / 255, green: 156 / 255, blue: 186 / 255)
    static let progressFill = Color(red: 90 / 255, green: 74 / 255, blue: 244 / 255)
    static let title = Color(red: 4 / 255, green: 2 / 255, blue: 26 / 255)
    static let body = Color(red: 72 / 255, green: 70 / 255, blue: 92 / 255)
}
        
#Preview {
    OnboardingView(
        notice: nil,
        onLogin: {},
        onRegister: {}
    )
}
