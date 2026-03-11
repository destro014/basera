import SwiftUI

struct ProfilePhotoPickerField: View {
    @Binding var photoURL: URL?

    var body: some View {
        ProfileSectionView(title: "Profile Photo") {
            HStack(spacing: AppTheme.Spacing.medium) {
                BaseraAvatar(initials: photoURL == nil ? "--" : "OK")
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                    Text(photoURL == nil ? "No photo uploaded" : "Photo attached")
                        .font(AppTheme.Typography.body)
                    Text("Mock upload for development previews")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }

                Spacer()
            }

            BaseraButton(title: photoURL == nil ? "Upload Photo" : "Remove Photo", style: .secondary) {
                if photoURL == nil {
                    photoURL = URL(string: "https://example.com/mock/profile.jpg")
                } else {
                    photoURL = nil
                }
            }
        }
    }
}

#Preview {
    StatefulPreviewContainer(URL?.none) { url in
        ProfilePhotoPickerField(photoURL: url)
            .padding()
    }
}
