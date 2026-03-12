import SwiftUI

struct RenterInterestsView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: RenterInterestsViewModel

    init(renterID: String) {
        _viewModel = StateObject(wrappedValue: RenterInterestsViewModel(renterID: renterID))
    }

    var body: some View {
        List {
            if viewModel.badge.renterChatApprovals > 0 {
                BaseraInlineMessageView(tone: .success, message: "\(viewModel.badge.renterChatApprovals) chat request(s) approved.")
            }

            ForEach(viewModel.interests) { interest in
                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    Text("Listing \(interest.listingID)")
                        .baseraTextStyle(AppTheme.Typography.titleSmall)
                    Text(interest.submittedMessage)
                        .baseraTextStyle(AppTheme.Typography.bodySmall)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    HStack {
                        BaseraBadge(text: interest.status.label, tone: statusTone(interest.status))
                        BaseraBadge(text: interest.chatApproval.label, tone: chatTone(interest.chatApproval))
                    }
                    if interest.canOpenChat {
                        NavigationLink("Open Chat") {
                            ConversationListView(userID: viewModel.renterID)
                        }
                    }
                }
                .padding(.vertical, AppTheme.Spacing.xSmall)
            }
        }
        .navigationTitle("My Interests")
        .task {
            await viewModel.load(using: environment.interestsRepository)
        }
    }

    private func statusTone(_ status: InterestRequest.Status) -> Color {
        switch status {
        case .pending: AppTheme.Colors.warningPrimary
        case .accepted: AppTheme.Colors.successPrimary
        case .rejected: AppTheme.Colors.errorPrimary
        }
    }

    private func chatTone(_ state: InterestRequest.ChatApproval) -> Color {
        switch state {
        case .unavailable: AppTheme.Colors.textSecondary
        case .awaitingOwnerApproval: AppTheme.Colors.warningPrimary
        case .approved: AppTheme.Colors.successPrimary
        }
    }
}

#Preview("Accepted + chat approved") {
    NavigationView {
        RenterInterestsView(renterID: "preview-user-001")
    }
    .environmentObject(AppEnvironment.bootstrap())
}
