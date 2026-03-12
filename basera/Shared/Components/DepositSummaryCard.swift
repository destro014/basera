import SwiftUI

struct DepositSummaryCard: View {
    let deposit: TenancyRecord.DepositSummary

    var body: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text("Deposit Summary")
                    .baseraTextStyle(AppTheme.Typography.titleMedium)
                Text("Held: Rs. \(NSDecimalNumber(decimal: deposit.heldAmount).intValue)")
                    .baseraTextStyle(AppTheme.Typography.bodyLarge)
                Text("Total deposit: Rs. \(NSDecimalNumber(decimal: deposit.totalDeposit).intValue)")
                    .baseraTextStyle(AppTheme.Typography.bodySmall)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                if let plannedRefundAmount = deposit.plannedRefundAmount {
                    Text("Planned refund: Rs. \(NSDecimalNumber(decimal: plannedRefundAmount).intValue)")
                        .baseraTextStyle(AppTheme.Typography.bodySmall)
                }
                if let deductionNotes = deposit.deductionNotes {
                    BaseraInlineMessageView(tone: .info, message: deductionNotes)
                }
            }
        }
    }
}

#Preview {
    DepositSummaryCard(deposit: PreviewData.mockTenancies[2].depositSummary)
}
