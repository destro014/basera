import SwiftUI

struct OwnerInterestedRentersView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: OwnerInterestedRentersViewModel

    init(listingID: String, ownerID: String) {
        _viewModel = StateObject(wrappedValue: OwnerInterestedRentersViewModel(listingID: listingID, ownerID: ownerID))
    }

    var body: some View {
        List {
            if viewModel.badge.ownerPendingInterests > 0 {
                Label("\(viewModel.badge.ownerPendingInterests) pending interest requests", systemImage: "bell.badge")
            }

            ForEach(viewModel.interests) { interest in
                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    Text(interest.renterSnapshot.fullName)
                        .baseraTextStyle(AppTheme.Typography.titleSmall)
                    Text("\(interest.renterSnapshot.occupation) • Family \(interest.renterSnapshot.familySize)")
                        .baseraTextStyle(AppTheme.Typography.bodySmall)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    Text(interest.submittedMessage)
                        .baseraTextStyle(AppTheme.Typography.bodySmall)
                    HStack {
                        BaseraBadge(text: interest.status.label, tone: statusTone(interest.status))
                        BaseraBadge(text: interest.chatApproval.label, tone: chatTone(interest.chatApproval))
                    }
                    actionRow(for: interest)
                }
                .padding(.vertical, AppTheme.Spacing.xSmall)
            }
        }
        .navigationTitle("Interested Renters")
        .task {
            await viewModel.load(using: environment.interestsRepository)
        }
    }

    @ViewBuilder
    private func actionRow(for interest: InterestRequest) -> some View {
        HStack {
            if interest.status == .pending {
                BaseraButton(title: "Accept", style: .primary) {
                    Task { await viewModel.accept(interest.id, using: environment.interestsRepository) }
                }
                BaseraButton(title: "Reject", style: .secondary) {
                    Task { await viewModel.reject(interest.id, using: environment.interestsRepository) }
                }
            } else if interest.canApproveChat {
                BaseraButton(title: "Approve Chat", style: .primary) {
                    Task { await viewModel.approveChat(interest.id, using: environment.interestsRepository) }
                }
            } else if interest.canOpenChat {
                NavigationLink("Open Chat") {
                    ConversationListView(userID: viewModel.ownerID)
                }
            }
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

#Preview("Pending/Accepted/Rejected") {
    NavigationView {
        OwnerInterestedRentersView(listingID: "OL-200", ownerID: "preview-user-001")
    }
    .environmentObject(AppEnvironment.bootstrap())
}
