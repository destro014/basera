import SwiftUI
import VroxalDesign

struct BaseraChip: View {
    let text: String
    var color: VdBadgeColor = .primary
    var style: VdBadgeStyle = .subtle
    var size: VdBadgeSize = .medium

    var body: some View {
        VdBadge(
            text,
            color: color,
            style: style,
            size: size,
            rounded: true
        )
    }
}

#Preview {
    BaseraChip(text: "Verified")
        .padding()
}
