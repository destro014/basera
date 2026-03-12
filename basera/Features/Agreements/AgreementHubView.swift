import SwiftUI

struct AgreementHubView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: AgreementFlowViewModel

    init(currentUserID: String, party: AgreementRecord.Party) {
        _viewModel = StateObject(wrappedValue: AgreementFlowViewModel(currentUserID: currentUserID, currentParty: party))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                AgreementStatusTrackingView(agreement: viewModel.selectedAgreement)

                if viewModel.currentParty == .owner {
                    ownerCreationCard
                    editableSectionsCard
                }

                AgreementPreviewCard(agreement: viewModel.selectedAgreement, viewerParty: viewModel.currentParty)
                signatureCard
                successState

                if let agreement = viewModel.selectedAgreement {
                    AgreementDetailCard(agreement: agreement)
                    AgreementPDFCard(agreementID: agreement.id)
                    renewalScaffoldCard
                }
            }
            .padding()
        }
        .navigationTitle("Agreements")
        .task {
            await viewModel.load(using: environment.agreementsRepository)
        }
        .alert("Agreement update", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }

    private var ownerCreationCard: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text("Owner agreement creation")
                    .baseraTextStyle(AppTheme.Typography.titleMedium)
                Text("Create and edit all mandatory sections before signing. Agreement remains editable until both typed-name and OTP confirmation are completed.")
                    .baseraTextStyle(AppTheme.Typography.bodyMedium)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                BaseraButton(title: "Create Draft", style: .secondary) {
                    Task { await viewModel.createOwnerDraft(using: environment.agreementsRepository) }
                }
            }
        }
    }

    private var editableSectionsCard: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text("Editable sections (pre-sign)")
                    .baseraTextStyle(AppTheme.Typography.titleMedium)
                LabeledContent("Monthly rent") {
                    TextField("NPR", value: $viewModel.editableTerms.monthlyRent, format: .number)
                        .textFieldStyle(.roundedBorder)
                }
                LabeledContent("Security deposit") {
                    TextField("NPR", value: $viewModel.editableTerms.securityDeposit, format: .number)
                        .textFieldStyle(.roundedBorder)
                }
                editableTextField("Utility terms", text: $viewModel.editableTerms.utilityTerms)
                editableTextField("Rules & regulations", text: $viewModel.editableTerms.rulesAndRegulations)
                editableTextField("Late fee text", text: $viewModel.editableTerms.lateFeeText)
                editableTextField("Repair responsibility", text: $viewModel.editableTerms.repairResponsibility)
                editableTextField("Guest rules", text: $viewModel.editableTerms.guestRules)
                editableTextField("Pet rules", text: $viewModel.editableTerms.petRules)
                Stepper("Notice period: \(viewModel.editableTerms.noticePeriodDays) days", value: $viewModel.editableTerms.noticePeriodDays, in: 7...90)
                DatePicker("Start date", selection: $viewModel.editableTerms.startDate, displayedComponents: .date)
                DatePicker("End date", selection: $viewModel.editableTerms.endDate, displayedComponents: .date)

                HStack {
                    BaseraButton(title: "Save Edits", style: .secondary) {
                        Task { await viewModel.saveEdits(using: environment.agreementsRepository) }
                    }
                    BaseraButton(title: "Submit for Signing", style: .primary) {
                        Task { await viewModel.submitForSigning(using: environment.agreementsRepository) }
                    }
                }
            }
        }
    }

    private func editableTextField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text(title)
                .baseraTextStyle(AppTheme.Typography.labelLarge)
            TextField(title, text: text, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var signatureCard: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text("Typed-name + OTP confirmation")
                    .baseraTextStyle(AppTheme.Typography.titleMedium)
                TextField("Type your full legal name", text: $viewModel.typedName)
                    .textFieldStyle(.roundedBorder)
                BaseraButton(title: "Request OTP", style: .secondary) {
                    Task { await viewModel.requestOTP(using: environment.agreementsRepository) }
                }
                if viewModel.otpChallenge != nil {
                    TextField("Enter OTP", text: $viewModel.otpCode)
                        .textFieldStyle(.roundedBorder)
                    BaseraButton(title: "Confirm & Sign", style: .primary) {
                        Task { await viewModel.verifyOTPAndSign(using: environment.agreementsRepository) }
                    }
                }
            }
        }
    }

    private var successState: some View {
        Group {
            if let message = viewModel.successMessage {
                BaseraInlineMessageView(tone: .success, message: message)
            }
        }
    }

    private var renewalScaffoldCard: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text("Renewal entry point")
                    .baseraTextStyle(AppTheme.Typography.titleMedium)
                Text("Generate a new draft version linked to signed history. Signed records remain immutable.")
                    .baseraTextStyle(AppTheme.Typography.bodySmall)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                BaseraButton(title: "Create Renewal Draft", style: .secondary) {
                    Task { await viewModel.createRenewal(using: environment.agreementsRepository) }
                }
            }
        }
    }
}

private struct AgreementStatusTrackingView: View {
    let agreement: AgreementRecord?

    var body: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text("Agreement status tracking")
                    .baseraTextStyle(AppTheme.Typography.titleMedium)
                Text(agreement?.status.title ?? "No agreement selected")
                    .baseraTextStyle(AppTheme.Typography.bodyLarge)
                if let history = agreement?.statusHistory {
                    ForEach(history.reversed()) { event in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.title).baseraTextStyle(AppTheme.Typography.labelLarge)
                            Text(event.detail).baseraTextStyle(AppTheme.Typography.bodySmall)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                    }
                }
            }
        }
    }
}

private struct AgreementPreviewCard: View {
    let agreement: AgreementRecord?
    let viewerParty: AgreementRecord.Party

    var body: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text("Agreement preview (\(viewerParty.title))")
                    .baseraTextStyle(AppTheme.Typography.titleMedium)
                if let agreement {
                    Text("Owner: \(agreement.owner.fullName)")
                    Text("Renter: \(agreement.renter.fullName)")
                    Text("Property: \(agreement.property.listingTitle)")
                    Text("Address: \(agreement.previewAddress(for: viewerParty))")
                    Text("Monthly rent: NPR \(agreement.terms.monthlyRent.formatted())")
                    Text("Security deposit: NPR \(agreement.terms.securityDeposit.formatted())")
                    Text("Notice period: \(agreement.terms.noticePeriodDays) days")
                    Text("Digital record only (not legal enforcement).")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                } else {
                    Text("Create or select an agreement draft.")
                }
            }
            .baseraTextStyle(AppTheme.Typography.bodyMedium)
        }
    }
}

private struct AgreementDetailCard: View {
    let agreement: AgreementRecord

    var body: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text("Agreement detail")
                    .baseraTextStyle(AppTheme.Typography.titleMedium)
                Text("Agreement ID: \(agreement.id)")
                Text("Tenancy ID: \(agreement.tenancyID)")
                Text("Version: v\(agreement.version)")
                if let previous = agreement.previousAgreementID {
                    Text("Renewed from: \(previous)")
                }
                Text(agreement.isLocked ? "Status: Locked after signing" : "Status: Editable before signing")
                    .foregroundStyle(agreement.isLocked ? AppTheme.Colors.successPrimary : AppTheme.Colors.warningPrimary)
            }
            .baseraTextStyle(AppTheme.Typography.bodyMedium)
        }
    }
}

private struct AgreementPDFCard: View {
    let agreementID: String

    var body: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text("PDF preview / download placeholder")
                    .baseraTextStyle(AppTheme.Typography.titleMedium)
                Text("Architecture is wired through AgreementPDFServiceProtocol for server-side generation and future signed PDF storage.")
                    .baseraTextStyle(AppTheme.Typography.bodySmall)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                BaseraButton(title: "Preview PDF (placeholder)", style: .secondary, action: {})
                BaseraButton(title: "Download PDF (placeholder)", style: .subtle, action: {})
            }
        }
    }
}

#Preview {
    NavigationView {
        AgreementHubView(currentUserID: "preview-user-001", party: .owner)
            .environmentObject(AppEnvironment.bootstrap())
    }
}
