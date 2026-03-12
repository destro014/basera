import Foundation

protocol ReviewsRepositoryProtocol: Sendable {
    func fetchReviewContext(for userID: String, role: UserRole) async throws -> [ReviewCounterpartyContext]
    func submitReview(_ draft: ReviewSubmissionDraft) async throws -> ReviewRecord
    func fetchPublicReviews(for userID: String) async throws -> [ReviewRecord]
    func fetchRatingSummary(for userID: String) async throws -> ReviewRatingSummary
    func reportReview(reviewID: String, reporterID: String, reason: ReviewReportReason, note: String) async throws
    func fetchReports(for reviewID: String) async throws -> [ReviewReportRecord]
}
