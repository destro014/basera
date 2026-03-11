import SwiftUI

struct ProfileSectionView<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                    Text(title)
                        .font(AppTheme.Typography.subtitle)
                    if let subtitle {
                        Text(subtitle)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
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
    }
    .padding()
}
