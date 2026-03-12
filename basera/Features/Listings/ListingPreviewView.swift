import SwiftUI

struct ListingPreviewView: View {
    let listing: Listing

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                BaseraBadge(text: listing.status.label, tone: statusTone)
                Text(listing.title)
                    .baseraTextStyle(AppTheme.Typography.titleLarge)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text(listing.description)
                    .baseraTextStyle(AppTheme.Typography.bodyMedium)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text("Approximate location: \(listing.approximateLocation)")
                Text("Exact address: Hidden until owner approval")
                Text("Type: \(listing.propertyType.rawValue) • \(listing.listingScope.rawValue)")
                Text("Pricing: NPR \(listing.monthlyRent)/month")
                Text("Minimum stay: \(listing.minimumStayMonths) months")
            }
            .baseraTextStyle(AppTheme.Typography.bodyMedium)
            .padding()
        }
        .navigationTitle("Listing Preview")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statusTone: Color {
        switch listing.status {
        case .active, .occupied: AppTheme.Colors.successPrimary
        case .draft, .agreementPending: AppTheme.Colors.warningPrimary
        case .paused: AppTheme.Colors.infoPrimary
        case .assigned: AppTheme.Colors.brandPrimary
        }
    }
}

#Preview {
    NavigationView {
        ListingPreviewView(listing: PreviewData.ownerListings[0])
    }
}
