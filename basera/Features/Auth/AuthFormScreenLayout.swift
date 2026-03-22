import SwiftUI
import VroxalDesign

struct AuthFormScreenLayout<HeaderContent: View, InputContent: View, NoticeContent: View, ActionContent: View, FooterContent: View>: View {
    private let headerContent: () -> HeaderContent
    private let inputContent: () -> InputContent
    private let noticeContent: () -> NoticeContent
    private let actionContent: () -> ActionContent
    private let footerContent: () -> FooterContent

    init(
        @ViewBuilder headerContent: @escaping () -> HeaderContent,
        @ViewBuilder inputContent: @escaping () -> InputContent,
        @ViewBuilder noticeContent: @escaping () -> NoticeContent,
        @ViewBuilder actionContent: @escaping () -> ActionContent,
        @ViewBuilder footerContent: @escaping () -> FooterContent
    ) {
        self.headerContent = headerContent
        self.inputContent = inputContent
        self.noticeContent = noticeContent
        self.actionContent = actionContent
        self.footerContent = footerContent
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VdSpacing.none) {
                    Spacer()
                        .frame(height: VdSpacing.xxl)

                    authLogo

                    Spacer()
                        .frame(height: VdSpacing.lg)

                    headerContent()

                    Spacer()
                        .frame(height: VdSpacing.xl)

                    inputContent()

                    noticeContent()

                    actionContent()

                    footerContent()
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

    private var authLogo: some View {
        Image("logo-horizontal")
            .resizable()
            .scaledToFit()
            .frame(height: 44)
            .accessibilityHidden(true)
    }
}

extension AuthStepNotice.Style {
    var authAlertColor: VdAlertColor {
        switch self {
        case .info:
            return .info
        case .success:
            return .success
        case .error:
            return .error
        }
    }

    var authAlertTitle: String {
        switch self {
        case .info:
            return "Notice"
        case .success:
            return "Success"
        case .error:
            return "Error"
        }
    }
}
