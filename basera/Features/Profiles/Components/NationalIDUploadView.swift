import SwiftUI

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
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text(isUploaded ? "Uploaded" : "Tap to upload")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: isUploaded ? "checkmark.circle.fill" : "arrow.up.circle")
                    .foregroundStyle(isUploaded ? AppTheme.Colors.success : AppTheme.Colors.brandPrimary)
            }
            .padding(AppTheme.Spacing.medium)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                    .stroke(AppTheme.Colors.borderLight, lineWidth: 1)
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
