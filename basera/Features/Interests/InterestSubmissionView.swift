import SwiftUI

struct InterestSubmissionView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: InterestSubmissionViewModel

    init(listing: Listing, renterID: String, renterSnapshot: RenterProfileSnapshot) {
        _viewModel = StateObject(
            wrappedValue: InterestSubmissionViewModel(
                listing: listing,
                renterID: renterID,
                renterSnapshot: renterSnapshot
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                BaseraCard {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Interest Request")
                            .baseraTextStyle(AppTheme.Typography.titleLarge)
                        Text("Profile snapshot shared with owner")
                            .baseraTextStyle(AppTheme.Typography.bodySmall)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                        Text(viewModel.renterSnapshot.fullName)
                        Text("Occupation: \(viewModel.renterSnapshot.occupation)")
                        Text("Family size: \(viewModel.renterSnapshot.familySize)")
                        Text("Pets: \(viewModel.renterSnapshot.hasPets ? "Yes" : "No")")
                        Text("Smoking: \(viewModel.renterSnapshot.smokingStatus)")
                    }
                }

                BaseraTextField(
                    title: "Optional message",
                    text: $viewModel.optionalMessage,
                    prompt: "Share move-in timeline or requirements"
                )

                BaseraInlineMessageView(tone: .info, message: "Exact property address stays hidden until owner accepts your interest.")

                if case .error(let message) = viewModel.state {
                    BaseraInlineMessageView(tone: .error, message: message)
                }

                BaseraButton(
                    title: buttonTitle,
                    style: .primary,
                    isDisabled: viewModel.state == .submitting || viewModel.state == .submitted,
                    action: {
                        Task { await viewModel.submit(using: environment.interestsRepository) }
                    }
                )
            }
            .padding()
        }
        .navigationTitle("I'm Interested")
        .onChange(of: viewModel.state) { newValue in
            guard newValue == .submitted else { return }
            dismiss()
        }
    }

    private var buttonTitle: String {
        switch viewModel.state {
        case .submitting: return "Submitting..."
        case .submitted: return "Submitted"
        default: return "Send Interest"
        }
    }
}

#Preview("Pending") {
    NavigationView {
        InterestSubmissionView(
            listing: PreviewData.featuredListings[0],
            renterID: "preview-user-001",
            renterSnapshot: .init(renterID: "preview-user-001", fullName: "Sita Basera", occupation: "Engineer", familySize: 3, hasPets: false, smokingStatus: "Non-smoker")
        )
    }
    .environmentObject(AppEnvironment.bootstrap())
}
