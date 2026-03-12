import Combine
import Foundation

@MainActor
final class InterestSubmissionViewModel: ObservableObject {
    enum SubmissionState: Equatable {
        case idle
        case submitting
        case submitted
        case error(String)
    }

    @Published var optionalMessage = ""
    @Published private(set) var state: SubmissionState = .idle

    let listing: Listing
    let renterSnapshot: RenterProfileSnapshot
    let renterID: String

    init(listing: Listing, renterID: String, renterSnapshot: RenterProfileSnapshot) {
        self.listing = listing
        self.renterID = renterID
        self.renterSnapshot = renterSnapshot
    }

    func submit(using repository: InterestsRepositoryProtocol) async {
        state = .submitting
        do {
            _ = try await repository.submitInterest(
                InterestSubmissionDraft(
                    listingID: listing.id,
                    ownerID: listing.ownerID,
                    renterID: renterID,
                    renterSnapshot: renterSnapshot,
                    optionalMessage: optionalMessage
                )
            )
            state = .submitted
        } catch {
            state = .error("Unable to submit interest right now.")
        }
    }
}
