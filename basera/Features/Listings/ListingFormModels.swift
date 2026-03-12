import Foundation

struct ListingFormDraft: Equatable {
    struct MediaDraft: Identifiable, Equatable {
        enum UploadState: String {
            case placeholder
            case ready
        }

        let id: String
        let kind: Listing.MediaItem.Kind
        var title: String
        var uploadState: UploadState

        var subtitle: String {
            switch uploadState {
            case .placeholder: "Upload pending"
            case .ready: "Ready"
            }
        }
    }

    var title = ""
    var description = ""
    var propertyType: Listing.PropertyType = .room
    var listingScope: Listing.ListingScope = .fullProperty
    var exactAddress = ""
    var approximateLocation = ""
    var latitude = 27.7172
    var longitude = 85.3240
    var rooms = 1
    var floor = 1
    var furnishing: Listing.Furnishing = .furnished
    var preferredTenantType: Listing.TenantPreference = .both
    var availableDate = Date()
    var minimumStayMonths = 6

    var monthlyRent = 12_000
    var securityDeposit = 12_000
    var includesElectricity = false
    var includesWater = true
    var includesInternet = true

    var hasParking = false
    var hasWifi = true
    var petAllowed = false

    var smokingAllowed = false
    var visitorsAllowed = true
    var quietHours = "10 PM - 6 AM"

    var media: [MediaDraft] = [
        .init(id: "photo-slot", kind: .image, title: "Add photos", uploadState: .placeholder),
        .init(id: "video-slot", kind: .videoPreview, title: "Add videos", uploadState: .placeholder)
    ]

    var canPublish: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !approximateLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !exactAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
