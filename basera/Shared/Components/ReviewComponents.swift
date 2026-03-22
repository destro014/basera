import SwiftUI
import VroxalDesign

struct ReviewRatingSummaryCard: View {
    let summary: ReviewRatingSummary

    var body: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: VdSpacing.sm) {
                Text("Your public rating")
                    .vdFont(VdFont.titleMedium)

                if summary.reviewCount == 0 {
                    Text("No public reviews yet.")
                        .vdFont(VdFont.bodyMedium)
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                } else {
                    Text(String(format: "%.1f ★", summary.averageRating))
                        .vdFont(VdFont.titleLarge)
                    Text("Based on \(summary.reviewCount) review(s)")
                        .vdFont(VdFont.bodySmall)
                        .foregroundStyle(Color.vdContentDefaultSecondary)
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
            VStack(alignment: .leading, spacing: VdSpacing.sm) {
                Text("\(review.reviewerName) • \(review.stage.title)")
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary)
                Text(review.ratingLabel)
                    .vdFont(VdFont.titleSmall)
                Text(review.comment)
                    .vdFont(VdFont.bodyMedium)
                Button("Report review", action: onReportTapped)
                    .vdFont(VdFont.bodySmall)
            }
        }
    }
}

#Preview {
    VStack(spacing: VdSpacing.smMd) {
        ReviewRatingSummaryCard(summary: .init(averageRating: 4.7, reviewCount: 12))
        PublicReviewCard(review: PreviewData.mockReviews[0], onReportTapped: {})
    }
    .padding()
}
