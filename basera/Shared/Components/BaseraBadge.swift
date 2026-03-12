import SwiftUI

struct BaseraBadge: View {
    let text: String
    let tone: Color

    var body: some View {
        Text(text)
            .baseraTextStyle(AppTheme.Typography.labelMedium)
            .padding(.horizontal, AppTheme.Spacing.small)
            .padding(.vertical, AppTheme.Spacing.xSmall)
            .background(tone.opacity(0.2))
            .foregroundStyle(tone)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous))
    }
}

#Preview {
    HStack {
        BaseraBadge(text: "Active", tone: AppTheme.Colors.successPrimary)
        BaseraBadge(text: "Draft", tone: AppTheme.Colors.warningPrimary)
    }
    .padding()
}
