import SwiftUI

struct OwnerDashboardView: View {
    let ownerID: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            BaseraCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    Text("Owner Command Center")
                        .baseraTextStyle(AppTheme.Typography.titleLarge)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text("Create, edit, pause, and duplicate listings while keeping exact address private until approval.")
                        .baseraTextStyle(AppTheme.Typography.bodyLarge)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            .padding(.horizontal)

            BaseraCard {
                HStack {
                    NavigationLink("Interested Renters") {
                        OwnerInterestedRentersView(listingID: "OL-200", ownerID: ownerID)
                    }
                    NavigationLink("Owner Conversations") {
                        ConversationListView(userID: ownerID)
                    }
                }
                .baseraTextStyle(AppTheme.Typography.bodyMedium)
            }
            .padding(.horizontal)

            MyListingsView(ownerID: ownerID)
        }
    }
}

#Preview {
    OwnerDashboardView(ownerID: "preview-user-001")
        .environmentObject(AppEnvironment.bootstrap())
}
