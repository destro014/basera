import SwiftUI
import UniformTypeIdentifiers

struct AuthProfilePhotoView: View {
    let hasSelectedPhoto: Bool
    let isLoading: Bool
    let onPhotoSelected: (Data) -> Void
    let onPhotoSelectionFailure: () -> Void
    let onComplete: () -> Void
    let onSkip: () -> Void

    @State private var isPresentingFileImporter = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            VStack(alignment: .center, spacing: AppTheme.Spacing.medium) {
                ZStack {
                    Circle()
                        .fill(hasSelectedPhoto ? AppTheme.Colors.brandTertiary : AppTheme.Colors.backgroundPrimary)
                        .frame(width: 120, height: 120)

                    Image(systemName: hasSelectedPhoto ? "checkmark.circle.fill" : "camera.fill")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(hasSelectedPhoto ? AppTheme.Colors.brandPrimary : AppTheme.Colors.brandPrimary)
                }

                Text(hasSelectedPhoto ? "Photo selected and ready to upload." : "No profile photo selected yet.")
                    .baseraTextStyle(AppTheme.Typography.titleMedium)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Text("Your photo will show in chat, agreement history, and profile screens. You can update it later.")
                    .baseraTextStyle(AppTheme.Typography.bodyLarge)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.large)
            .background(AppTheme.Colors.surfacePrimary)
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous)
                    .stroke(AppTheme.Colors.borderSecondary, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))

            BaseraButton(
                title: hasSelectedPhoto ? "Choose another photo" : "Choose a photo",
                style: .secondary
            ) {
                isPresentingFileImporter = true
            }

            VStack(spacing: AppTheme.Spacing.medium) {
                BaseraButton(
                    title: "Finish onboarding",
                    style: .primary,
                    isLoading: isLoading,
                    action: onComplete
                )

                if hasSelectedPhoto {
                    BaseraButton(
                        title: "Skip this photo for now",
                        style: .secondary,
                        isDisabled: isLoading,
                        action: onSkip
                    )
                }
            }
        }
        .fileImporter(isPresented: $isPresentingFileImporter, allowedContentTypes: [.image]) { result in
            do {
                let url = try result.get()
                let isSecurityScoped = url.startAccessingSecurityScopedResource()
                defer {
                    if isSecurityScoped {
                        url.stopAccessingSecurityScopedResource()
                    }
                }

                let data = try Data(contentsOf: url)
                onPhotoSelected(data)
            } catch {
                onPhotoSelectionFailure()
            }
        }
    }
}

#Preview("Empty") {
    AuthProfilePhotoView(
        hasSelectedPhoto: false,
        isLoading: false,
        onPhotoSelected: { _ in },
        onPhotoSelectionFailure: {},
        onComplete: {},
        onSkip: {}
    )
    .padding()
}

#Preview("Selected") {
    AuthProfilePhotoView(
        hasSelectedPhoto: true,
        isLoading: false,
        onPhotoSelected: { _ in },
        onPhotoSelectionFailure: {},
        onComplete: {},
        onSkip: {}
    )
    .padding()
}

#Preview("Loading") {
    AuthProfilePhotoView(
        hasSelectedPhoto: true,
        isLoading: true,
        onPhotoSelected: { _ in },
        onPhotoSelectionFailure: {},
        onComplete: {},
        onSkip: {}
    )
    .padding()
}
