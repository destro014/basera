import SwiftUI
import VroxalDesign

struct BaseraCard<Content: View>: View {
    let backgroundColor: Color
    @ViewBuilder let content: Content

    init(
        backgroundColor: Color = Color.vdBackgroundDefaultSecondary,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    var body: some View {
        content
            .padding(VdSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg, style: .continuous))
    }
}

#Preview {
    BaseraCard {
        Text("Basera card content")
            .vdFont(VdFont.bodyLarge)
            .foregroundStyle(Color.vdContentDefaultBase)
    }
    .padding()
}
