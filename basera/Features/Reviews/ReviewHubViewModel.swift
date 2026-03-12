import Foundation

@MainActor
final class ReviewHubViewModel: ObservableObject {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    @Published private(set) var state: LoadState = .idle
    @Published private(set) var submissionContexts: [ReviewCounterpartyContext] = []
    @Published private(set) var receivedReviews: [ReviewRecord] = []
    @Published private(set) var ratingSummary: ReviewRatingSummary = .empty
    @Published var selectedContextID: String?
    @Published var selectedRating: Int = 5
    @Published var reviewComment: String = ""
    @Published var reportReason: ReviewReportReason = .abusiveLanguage
    @Published var reportNote: String = ""
    @Published private(set) var bannerMessage: String?

    let userID: String
    let role: UserRole

    init(userID: String, role: UserRole) {
        self.userID = userID
        self.role = role
    }

    var selectedContext: ReviewCounterpartyContext? {
        submissionContexts.first(where: { $0.id == selectedContextID })
    }

    func load(using repository: ReviewsRepositoryProtocol) async {
        state = .loading
        do {
            async let contextsTask = repository.fetchReviewContext(for: userID, role: role)
            async let reviewsTask = repository.fetchPublicReviews(for: userID)
            async let summaryTask = repository.fetchRatingSummary(for: userID)

            submissionContexts = try await contextsTask
            receivedReviews = try await reviewsTask
            ratingSummary = try await summaryTask
            selectedContextID = submissionContexts.first(where: { $0.canSubmit && $0.existingReview == nil })?.id
            state = .loaded
        } catch {
            state = .error("Unable to load reviews right now.")
        }
    }

    func submit(using repository: ReviewsRepositoryProtocol) async {
        guard let context = selectedContext, context.canSubmit, context.existingReview == nil else {
            bannerMessage = "This review stage is not available for submission."
            return
        }

        do {
            _ = try await repository.submitReview(
                ReviewSubmissionDraft(
                    tenancyID: context.tenancyID,
                    stage: context.stage,
                    reviewerID: userID,
                    reviewerName: "Current User",
                    reviewerRole: context.reviewerRole,
                    revieweeID: context.revieweeID,
                    revieweeName: context.revieweeName,
                    rating: selectedRating,
                    comment: reviewComment.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            )

            bannerMessage = "Review submitted. It is now public."
            reviewComment = ""
            await load(using: repository)
        } catch {
            bannerMessage = error.localizedDescription
        }
    }

    func report(reviewID: String, using repository: ReviewsRepositoryProtocol) async {
        do {
            try await repository.reportReview(reviewID: reviewID, reporterID: userID, reason: reportReason, note: reportNote)
            bannerMessage = "Review reported. Our moderation team will review it."
            reportNote = ""
        } catch {
            bannerMessage = error.localizedDescription
        }
    }
}
