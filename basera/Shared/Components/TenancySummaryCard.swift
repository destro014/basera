import SwiftUI
import VroxalDesign

struct TenancySummaryCard: View {
    let tenancy: TenancyRecord
    let party: AgreementRecord.Party

    var body: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: VdSpacing.sm) {
                HStack {
                    Text(tenancy.listingTitle)
                        .vdFont(VdFont.titleMedium)
                    Spacer()
                    VdBadge(tenancy.status.title, color: .info, style: .subtle)
                }
                Text(tenancy.approximateLocation)
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary)
                Text(tenancy.address(for: party))
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary)
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
