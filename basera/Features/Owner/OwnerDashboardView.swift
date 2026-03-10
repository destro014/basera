import SwiftUI

struct OwnerDashboardView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: AppTheme.Spacing.large) {
                BaseraCard {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Owner Command Center")
                            .font(AppTheme.Typography.subtitle)
                        Text("Manage listings, approvals, agreements, and monthly Basera invoices.")
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }

                BaseraEmptyStateView(
                    title: "No active tenants",
                    message: "Assigned renters and move-out actions will appear here."
                )
            }
            .padding()
            .navigationTitle("Basera Owner")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    OwnerDashboardView()
}
