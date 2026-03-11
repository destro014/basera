import SwiftUI

struct OwnerDashboardView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.large) {
                BasraCard {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Owner Command Center")
                            .font(AppTheme.Typography.subtitle)
                        Text("Manage listings, approvals, agreements, and monthly Basra invoices.")
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }

                BasraEmptyStateView(
                    title: "No active tenants",
                    message: "Assigned renters and move-out actions will appear here."
                )
            }
            .padding()
            .navigationTitle("Basra Owner")
        }
    }
}

#Preview {
    OwnerDashboardView()
}
