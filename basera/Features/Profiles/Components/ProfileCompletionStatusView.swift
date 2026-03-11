import SwiftUI

struct ProfileCompletionStatusView: View {
    let status: ProfileCompletionStatus

    var body: some View {
        ProfileSectionView(title: "\(status.role.title) Profile Completion") {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                ProgressView(value: status.progressValue)
                    .tint(status.isComplete ? AppTheme.Colors.success : AppTheme.Colors.warning)

                Text(status.summaryText)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                if status.missingFields.isEmpty == false {
                    Text("Missing: \(status.missingFields.joined(separator: ", "))")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.warning)
                }
            }
        }
    }
}

#Preview {
    VStack {
        ProfileCompletionStatusView(
            status: UserProfileBundle(renterProfile: nil, ownerProfile: PreviewData.ownerProfile).completionStatus(for: .owner)
        )
    }
    .padding()
}
