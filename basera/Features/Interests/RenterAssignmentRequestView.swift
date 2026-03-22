import SwiftUI
import VroxalDesign

struct RenterAssignmentRequestView: View {
    let assignment: ListingAssignment
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(spacing: VdSpacing.md) {
            BaseraCard {
                VStack(alignment: .leading, spacing: VdSpacing.sm) {
                    Text("Assignment Request")
                        .vdFont(VdFont.titleLarge)
                    Text("Listing \(assignment.listingID)")
                        .vdFont(VdFont.bodyMedium)
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                    Text(assignment.note)
                        .vdFont(VdFont.bodyLarge)
                }
            }

            VdAlert(
                tone: .info,
                message: "Accept assignment to unlock agreement creation. Listing remains public until agreement signing is complete."
            )

            HStack(spacing: VdSpacing.smMd) {
                VdButton(title: "Decline", style: .secondary, action: onDecline)
                VdButton(title: "Accept", style: .primary, action: onAccept)
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
