import SwiftUI
import VroxalDesign

struct OwnerInterestedRentersView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: OwnerInterestedRentersViewModel
    @State private var schedulingRenterID: String?
    @State private var isScheduleSheetPresented = false
    @State private var scheduledAt: Date = .now
    @State private var visitNote = ""

    init(listingID: String, ownerID: String) {
        _viewModel = StateObject(wrappedValue: OwnerInterestedRentersViewModel(listingID: listingID, ownerID: ownerID))
    }

    var body: some View {
        List {
            if let assignment = viewModel.assignment {
                VdAlert(
                    tone: assignment.status == .accepted ? .success : .info,
                    message: "Assignment: \(assignment.status.label). Listing remains visible until agreement is signed."
                )
            }

            Section("Scheduled Visits") {
                if viewModel.visits.isEmpty {
                    Text("No visits scheduled yet.")
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                } else {
                    ForEach(viewModel.visits) { visit in
                        VStack(alignment: .leading, spacing: VdSpacing.sm) {
                            Text("Renter: \(visit.renterID)")
                            Text(visit.scheduledAt, style: .date)
                            Text(visit.scheduledAt, style: .time)
                            VdBadge(
                                visit.status.label,
                                color: visit.status == .confirmed ? .success : .warning,
                                style: .subtle
                            )
                        }
                    }
                }
            }

            Section("Interested Renters") {
                ForEach(viewModel.interests) { interest in
                    VStack(alignment: .leading, spacing: VdSpacing.sm) {
                        Text(interest.renterSnapshot.fullName)
                            .vdFont(VdFont.titleSmall)
                        Text("\(interest.renterSnapshot.occupation) • Family \(interest.renterSnapshot.familySize)")
                            .vdFont(VdFont.bodySmall)
                            .foregroundStyle(Color.vdContentDefaultSecondary)
                        Text(interest.submittedMessage)
                            .vdFont(VdFont.bodySmall)
                        HStack {
                            VdBadge(interest.status.label, color: statusTone(interest.status), style: .subtle)
                            VdBadge(interest.chatApproval.label, color: chatTone(interest.chatApproval), style: .subtle)
                        }
                        actionRow(for: interest)
                    }
                    .padding(.vertical, VdSpacing.xs)
                }
            }
        }
        .baseraListBackground()
        .navigationTitle("Interested Renters")
        .task {
            await viewModel.load(using: environment.interestsRepository)
        }
        .sheet(isPresented: $isScheduleSheetPresented) {
            NavigationView {
                if let renterID = schedulingRenterID {
                    VisitScheduleFormView(
                        scheduledAt: $scheduledAt,
                        note: $visitNote,
                        isSubmitting: false
                    ) {
                        Task {
                            await viewModel.scheduleVisit(
                                for: renterID,
                                at: scheduledAt,
                                note: visitNote,
                                using: environment.interestsRepository
                            )
                            schedulingRenterID = nil
                            isScheduleSheetPresented = false
                        }
                    }
                    .padding()
                    .navigationTitle("Schedule Visit")
                }
            }
        }
    }

    @ViewBuilder
    private func actionRow(for interest: InterestRequest) -> some View {
        HStack {
            if interest.status == .pending {
                VdButton(title: "Accept", style: .primary) {
                    Task { await viewModel.accept(interest.id, using: environment.interestsRepository) }
                }
                VdButton(title: "Reject", style: .secondary) {
                    Task { await viewModel.reject(interest.id, using: environment.interestsRepository) }
                }
            } else if interest.canApproveChat {
                VdButton(title: "Approve Chat", style: .primary) {
                    Task { await viewModel.approveChat(interest.id, using: environment.interestsRepository) }
                }
            } else if interest.canOpenChat {
                NavigationLink("Open Chat") {
                    ConversationListView(userID: viewModel.ownerID)
                }
                VdButton(title: "Schedule Visit", style: .secondary) {
                    scheduledAt = .now
                    visitNote = ""
                    schedulingRenterID = interest.renterID
                    isScheduleSheetPresented = true
                }
                if viewModel.canRequestAssignment(for: interest) {
                    VdButton(title: "Request Assignment", style: .primary) {
                        Task {
                            await viewModel.requestAssignment(
                                interestID: interest.id,
                                note: "Please confirm assignment before agreement drafting.",
                                interestsRepository: environment.interestsRepository,
                                listingsRepository: environment.listingsRepository
                            )
                        }
                    }
                }
            }
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


#Preview("Pending/Accepted/Rejected") {
    NavigationView {
        OwnerInterestedRentersView(listingID: "OL-200", ownerID: "preview-user-001")
    }
    .environmentObject(AppEnvironment.bootstrap())
}
