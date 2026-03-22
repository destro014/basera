import SwiftUI
import VroxalDesign

struct ListingPreviewView: View {
    let listing: Listing

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VdSpacing.smMd) {
                VdBadge(listing.status.label, color: statusTone, style: .subtle)
                Text(listing.title)
                    .vdFont(VdFont.titleLarge)
                    .foregroundStyle(Color.vdContentDefaultBase)
                Text(listing.description)
                    .vdFont(VdFont.bodyMedium)
                    .foregroundStyle(Color.vdContentDefaultSecondary)
                Text("Approximate location: \(listing.approximateLocation)")
                Text("Exact address: Hidden until owner approval")
                Text("Type: \(listing.propertyType.rawValue) • \(listing.listingScope.rawValue)")
                Text("Pricing: NPR \(listing.monthlyRent)/month")
                Text("Minimum stay: \(listing.minimumStayMonths) months")
            }
            .vdFont(VdFont.bodyMedium)
            .padding()
        }
        .navigationTitle("Listing Preview")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statusTone: VdBadgeColor {
        switch listing.status {
        case .active, .occupied: .success
        case .draft, .agreementPending: .warning
        case .paused: .info
        case .assigned: .primary
        }
    }
}

#Preview {
    NavigationView {
        ListingPreviewView(listing: PreviewData.ownerListings[0])
    }
}
