import Foundation

actor MockReviewsRepository: ReviewsRepositoryProtocol {
    private let tenancies: [TenancyRecord]
    private var reviews: [ReviewRecord]
    private var reports: [ReviewReportRecord]

    init(
        tenancies: [TenancyRecord] = PreviewData.mockTenancies,
        reviews: [ReviewRecord] = PreviewData.mockReviews,
        reports: [ReviewReportRecord] = PreviewData.mockReviewReports
    ) {
        self.tenancies = tenancies
        self.reviews = reviews
        self.reports = reports
    }

    func fetchReviewContext(for userID: String, role: UserRole) async throws -> [ReviewCounterpartyContext] {
        let candidateTenancies = tenancies.filter { tenancy in
            switch role {
            case .renter: tenancy.renterID == userID
            case .owner: tenancy.ownerID == userID
            }
        }

        var contexts: [ReviewCounterpartyContext] = []
        for tenancy in candidateTenancies {
            contexts.append(context(for: tenancy, stage: .duringStay, userID: userID, role: role))
            contexts.append(context(for: tenancy, stage: .postMoveOut, userID: userID, role: role))
        }

        return contexts.sorted { lhs, rhs in
            if lhs.tenancyID == rhs.tenancyID {
                return lhs.stage == .duringStay && rhs.stage == .postMoveOut
            }
            return lhs.tenancyID < rhs.tenancyID
        }
    }

    func submitReview(_ draft: ReviewSubmissionDraft) async throws -> ReviewRecord {
        guard draft.stage == .duringStay || isTenancyArchived(draft.tenancyID) else {
            throw ReviewRepositoryError.invalidStage
        }

        let exists = reviews.contains {
            $0.tenancyID == draft.tenancyID &&
                $0.stage == draft.stage &&
                $0.reviewerID == draft.reviewerID
        }

        guard !exists else {
            throw ReviewRepositoryError.duplicateSubmission
        }

        let review = ReviewRecord(
            id: "REV-\(UUID().uuidString.prefix(8))",
            tenancyID: draft.tenancyID,
            stage: draft.stage,
            reviewerID: draft.reviewerID,
            reviewerName: draft.reviewerName,
            reviewerRole: draft.reviewerRole,
            revieweeID: draft.revieweeID,
            revieweeName: draft.revieweeName,
            rating: min(max(draft.rating, 1), 5),
            comment: draft.comment,
            createdAt: .now
        )

        reviews.insert(review, at: 0)
        return review
    }

    func fetchPublicReviews(for userID: String) async throws -> [ReviewRecord] {
        reviews
            .filter { $0.revieweeID == userID }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func fetchRatingSummary(for userID: String) async throws -> ReviewRatingSummary {
        let publicReviews = reviews.filter { $0.revieweeID == userID }
        guard !publicReviews.isEmpty else { return .empty }

        let totalRating = publicReviews.reduce(0) { $0 + $1.rating }
        return ReviewRatingSummary(
            averageRating: Double(totalRating) / Double(publicReviews.count),
            reviewCount: publicReviews.count
        )
    }

    func reportReview(reviewID: String, reporterID: String, reason: ReviewReportReason, note: String) async throws {
        let alreadyExists = reports.contains { $0.reviewID == reviewID && $0.reporterID == reporterID }
        guard !alreadyExists else { throw ReviewRepositoryError.alreadyReported }

        reports.append(
            ReviewReportRecord(
                id: "RPT-\(UUID().uuidString.prefix(8))",
                reviewID: reviewID,
                reporterID: reporterID,
                reason: reason,
                note: note,
                createdAt: .now
            )
        )
    }

    func fetchReports(for reviewID: String) async throws -> [ReviewReportRecord] {
        reports.filter { $0.reviewID == reviewID }
    }

    private func context(for tenancy: TenancyRecord, stage: ReviewStage, userID: String, role: UserRole) -> ReviewCounterpartyContext {
        let canSubmit: Bool
        if stage == .postMoveOut {
            canSubmit = tenancy.status == .archived
        } else {
            canSubmit = tenancy.status == .active || tenancy.status == .moveOutRequested || tenancy.status == .archived
        }

        let revieweeID = role == .renter ? tenancy.ownerID : tenancy.renterID
        let revieweeName = role == .renter ? tenancy.ownerContact.fullName : tenancy.renterContact.fullName

        let existingReview = reviews.first {
            $0.tenancyID == tenancy.id &&
                $0.stage == stage &&
                $0.reviewerID == userID
        }

        return ReviewCounterpartyContext(
            id: "\(tenancy.id)-\(stage.rawValue)",
            tenancyID: tenancy.id,
            stage: stage,
            revieweeID: revieweeID,
            revieweeName: revieweeName,
            reviewerRole: role == .renter ? .renter : .owner,
            canSubmit: canSubmit,
            existingReview: existingReview
        )
    }

    private func isTenancyArchived(_ tenancyID: String) -> Bool {
        tenancies.first(where: { $0.id == tenancyID })?.status == .archived
    }
}
