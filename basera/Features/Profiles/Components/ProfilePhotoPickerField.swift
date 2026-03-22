import SwiftUI
import VroxalDesign

struct ProfilePhotoPickerField: View {
    @Binding var photoURL: URL?

    var body: some View {
        ProfileSectionView(title: "Profile Photo") {
            HStack(spacing: VdSpacing.smMd) {
                BaseraAvatar(initials: photoURL == nil ? "--" : "OK")
                VStack(alignment: .leading, spacing: VdSpacing.xs) {
                    Text(photoURL == nil ? "No photo uploaded" : "Photo attached")
                        .vdFont(VdFont.bodyLarge)
                    Text("Mock upload for development previews")
                        .vdFont(VdFont.bodySmall)
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                }

                Spacer()
            }

            VdButton(title: photoURL == nil ? "Upload Photo" : "Remove Photo", style: .secondary) {
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
