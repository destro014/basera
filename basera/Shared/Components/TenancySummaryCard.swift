import SwiftUI

struct TenancySummaryCard: View {
    let tenancy: TenancyRecord
    let party: AgreementRecord.Party

    var body: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                HStack {
                    Text(tenancy.listingTitle)
                        .baseraTextStyle(AppTheme.Typography.titleMedium)
                    Spacer()
                    BaseraBadge(text: tenancy.status.title, tone: AppTheme.Colors.infoPrimary)
                }
                Text(tenancy.approximateLocation)
                    .baseraTextStyle(AppTheme.Typography.bodySmall)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text(tenancy.address(for: party))
                    .baseraTextStyle(AppTheme.Typography.bodySmall)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                HStack {
                    BaseraChip(text: "Rent Rs. \(NSDecimalNumber(decimal: tenancy.monthlyRent).intValue)/month")
                    BaseraChip(text: "Due Rs. \(NSDecimalNumber(decimal: tenancy.billSummary.amountDue).intValue)")
                }
            }
        }
    }
}

#Preview {
    TenancySummaryCard(tenancy: PreviewData.mockTenancies[0], party: .renter)
}
