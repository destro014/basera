import SwiftUI
import VroxalDesign

struct BaseraActionTile: View {
    let title: String
    let subtitle: String?
    let systemImage: String

    var body: some View {
        HStack(alignment: .center, spacing: VdSpacing.smMd) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.vdContentPrimaryBase)
                .frame(width: 36, height: 36)
                .background(Color.vdBackgroundPrimarySecondary)
                .clipShape(RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous))

            VStack(alignment: .leading, spacing: VdSpacing.xs) {
                Text(title)
                    .vdFont(VdFont.labelLarge)
                    .foregroundStyle(Color.vdContentDefaultBase)

                if let subtitle, subtitle.isEmpty == false {
                    Text(subtitle)
                        .vdFont(VdFont.bodySmall)
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.vdContentDefaultSecondary)
        }
        .padding(VdSpacing.smMd)
        .background(Color.vdBackgroundDefaultSecondary)
        .overlay {
            RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                .stroke(Color.vdBorderDefaultSecondary, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous))
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
