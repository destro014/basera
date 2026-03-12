import SwiftUI

struct ReviewHubView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: ReviewHubViewModel
    @State private var selectedReviewForReport: ReviewRecord?

    init(userID: String, role: UserRole) {
        _viewModel = StateObject(wrappedValue: ReviewHubViewModel(userID: userID, role: role))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                BaseraLoadingView(message: "Loading reviews")
            case .error(let message):
                BaseraErrorStateView(title: "Reviews unavailable", message: message) {
                    Task { await viewModel.load(using: environment.reviewsRepository) }
                }
            case .loaded:
                content
            }
        }
        .navigationTitle("Reviews")
        .sheet(item: $selectedReviewForReport) { review in
            reportSheet(for: review)
        }
        .task {
            guard viewModel.state == .idle else { return }
            await viewModel.load(using: environment.reviewsRepository)
        }
    }

    private var content: some View {
        ScrollView {
            BaseraPageContainer {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                    ratingSummaryCard
                    submissionSection
                    publicReviewsSection
                }
            }
        }
    }

    private var ratingSummaryCard: some View {
        ReviewRatingSummaryCard(summary: viewModel.ratingSummary)
    }


    private var submissionSection: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text("Leave a review")
                    .baseraTextStyle(AppTheme.Typography.titleMedium)

                if viewModel.submissionContexts.isEmpty {
                    BaseraEmptyStateView(
                        title: "No review opportunities yet",
                        message: "You can review once a tenancy is active.",
                        systemImage: "star.bubble"
                    )
                } else {
                    Picker("Stage", selection: $viewModel.selectedContextID) {
                        ForEach(viewModel.submissionContexts) { context in
                            Text("\(context.revieweeName) · \(context.stage.title)").tag(Optional(context.id))
                        }
                    }

                    if let context = viewModel.selectedContext {
                        if let review = context.existingReview {
                            BaseraInlineMessageView(
                                tone: .success,
                                message: "Already submitted for this stage: \(review.ratingLabel)"
                            )
                        } else if !context.canSubmit {
                            BaseraInlineMessageView(
                                tone: .info,
                                message: context.stage == .postMoveOut ? "Available after move-out completion." : "This stage is currently unavailable."
                            )
                        } else {
                            Stepper("Rating: \(viewModel.selectedRating)", value: $viewModel.selectedRating, in: 1...5)
                            BaseraTextField(
                                title: "Comment",
                                text: $viewModel.reviewComment,
                                prompt: "Share your experience"
                            )
                            BaseraButton(title: "Submit Public Review", style: .primary) {
                                Task { await viewModel.submit(using: environment.reviewsRepository) }
                            }
                        }
                    }
                }

                if let banner = viewModel.bannerMessage {
                    BaseraInlineMessageView(tone: .info, message: banner)
                }
            }
        }
    }

    private var publicReviewsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text("Public reviews received")
                .baseraTextStyle(AppTheme.Typography.titleMedium)

            if viewModel.receivedReviews.isEmpty {
                BaseraEmptyStateView(
                    title: "No reviews yet",
                    message: "Published reviews from renter and owner will appear here.",
                    systemImage: "star.slash"
                )
            } else {
                ForEach(viewModel.receivedReviews) { review in
                    PublicReviewCard(review: review) {
                        selectedReviewForReport = review
                    }
                }
            }
        }
    }

    private func reportSheet(for review: ReviewRecord) -> some View {
        NavigationView {
            Form {
                Picker("Reason", selection: $viewModel.reportReason) {
                    ForEach(ReviewReportReason.allCases) { reason in
                        Text(reason.title).tag(reason)
                    }
                }

                BaseraTextField(
                    title: "Details",
                    text: $viewModel.reportNote,
                    prompt: "Optional context"
                )

                BaseraButton(title: "Submit Report", style: .primary) {
                    Task {
                        await viewModel.report(reviewID: review.id, using: environment.reviewsRepository)
                        selectedReviewForReport = nil
                    }
                }
            }
            .navigationTitle("Report Review")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { selectedReviewForReport = nil }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ReviewHubView(userID: "preview-user-001", role: .renter)
            .environmentObject(AppEnvironment.bootstrap())
    }
}
