import SwiftUI
import VroxalDesign

struct ContentView: View {
    public var body: some View {
        
        AppRootView()
            .baseraScreenBackground()

    }

//        NavigationStack {
//            VStack(alignment: .leading, spacing: VdSpacing.lg) {
//                Text("Vroxal Preview")
//                    .vdFont(.headlineSmall)
//                    .foregroundStyle(Color.vdContentDefaultBase)
//
//                Text("Choose where to start")
//                    .vdFont(.bodyMedium)
//                    .foregroundStyle(Color.vdContentDefaultSecondary)
//
//                NavigationLink {
//                    AppRootView()
//                } label: {
//                    navTile(
//                        title: "App Root",
//                        subtitle: "Component usage in an app-like screen"
//                    )
//                }
//                .buttonStyle(.plain)
//
//                NavigationLink {
//                    VdPreviewGallery()
//                } label: {
//                    navTile(
//                        title: "Preview Gallery",
//                        subtitle:
//                            "All vd-swift components, colors, spacing, and typography"
//                    )
//                }
//                .buttonStyle(.plain)
//
//                Spacer(minLength: 0)
//            }
//            .padding(VdSpacing.lg)
//            .background(Color.vdBackgroundDefaultBase)
//        }
//    }
//
//    private func navTile(title: String, subtitle: String) -> some View {
//        VStack(alignment: .leading, spacing: VdSpacing.xs) {
//            Text(title)
//                .vdFont(.labelLarge)
//                .foregroundStyle(Color.vdContentDefaultBase)
//
//            Text(subtitle)
//                .vdFont(.bodySmall)
//                .foregroundStyle(Color.vdContentDefaultSecondary)
//                .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .padding(VdSpacing.md)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color.vdBackgroundDefaultSecondary)
//        .clipShape(
//            RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
//        )
//        .overlay {
//            RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
//                .strokeBorder(
//                    Color.vdBorderDefaultTertiary,
//                    lineWidth: VdBorderWidth.sm
//                )
//        }
//    }
}

#Preview {
    ContentView()
        .environmentObject(AppEnvironment.bootstrap())
}
