import SwiftUI
import VroxalDesign

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
                VdLoadingState(title: "Loading reviews")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            case .error(let message):
                VdAlert(title: "Reviews unavailable", message: message) {
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
                VStack(alignment: .leading, spacing: VdSpacing.md) {
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
            VStack(alignment: .leading, spacing: VdSpacing.smMd) {
                Text("Leave a review")
                    .vdFont(VdFont.titleMedium)

                if viewModel.submissionContexts.isEmpty {
                    VdEmptyState(
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
                            VdAlert(
                                tone: .success,
                                message: "Already submitted for this stage: \(review.ratingLabel)"
                            )
                        } else if !context.canSubmit {
                            VdAlert(
                                tone: .info,
                                message: context.stage == .postMoveOut ? "Available after move-out completion." : "This stage is currently unavailable."
                            )
                        } else {
                            Stepper("Rating: \(viewModel.selectedRating)", value: $viewModel.selectedRating, in: 1...5)
                            VdTextField(
                                title: "Comment",
                                prompt: "Share your experience",
                                text: $viewModel.reviewComment
                            )
                            VdButton(title: "Submit Public Review", style: .primary) {
                                Task { await viewModel.submit(using: environment.reviewsRepository) }
                            }
                        }
                    }
                }

                if let banner = viewModel.bannerMessage {
                    VdAlert(tone: .info, message: banner)
                }
            }
        }
    }

    private var publicReviewsSection: some View {
        VStack(alignment: .leading, spacing: VdSpacing.sm) {
            Text("Public reviews received")
                .vdFont(VdFont.titleMedium)

            if viewModel.receivedReviews.isEmpty {
                VdEmptyState(
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

                VdTextField(
                    title: "Details",
                    prompt: "Optional context",
                    text: $viewModel.reportNote
                )

                VdButton(title: "Submit Report", style: .primary) {
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
