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

            if let assignment = viewModel.assignment {
                NavigationLink("Open Assignment Request") {
                    RenterAssignmentRequestView(
                        assignment: assignment,
                        onAccept: {
                            Task {
                                await viewModel.respondToAssignment(
                                    accept: true,
                                    interestsRepository: environment.interestsRepository,
                                    listingsRepository: environment.listingsRepository
                                )
                            }
                        },
                        onDecline: {
                            Task {
                                await viewModel.respondToAssignment(
                                    accept: false,
                                    interestsRepository: environment.interestsRepository,
                                    listingsRepository: environment.listingsRepository
                                )
                            }
                        }
                    )
                }
            }

            Section("Visit Schedule") {
                if viewModel.visits.isEmpty {
                    Text("No visit requests yet.")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }

                ForEach(viewModel.visits) { visit in
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Listing \(visit.listingID)")
                            .baseraTextStyle(AppTheme.Typography.titleSmall)
                        Text(visit.scheduledAt, style: .date)
                        Text(visit.scheduledAt, style: .time)
                        Text(visit.note)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                        HStack {
                            BaseraBadge(text: visit.status.label, tone: visit.status == .confirmed ? AppTheme.Colors.successPrimary : AppTheme.Colors.warningPrimary)
                            if visit.status == .proposed {
                                BaseraButton(title: "Confirm", style: .primary) {
                                    Task { await viewModel.confirmVisit(visit.id, using: environment.interestsRepository) }
                                }
                            }
                        }
                    }
                    .padding(.vertical, AppTheme.Spacing.xSmall)
                }
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
