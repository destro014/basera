import Foundation

enum ReviewStage: String, CaseIterable, Identifiable, Codable {
    case duringStay
    case postMoveOut

    var id: String { rawValue }

    var title: String {
        switch self {
        case .duringStay: "During stay"
        case .postMoveOut: "After move-out"
        }
    }
}

enum ReviewParticipantRole: String, Codable {
    case renter
    case owner
}

struct ReviewRecord: Identifiable, Equatable {
    let id: String
    let tenancyID: String
    let stage: ReviewStage
    let reviewerID: String
    let reviewerName: String
    let reviewerRole: ReviewParticipantRole
    let revieweeID: String
    let revieweeName: String
    let rating: Int
    let comment: String
    let createdAt: Date

    var ratingLabel: String { "\(rating)/5" }
}

struct ReviewSubmissionDraft {
    let tenancyID: String
    let stage: ReviewStage
    let reviewerID: String
    let reviewerName: String
    let reviewerRole: ReviewParticipantRole
    let revieweeID: String
    let revieweeName: String
    let rating: Int
    let comment: String
}

struct ReviewCounterpartyContext: Identifiable, Equatable {
    let id: String
    let tenancyID: String
    let stage: ReviewStage
    let revieweeID: String
    let revieweeName: String
    let reviewerRole: ReviewParticipantRole
    let canSubmit: Bool
    let existingReview: ReviewRecord?
}

struct ReviewRatingSummary: Equatable {
    let averageRating: Double
    let reviewCount: Int

    static let empty = ReviewRatingSummary(averageRating: 0, reviewCount: 0)
}

enum ReviewReportReason: String, CaseIterable, Identifiable, Codable {
    case abusiveLanguage
    case harassment
    case falseInformation
    case spam
    case privacyConcern

    var id: String { rawValue }

    var title: String {
        switch self {
        case .abusiveLanguage: "Abusive language"
        case .harassment: "Harassment"
        case .falseInformation: "False information"
        case .spam: "Spam"
        case .privacyConcern: "Privacy concern"
        }
    }
}

struct ReviewReportRecord: Identifiable, Equatable {
    let id: String
    let reviewID: String
    let reporterID: String
    let reason: ReviewReportReason
    let note: String
    let createdAt: Date
}

enum ReviewRepositoryError: LocalizedError {
    case duplicateSubmission
    case invalidStage
    case alreadyReported

    var errorDescription: String? {
        switch self {
        case .duplicateSubmission: "You already submitted this review for the selected stage."
        case .invalidStage: "This review stage is not yet available."
        case .alreadyReported: "You already reported this review."
        }
    }
}
