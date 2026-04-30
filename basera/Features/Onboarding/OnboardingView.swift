import Combine
import SwiftUI
import VroxalDesign

struct OnboardingView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = OnboardingViewModel()

    // Fractional slide position: 0.0 = first slide, 1.0 = second, etc.
    // Animates smoothly between values — avoids the integer-snap discontinuity.
    @State private var slidePosition: CGFloat = 0
    @State private var safeAreaTop: CGFloat = 0
    @State private var safeAreaBottom: CGFloat = 0

    let notice: AuthStepNotice?
    let onLogin: () -> Void
    let onRegister: () -> Void
    let isPreviewMode: Bool

    private let progressBarHeight: CGFloat = 4
    private let autoplayTimer = Timer.publish(
        every: OnboardingViewModel.timerStep,
        on: .main,
        in: .common
    ).autoconnect()

    init(
        notice: AuthStepNotice?,
        onLogin: @escaping () -> Void,
        onRegister: @escaping () -> Void,
        isPreviewMode: Bool = false
    ) {
        self.notice = notice
        self.onLogin = onLogin
        self.onRegister = onRegister
        self.isPreviewMode = isPreviewMode
    }

    private var shouldUseStaticPreviewMode: Bool {
        isPreviewMode
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                slideImageLayer(width: proxy.size.width)

                VStack(spacing: 0) {
                    topBar(safeAreaTop: safeAreaTop)
                    Spacer()
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)

                bottomCard(bottomInset: safeAreaBottom, screenWidth: proxy.size.width)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .gesture(swipeGesture(width: proxy.size.width))
        }
        .ignoresSafeArea()
        .onAppear {
            let insets = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?
                .safeAreaInsets
            safeAreaTop = insets?.top ?? 0
            safeAreaBottom = insets?.bottom ?? 0
            slidePosition = CGFloat(viewModel.currentIndex)
            viewModel.setPlaybackActive(!shouldUseStaticPreviewMode)
        }
        .onDisappear {
            viewModel.setPlaybackActive(false)
        }
        .onChange(of: scenePhase) { newValue in
            viewModel.setPlaybackActive(!shouldUseStaticPreviewMode && newValue == .active)
        }
        .onChange(of: viewModel.currentIndex) { newIndex in
            withAnimation(.easeInOut(duration: 0.45)) {
                slidePosition = CGFloat(newIndex)
            }
        }
        .onReceive(autoplayTimer) { _ in
            guard !shouldUseStaticPreviewMode else { return }
            viewModel.tick()
        }
    }

    // MARK: - Image layer

    private func slideImageLayer(width: CGFloat) -> some View {
        ZStack {
            ForEach(Array(viewModel.slides.enumerated()), id: \.element.id) { index, slide in
                Image(slide.imageAssetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width)
                    .clipped()
                    .offset(x: (CGFloat(index) - slidePosition) * width)
            }
        }
        .clipped()
    }

    // MARK: - Swipe gesture

    private func swipeGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 15)
            .onChanged { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                let raw = CGFloat(viewModel.currentIndex) - value.translation.width / width
                slidePosition = raw.clamped(to: 0...CGFloat(viewModel.slides.count - 1))
            }
            .onEnded { value in
                let dragFraction = value.translation.width / width
                let velocityFraction = value.predictedEndTranslation.width / width
                let threshold: CGFloat = 0.25

                let targetIndex: Int
                if dragFraction < -threshold || velocityFraction < -threshold {
                    targetIndex = min(viewModel.currentIndex + 1, viewModel.slides.count - 1)
                } else if dragFraction > threshold || velocityFraction > threshold {
                    targetIndex = max(viewModel.currentIndex - 1, 0)
                } else {
                    targetIndex = viewModel.currentIndex
                }

                withAnimation(.easeInOut(duration: 0.3)) {
                    slidePosition = CGFloat(targetIndex)
                }
                viewModel.selectSlide(targetIndex)
            }
    }

    // MARK: - Top bar

    private func topBar(safeAreaTop: CGFloat) -> some View {
        progressIndicator
            .padding(.horizontal, VdSpacing.s400)
            .padding(.top, safeAreaTop + VdSpacing.s400)
            .padding(.bottom, VdSpacing.s300)
    }

    private var progressIndicator: some View {
        HStack(spacing: 3) {
            ForEach(Array(viewModel.progressValues.enumerated()), id: \.offset) { index, progress in
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.4))

                        Capsule()
                            .fill(Color.white)
                            .frame(width: proxy.size.width * progress)
                    }
                }
                .frame(height: progressBarHeight)
            }
        }
        .frame(height: progressBarHeight)
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentIndex)
    }

    // MARK: - Bottom card

    private func bottomCard(bottomInset: CGFloat, screenWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: VdSpacing.s1000) {
            slideTextContent
            

            footer(bottomInset: bottomInset)
        }
        .padding(.horizontal, VdSpacing.s600)

        .padding(.top, VdSpacing.s1000)
        .padding(.bottom, max(bottomInset, VdSpacing.s800))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .foregroundStyle(Color.vdBackgroundDefaultBase)
        .clipShape(RoundedRectangle(cornerRadius: VdSpacing.s1000, style: .continuous))
        .padding(.horizontal, VdSpacing.s200)
        .padding(.bottom, VdSpacing.s200)
    }

    private var slideTextContent: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(viewModel.slides.enumerated()), id: \.element.id) { index, slide in
                if index == viewModel.currentIndex {
                    VStack(alignment: .leading, spacing: VdSpacing.s100) {
                        Text(slide.title)
                            .vdFont(VdFont.headlineLarge)
                            .foregroundStyle(Color.vdContentDefaultBase)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(slide.message)
                            .vdFont(VdFont.bodyLarge)
                            .foregroundStyle(Color.vdContentDefaultBase)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
                    .id(slide.id)
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.currentIndex)
    }

    // MARK: - Footer buttons

    private func footer(bottomInset: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: VdSpacing.s400) {
            if let notice {
                VdAlert(tone: tone(for: notice.style), message: notice.message)
            }

            HStack(spacing: VdSpacing.s400) {
                VdButton("Login", style: .subtle, size: .large, action: onLogin)
                    .fixedSize(horizontal: false, vertical: true)

                VdButton("Create account", style: .solid, size: .large, fullWidth: true, action: onRegister)
            }
        }
    }

    private func tone(for style: AuthStepNotice.Style) -> BaseraVdAlertTone {
        switch style {
        case .info: .info
        case .success: .success
        case .error: .error
        }
    }
}

// MARK: - Helpers

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Palette

private enum OnboardingPalette {
    static let cardBackground = Color(red: 231 / 255, green: 230 / 255, blue: 245 / 255).opacity(0.7)
    static let title = Color(red: 4 / 255, green: 2 / 255, blue: 26 / 255)
    static let body = Color(red: 72 / 255, green: 70 / 255, blue: 92 / 255)
}

#Preview {
    OnboardingView(
        notice: nil,
        onLogin: {},
        onRegister: {},
        isPreviewMode: false
    )
}
