import SwiftUI

struct BaseraAvatar: View {
    let initials: String
    var size: CGFloat = 44

    var body: some View {
        Text(initials)
            .font(AppTheme.Typography.body.weight(.bold))
            .foregroundStyle(AppTheme.Colors.onPrimary)
            .frame(width: size, height: size)
            .background(AppTheme.Colors.brandPrimary)
            .clipShape(Circle())
    }
}

#Preview {
    BaseraAvatar(initials: "SB", size: 56)
        .padding()
}
