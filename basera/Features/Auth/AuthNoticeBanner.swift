import SwiftUI
import VroxalDesign

struct AuthNoticeBanner: View {
    let notice: AuthStepNotice

    var body: some View {
        HStack(alignment: .top, spacing: VdSpacing.sm) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .padding(2)
                .foregroundStyle(iconColor)
                .frame(width: VdIconSize.md, height: VdIconSize.md)

            Text(notice.message)
                .vdFont(VdFont.labelMedium)
                .foregroundStyle(Color.vdContentDefaultBase)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(VdSpacing.md)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                .strokeBorder(borderColor, lineWidth: VdBorderWidth.sm)
        }
    }

    private var iconName: String {
        switch notice.style {
        case .info:
            return "info.circle.fill"
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.circle.fill"
        }
    }

    private var iconColor: Color {
        switch notice.style {
        case .info:
            return .vdContentInfoBase
        case .success:
            return .vdContentSuccessBase
        case .error:
            return .vdContentErrorBase
        }
    }

    private var backgroundColor: Color {
        switch notice.style {
        case .info:
            return .vdBackgroundInfoSecondary
        case .success:
            return .vdBackgroundSuccessSecondary
        case .error:
            return .vdBackgroundErrorSecondary
        }
    }

    private var borderColor: Color {
        switch notice.style {
        case .info:
            return .vdBorderInfoSecondary
        case .success:
            return .vdBorderSuccessSecondary
        case .error:
            return .vdBorderErrorSecondary
        }
    }
}
