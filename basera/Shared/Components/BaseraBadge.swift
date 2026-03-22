import SwiftUI
import VroxalDesign

struct BaseraBadge: View {
    let text: String
    var color: VdBadgeColor = .neutral
    var style: VdBadgeStyle = .subtle
    var size: VdBadgeSize = .medium
    var rounded: Bool = false

    var body: some View {
        VdBadge(
            text,
            color: color,
            style: style,
            size: size,
            rounded: rounded
        )
    }
}

#Preview {
    HStack {
        BaseraBadge(text: "Active", color: .success)
        BaseraBadge(text: "Draft", color: .warning)
    }
    .padding()
}
