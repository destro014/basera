import SwiftUI
import VroxalDesign

struct DepositSummaryCard: View {
    let deposit: TenancyRecord.DepositSummary

    var body: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: VdSpacing.sm) {
                Text("Deposit Summary")
                    .vdFont(VdFont.titleMedium)
                Text("Held: Rs. \(NSDecimalNumber(decimal: deposit.heldAmount).intValue)")
                    .vdFont(VdFont.bodyLarge)
                Text("Total deposit: Rs. \(NSDecimalNumber(decimal: deposit.totalDeposit).intValue)")
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary)
                if let plannedRefundAmount = deposit.plannedRefundAmount {
                    Text("Planned refund: Rs. \(NSDecimalNumber(decimal: plannedRefundAmount).intValue)")
                        .vdFont(VdFont.bodySmall)
                }
                if let deductionNotes = deposit.deductionNotes {
                    VdAlert(tone: .info, message: deductionNotes)
                }
            }
        }
    }
}

#Preview {
    DepositSummaryCard(deposit: PreviewData.mockTenancies[2].depositSummary)
}
