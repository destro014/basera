import SwiftUI

struct BasraBadge: View {
    let text: String
    let tone: Color

    var body: some View {
        Text(text)
            .font(AppTheme.Typography.caption.weight(.semibold))
            .padding(.horizontal, AppTheme.Spacing.small)
            .padding(.vertical, AppTheme.Spacing.xSmall)
            .background(tone.opacity(0.2))
            .foregroundStyle(tone)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous))
    }
}

#Preview {
    HStack {
        BasraBadge(text: "Active", tone: AppTheme.Colors.success)
        BasraBadge(text: "Draft", tone: AppTheme.Colors.warning)
    }
    .padding()
}
