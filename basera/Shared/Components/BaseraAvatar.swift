import SwiftUI
import VroxalDesign

struct BaseraAvatar: View {
    let initials: String
    var size: CGFloat = 44

    var body: some View {
        Text(initials)
            .vdFont(VdFont.titleMedium)
            .foregroundStyle(Color.vdContentPrimaryOnBase)
            .frame(width: size, height: size)
            .background(Color.vdBackgroundPrimaryBase)
            .clipShape(Circle())
    }
}

#Preview {
    BaseraAvatar(initials: "SB", size: 56)
        .padding()
}
