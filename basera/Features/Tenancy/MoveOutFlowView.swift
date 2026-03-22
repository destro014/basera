import SwiftUI
import VroxalDesign

struct MoveOutFlowView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: MoveOutFlowViewModel

    let userID: String
    let party: AgreementRecord.Party

    init(tenancy: TenancyRecord, userID: String, party: AgreementRecord.Party) {
        _viewModel = StateObject(wrappedValue: MoveOutFlowViewModel(tenancy: tenancy))
        self.userID = userID
        self.party = party
    }

    var body: some View {
        List {
            Section("Tenancy closure state") {
                Text(viewModel.tenancy.closureState.title)
                Text("Owner cannot force tenancy closure outside this flow.")
                    .foregroundStyle(Color.vdContentDefaultSecondary)
            }

            if party == .renter {
                renterRequestSection
            }

            if party == .owner {
                ownerApprovalSection
                ownerSettlementSection
            }

            checklistSection
            meterSection
            historySection
            listingReactivationSection
        }
        .baseraListBackground()
        .navigationTitle("Move-out & Closure")
        .alert("Move-out flow", isPresented: moveOutErrorIsPresented, actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }

    private var renterRequestSection: some View {
        Section("Renter move-out request") {
            DatePicker("Requested move-out date", selection: $viewModel.requestDate, displayedComponents: .date)
            VdTextField(title: "Reason", text: $viewModel.requestReason)
            VdTextField(title: "Condition notes", text: $viewModel.conditionNotes)
            VdTextField(title: "Photo placeholders (comma separated)", text: $viewModel.photoPlaceholderInput)
            Button("Submit move-out request") {
                Task {
                    await viewModel.submitRenterMoveOutRequest(userID: userID, repository: environment.tenancyRepository)
                }
            }
        }
    }

    private var ownerApprovalSection: some View {
        Section("Owner approval flow") {
            if let request = viewModel.tenancy.moveOutRequest {
                Text("Requested: \(request.requestedMoveOutDate.formatted(date: .abbreviated, time: .omitted))")
                Text("Reason: \(request.reason)")
                Text("Condition notes: \(request.conditionNotes)")
                if request.photoPlaceholders.isEmpty == false {
                    Text("Photos: \(request.photoPlaceholders.joined(separator: ", "))")
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                }
            } else {
                Text("No request yet")
            }

            VdTextField(title: "Owner note", text: $viewModel.ownerNote)
            HStack {
                Button("Approve request") {
                    Task {
                        await viewModel.ownerDecision(userID: userID, approve: true, repository: environment.tenancyRepository)
                    }
                }
                Button("Decline request") {
                    Task {
                        await viewModel.ownerDecision(userID: userID, approve: false, repository: environment.tenancyRepository)
                    }
                }
            }
        }
    }

    private var checklistSection: some View {
        Section("Move-out checklist") {
            if viewModel.checklistItems.isEmpty {
                Text("Checklist appears after owner approval.")
            } else {
                ForEach($viewModel.checklistItems) { $item in
                    Toggle(item.title, isOn: $item.isCompleted)
                    VdTextField(title: "Notes", text: $item.notes)
                    VdTextField(title: "Photo placeholders", text: .constant(item.photoPlaceholders.joined(separator: ", ")))
                }
                Button("Save checklist + final meter") {
                    Task {
                        await viewModel.saveChecklistAndMeter(userID: userID, repository: environment.tenancyRepository)
                    }
                }
            }
        }
    }

    private var meterSection: some View {
        Section("Final meter readings") {
            VdTextField(title: "Electricity", text: $viewModel.electricityReading)
            VdTextField(title: "Water", text: $viewModel.waterReading)
            VdTextField(title: "Internet", text: $viewModel.internetReading)
        }
    }

    private var ownerSettlementSection: some View {
        Section("Deposit deduction & refund") {
            Picker("Refund type", selection: $viewModel.refundType) {
                ForEach(TenancyRecord.DepositSettlement.RefundType.allCases) { type in
                    Text(type.title).tag(type)
                }
            }
            VdTextField(title: "Deduction title", text: $viewModel.deductionTitle)
            VdTextField(title: "Deduction amount", text: $viewModel.deductionAmount, keyboardType: .decimalPad)
            VdTextField(title: "Deduction note", text: $viewModel.deductionNote)
            VdTextField(title: "Refund amount", text: $viewModel.refundAmount, keyboardType: .decimalPad)
            VdTextField(title: "Settlement summary", text: $viewModel.settlementSummary)
            Button("Save settlement") {
                Task {
                    await viewModel.submitSettlement(userID: userID, repository: environment.tenancyRepository)
                }
            }

            Button("Close tenancy") {
                Task {
                    await viewModel.closeTenancy(userID: userID, repository: environment.tenancyRepository)
                }
            }
            .disabled(viewModel.tenancy.canOwnerCloseTenancy == false)
        }
    }

    private var historySection: some View {
        Section("Historical records after closure") {
            Text("Agreement: \(viewModel.tenancy.historicalAccess.agreementAvailable ? "Available" : "Unavailable")")
            Text("Invoices: \(viewModel.tenancy.historicalAccess.invoicesAvailable ? "Available" : "Unavailable")")
            Text("Payments: \(viewModel.tenancy.historicalAccess.paymentsAvailable ? "Available" : "Unavailable")")
        }
    }

    private var listingReactivationSection: some View {
        Section("Listing reactivation readiness") {
            Text(viewModel.tenancy.listingReactivation.isReady ? "Ready for future reuse" : "Pending before reuse")
            ForEach(viewModel.tenancy.listingReactivation.pendingItems, id: \.self) { item in
                Text("• \(item)")
                    .foregroundStyle(Color.vdContentDefaultSecondary)
            }
            if party == .owner {
                NavigationLink("Leave owner review") {
                    ReviewHubView(userID: userID, role: .owner)
                }
            }
        }
    }

    private var moveOutErrorIsPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if isPresented == false {
                    viewModel.errorMessage = nil
                }
            }
        )
    }
}

#Preview {
    NavigationView {
        MoveOutFlowView(tenancy: PreviewData.mockTenancies[0], userID: "preview-user-001", party: .renter)
            .environmentObject(AppEnvironment.bootstrap())
    }
}
