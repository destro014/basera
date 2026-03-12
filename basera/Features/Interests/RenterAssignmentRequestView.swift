import SwiftUI

struct RenterAssignmentRequestView: View {
    let assignment: ListingAssignment
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            BaseraCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    Text("Assignment Request")
                        .baseraTextStyle(AppTheme.Typography.titleLarge)
                    Text("Listing \(assignment.listingID)")
                        .baseraTextStyle(AppTheme.Typography.bodyMedium)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    Text(assignment.note)
                        .baseraTextStyle(AppTheme.Typography.bodyLarge)
                }
            }

            BaseraInlineMessageView(
                tone: .info,
                message: "Accept assignment to unlock agreement creation. Listing remains public until agreement signing is complete."
            )

            HStack(spacing: AppTheme.Spacing.medium) {
                BaseraButton(title: "Decline", style: .secondary, action: onDecline)
                BaseraButton(title: "Accept", style: .primary, action: onAccept)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Assignment")
    }
}

#Preview {
    NavigationView {
        RenterAssignmentRequestView(
            assignment: .init(
                id: "ASN-100",
                listingID: "L-100",
                ownerID: "owner-xyz",
                renterID: "preview-user-001",
                interestID: "INT-100",
                requestedAt: .now,
                status: .requested,
                note: "Please confirm in 24 hours."
            ),
            onAccept: {},
            onDecline: {}
        )
    }
}
