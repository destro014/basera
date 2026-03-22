import SwiftUI
import VroxalDesign

struct ProfileSectionView<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: VdSpacing.smMd) {
                VStack(alignment: .leading, spacing: VdSpacing.xs) {
                    Text(title)
                        .vdFont(VdFont.titleMedium)
                    if let subtitle {
                        Text(subtitle)
                            .vdFont(VdFont.bodySmall)
                            .foregroundStyle(Color.vdContentDefaultSecondary)
                    }
                }

                content
            }
        }
    }
}

#Preview {
    ProfileSectionView(title: "Identity", subtitle: "Upload front and back") {
        Text("Section content")
            .vdFont(VdFont.bodyLarge)
            .foregroundStyle(Color.vdContentDefaultBase)
    }
    .padding()
}
