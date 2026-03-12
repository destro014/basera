import SwiftUI

struct ReviewRatingSummaryCard: View {
    let summary: ReviewRatingSummary

    var body: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text("Your public rating")
                    .baseraTextStyle(AppTheme.Typography.titleMedium)

                if summary.reviewCount == 0 {
                    Text("No public reviews yet.")
                        .baseraTextStyle(AppTheme.Typography.bodyMedium)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                } else {
                    Text(String(format: "%.1f ★", summary.averageRating))
                        .baseraTextStyle(AppTheme.Typography.titleLarge)
                    Text("Based on \(summary.reviewCount) review(s)")
                        .baseraTextStyle(AppTheme.Typography.bodySmall)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
        }
    }
}

struct PublicReviewCard: View {
    let review: ReviewRecord
    let onReportTapped: () -> Void

    var body: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text("\(review.reviewerName) • \(review.stage.title)")
                    .baseraTextStyle(AppTheme.Typography.bodySmall)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text(review.ratingLabel)
                    .baseraTextStyle(AppTheme.Typography.titleSmall)
                Text(review.comment)
                    .baseraTextStyle(AppTheme.Typography.bodyMedium)
                Button("Report review", action: onReportTapped)
                    .baseraTextStyle(AppTheme.Typography.bodySmall)
            }
        }
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.medium) {
        ReviewRatingSummaryCard(summary: .init(averageRating: 4.7, reviewCount: 12))
        PublicReviewCard(review: PreviewData.mockReviews[0], onReportTapped: {})
    }
    .padding()
}
