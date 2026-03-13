import SwiftUI

struct BaseraActionTile: View {
    let title: String
    let subtitle: String?
    let systemImage: String

    var body: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.medium) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.brandPrimary)
                .frame(width: 36, height: 36)
                .background(AppTheme.Colors.brandSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                Text(title)
                    .baseraTextStyle(AppTheme.Typography.labelLarge)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                if let subtitle, subtitle.isEmpty == false {
                    Text(subtitle)
                        .baseraTextStyle(AppTheme.Typography.bodySmall)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(AppTheme.Spacing.medium)
        .background(AppTheme.Colors.surfacePrimary)
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                .stroke(AppTheme.Colors.borderSecondary, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
    }
}

#Preview {
    BaseraActionTile(
        title: "Open Payments",
        subtitle: "Track paid and due invoices",
        systemImage: "creditcard"
    )
    .padding()
}
