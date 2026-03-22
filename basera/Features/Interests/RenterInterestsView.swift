import SwiftUI
import VroxalDesign

struct RenterInterestsView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: RenterInterestsViewModel

    init(renterID: String) {
        _viewModel = StateObject(wrappedValue: RenterInterestsViewModel(renterID: renterID))
    }

    var body: some View {
        List {
            if viewModel.badge.renterChatApprovals > 0 {
                VdAlert(tone: .success, message: "\(viewModel.badge.renterChatApprovals) chat request(s) approved.")
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
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                }

                ForEach(viewModel.visits) { visit in
                    VStack(alignment: .leading, spacing: VdSpacing.sm) {
                        Text("Listing \(visit.listingID)")
                            .vdFont(VdFont.titleSmall)
                        Text(visit.scheduledAt, style: .date)
                        Text(visit.scheduledAt, style: .time)
                        Text(visit.note)
                            .foregroundStyle(Color.vdContentDefaultSecondary)
                        HStack {
                            VdBadge(
                                visit.status.label,
                                color: visit.status == .confirmed ? .success : .warning,
                                style: .subtle
                            )
                            if visit.status == .proposed {
                                VdButton(title: "Confirm", style: .primary) {
                                    Task { await viewModel.confirmVisit(visit.id, using: environment.interestsRepository) }
                                }
                            }
                        }
                    }
                    .padding(.vertical, VdSpacing.xs)
                }
            }

            ForEach(viewModel.interests) { interest in
                VStack(alignment: .leading, spacing: VdSpacing.sm) {
                    Text("Listing \(interest.listingID)")
                        .vdFont(VdFont.titleSmall)
                    Text(interest.submittedMessage)
                        .vdFont(VdFont.bodySmall)
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                    HStack {
                        VdBadge(interest.status.label, color: statusTone(interest.status), style: .subtle)
                        VdBadge(interest.chatApproval.label, color: chatTone(interest.chatApproval), style: .subtle)
                    }
                    if interest.canOpenChat {
                        NavigationLink("Open Chat") {
                            ConversationListView(userID: viewModel.renterID)
                        }
                    }
                }
                .padding(.vertical, VdSpacing.xs)
            }
        }
        .baseraListBackground()
        .navigationTitle("My Interests")
        .task {
            await viewModel.load(using: environment.interestsRepository)
        }
    }

    private func statusTone(_ status: InterestRequest.Status) -> VdBadgeColor {
        switch status {
        case .pending: .warning
        case .accepted: .success
        case .rejected: .error
        }
    }

    private func chatTone(_ state: InterestRequest.ChatApproval) -> VdBadgeColor {
        switch state {
        case .unavailable: .neutral
        case .awaitingOwnerApproval: .warning
        case .approved: .success
        }
    }
}

#Preview("Accepted + chat approved") {
    NavigationView {
        RenterInterestsView(renterID: "preview-user-001")
    }
    .environmentObject(AppEnvironment.bootstrap())
}
