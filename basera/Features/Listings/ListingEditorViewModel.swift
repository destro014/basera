import Combine
import Foundation

@MainActor
final class ListingEditorViewModel: ObservableObject {
    enum Step: Int, CaseIterable, Identifiable {
        case basics
        case media
        case pricing
        case amenities
        case rules
        case preview

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .basics: "Basics"
            case .media: "Media"
            case .pricing: "Pricing"
            case .amenities: "Amenities"
            case .rules: "Rules"
            case .preview: "Preview"
            }
        }
    }

    let ownerID: String
    let editingListingID: String?

    @Published var step: Step = .basics
    @Published var form = ListingFormDraft()

    init(ownerID: String, listing: Listing? = nil) {
        self.ownerID = ownerID
        self.editingListingID = listing?.id
        if let listing {
            hydrate(with: listing)
        }
    }

    var isEditing: Bool { editingListingID != nil }

    func goNext() {
        guard let next = Step(rawValue: step.rawValue + 1) else { return }
        step = next
    }

    func goBack() {
        guard let previous = Step(rawValue: step.rawValue - 1) else { return }
        step = previous
    }

    func markMediaReady(_ mediaID: String) {
        guard let index = form.media.firstIndex(where: { $0.id == mediaID }) else { return }
        form.media[index].uploadState = .ready
    }

    func buildListing(status: Listing.Status) -> Listing {
        Listing(
            id: editingListingID ?? "OL-\(Int.random(in: 300...999))",
            ownerID: ownerID,
            title: form.title,
            description: form.description,
            approximateLocation: form.approximateLocation,
            exactAddress: form.exactAddress,
            exactAddressMasked: "Exact address shared only after owner approval",
            monthlyRent: form.monthlyRent,
            securityDeposit: form.securityDeposit,
            bedroomCount: form.rooms,
            floor: form.floor,
            propertyType: form.propertyType,
            listingScope: form.listingScope,
            furnishing: form.furnishing,
            parkingAvailable: form.hasParking,
            wifiAvailable: form.hasWifi,
            petAllowed: form.petAllowed,
            tenantPreference: form.preferredTenantType,
            locationRadiusInKM: 5,
            availableFrom: form.availableDate,
            minimumStayMonths: form.minimumStayMonths,
            utilities: .init(
                electricityIncluded: form.includesElectricity,
                waterIncluded: form.includesWater,
                internetIncluded: form.includesInternet
            ),
            smokingAllowed: form.smokingAllowed,
            visitorsAllowed: form.visitorsAllowed,
            quietHours: form.quietHours,
            latitude: form.latitude,
            longitude: form.longitude,
            media: form.media.map {
                Listing.MediaItem(
                    id: $0.id,
                    kind: $0.kind,
                    title: $0.title,
                    subtitle: $0.subtitle,
                    systemImageName: $0.kind == .image ? "photo.fill" : "video.fill"
                )
            },
            status: status,
            similarListingIDs: []
        )
    }

    private func hydrate(with listing: Listing) {
        form = ListingFormDraft(
            title: listing.title,
            description: listing.description,
            propertyType: listing.propertyType,
            listingScope: listing.listingScope,
            exactAddress: listing.location.exactAddress,
            approximateLocation: listing.approximateLocation,
            latitude: listing.location.latitude,
            longitude: listing.location.longitude,
            rooms: listing.roomCount,
            floor: listing.floor,
            furnishing: listing.furnishing,
            preferredTenantType: listing.tenantPreference,
            availableDate: listing.availableFrom,
            minimumStayMonths: listing.minimumStayMonths,
            monthlyRent: listing.monthlyRent,
            securityDeposit: listing.pricing.securityDeposit,
            includesElectricity: listing.utilities.electricityIncluded,
            includesWater: listing.utilities.waterIncluded,
            includesInternet: listing.utilities.internetIncluded,
            hasParking: listing.parkingAvailable,
            hasWifi: listing.wifiAvailable,
            petAllowed: listing.petAllowed,
            smokingAllowed: listing.rules.smokingAllowed,
            visitorsAllowed: listing.rules.visitorsAllowed,
            quietHours: listing.rules.quietHours,
            media: listing.media.map {
                .init(id: $0.id, kind: $0.kind, title: $0.title, uploadState: .ready)
            }
        )
    }
}
