import SwiftUI

struct BasraAvatar: View {
    let initials: String
    var size: CGFloat = 44

    var body: some View {
        Text(initials)
            .font(AppTheme.Typography.body.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(AppTheme.Colors.brandPrimary)
            .clipShape(Circle())
    }
}

#Preview {
    BasraAvatar(initials: "SB", size: 56)
        .padding()
}
