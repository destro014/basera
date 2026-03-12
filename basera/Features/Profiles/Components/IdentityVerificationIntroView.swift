import SwiftUI

struct IdentityVerificationIntroView: View {
    var body: some View {
        ProfileSectionView(
            title: "Identity Verification",
            subtitle: "Your ID is used to unlock agreement signing and secure payment tracking."
        ) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Label("Upload front and back of your national ID", systemImage: "checkmark.seal")
                Label("Documents stay private and support trust between renter and owner", systemImage: "lock.shield")
                Label("Verification can be updated before agreements are signed", systemImage: "doc.text.magnifyingglass")
            }
            .baseraTextStyle(AppTheme.Typography.bodySmall)
            .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }
}

#Preview {
    IdentityVerificationIntroView()
        .padding()
}
