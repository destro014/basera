import SwiftUI
import VroxalDesign

struct NationalIDUploadView: View {
    @Binding var uploadState: DocumentUploadState

    var body: some View {
        ProfileSectionView(title: "National ID Upload") {
            uploadButton(
                title: "Front side",
                isUploaded: uploadState.frontUploaded,
                action: { uploadState.frontUploaded.toggle() }
            )

            uploadButton(
                title: "Back side",
                isUploaded: uploadState.backUploaded,
                action: { uploadState.backUploaded.toggle() }
            )
        }
    }

    private func uploadButton(title: String, isUploaded: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .vdFont(VdFont.bodyLarge)
                        .foregroundStyle(Color.vdContentDefaultBase)
                    Text(isUploaded ? "Uploaded" : "Tap to upload")
                        .vdFont(VdFont.bodySmall)
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                }

                Spacer()

                Image(systemName: isUploaded ? "checkmark.circle.fill" : "arrow.up.circle")
                    .foregroundStyle(isUploaded ? Color.vdContentSuccessBase : Color.vdBackgroundPrimaryBase)
            }
            .padding(VdSpacing.smMd)
            .background(Color.vdBackgroundDefaultSecondary)
            .clipShape(RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                    .stroke(Color.vdBorderDefaultSecondary, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StatefulPreviewContainer(DocumentUploadState.empty) { state in
        NationalIDUploadView(uploadState: state)
            .padding()
    }
}
