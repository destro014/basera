import SwiftUI
import VroxalDesign

struct ProfileCompletionStatusView: View {
    let status: ProfileCompletionStatus

    var body: some View {
        ProfileSectionView(title: "\(status.role.title) Profile Completion") {
            VStack(alignment: .leading, spacing: VdSpacing.sm) {
                ProgressView(value: status.progressValue)
                    .tint(status.isComplete ? Color.vdContentSuccessBase : Color.vdContentWarningBase)

                Text(status.summaryText)
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary)

                if status.missingFields.isEmpty == false {
                    Text("Missing: \(status.missingFields.joined(separator: ", "))")
                        .vdFont(VdFont.bodySmall)
                        .foregroundStyle(Color.vdContentWarningBase)
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
