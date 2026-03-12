import SwiftUI

struct BaseraInlineMessageView: View {
    enum Tone {
        case info
        case success
        case error

        var color: Color {
            switch self {
            case .info:
                AppTheme.Colors.infoPrimary
            case .success:
                AppTheme.Colors.successPrimary
            case .error:
                AppTheme.Colors.errorPrimary
            }
        }

        var iconName: String {
            switch self {
            case .info:
                "info.circle.fill"
            case .success:
                "checkmark.circle.fill"
            case .error:
                "exclamationmark.triangle.fill"
            }
        }
    }

    let tone: Tone
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.small) {
            Image(systemName: tone.iconName)
                .foregroundStyle(tone.color)

            Text(message)
                .baseraTextStyle(AppTheme.Typography.bodySmall)
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(AppTheme.Spacing.medium)
        .background(tone.color.opacity(0.08))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                .stroke(tone.color.opacity(0.18), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 12) {
        BaseraInlineMessageView(tone: .info, message: "We sent a new OTP to your phone.")
        BaseraInlineMessageView(tone: .success, message: "Profile photo selected and ready to upload.")
        BaseraInlineMessageView(tone: .error, message: "That OTP did not match.")
    }
    .padding()
}
