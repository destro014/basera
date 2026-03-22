import SwiftUI
import VroxalDesign

struct InvoiceListView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = InvoiceListViewModel()

    let tenancy: TenancyRecord
    let userID: String
    let actor: InvoiceRecord.CreatedByRole

    var body: some View {
        List {
            Section("Billing settings") {
                if let settings = viewModel.settings {
                    Text("Renter draft bills: \(settings.allowsRenterGeneratedBillDraft ? "Enabled" : "Disabled")")
                    Text("Partial payments: \(settings.allowsPartialPayment ? "Enabled" : "Disabled")")
                }
            }

            Section("Create") {
                if actor == .owner || (viewModel.settings?.allowsRenterGeneratedBillDraft == true) {
                    NavigationLink(actor == .owner ? "Create monthly invoice" : "Create renter bill draft") {
                        InvoiceComposerView(tenancy: tenancy, userID: userID, actor: actor)
                    }
                } else {
                    Text("Owner has not enabled renter-generated bill drafts.")
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                }
            }


            Section("Payments") {
                NavigationLink(actor == .owner ? "Open payment tracking" : "Open payment center") {
                    PaymentsHubView(tenancy: tenancy, userID: userID, actor: actor)
                }
            }

            Section("Invoices") {
                ForEach(viewModel.invoices) { invoice in
                    NavigationLink {
                        InvoiceDetailView(invoiceID: invoice.id, userID: userID)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(invoice.header.billingMonth.formatted(.dateTime.year().month()))
                            Text("Rs. \(NSDecimalNumber(decimal: invoice.totalAmount).stringValue) • \(invoice.status.title)")
                                .foregroundStyle(Color.vdContentDefaultSecondary)
                        }
                    }
                }
            }
        }
        .baseraListBackground()
        .navigationTitle(actor == .owner ? "Owner Billing" : "My Bills")
        .task {
            await viewModel.load(tenancyID: tenancy.id, userID: userID, repository: environment.billingRepository)
        }
        .alert("Billing error", isPresented: billingErrorIsPresented, actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: { Text(viewModel.errorMessage ?? "") })
    }

    private var billingErrorIsPresented: Binding<Bool> {
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

struct InvoiceComposerView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: InvoiceComposerViewModel
    @State private var showPreview = false

    let tenancy: TenancyRecord
    let userID: String
    let actor: InvoiceRecord.CreatedByRole

    init(tenancy: TenancyRecord, userID: String, actor: InvoiceRecord.CreatedByRole) {
        self.tenancy = tenancy
        self.userID = userID
        self.actor = actor
        _viewModel = StateObject(wrappedValue: InvoiceComposerViewModel(monthlyRent: tenancy.monthlyRent))
    }

    var body: some View {
        Form {
            Section("Invoice header") {
                DatePicker("Billing month", selection: $viewModel.billMonth, displayedComponents: .date)
                DatePicker("Due date", selection: $viewModel.dueDate, displayedComponents: .date)
                VdTextField(title: "Rent amount", text: $viewModel.rentAmountText, keyboardType: .decimalPad)
            }

            Section("Electricity") {
                Toggle("Include electricity", isOn: $viewModel.includesElectricity)
                if viewModel.includesElectricity {
                    Picker("Mode", selection: $viewModel.electricityInputMode) {
                        Text("Flat fee").tag(InvoiceComposerViewModel.ElectricityInputMode.flat)
                        Text("Consumed units").tag(InvoiceComposerViewModel.ElectricityInputMode.consumedUnits)
                        Text("Meter based").tag(InvoiceComposerViewModel.ElectricityInputMode.meterBased)
                    }

                    switch viewModel.electricityInputMode {
                    case .flat:
                        VdTextField(title: "Flat amount", text: $viewModel.electricityFlatAmountText, keyboardType: .decimalPad)
                    case .consumedUnits:
                        VdTextField(title: "Units consumed", text: $viewModel.electricityUnitsText, keyboardType: .decimalPad)
                        VdTextField(title: "Rate per unit", text: $viewModel.electricityRateText, keyboardType: .decimalPad)
                    case .meterBased:
                        VdTextField(title: "Previous reading", text: $viewModel.electricityPreviousReadingText, keyboardType: .decimalPad)
                        VdTextField(title: "Current reading", text: $viewModel.electricityCurrentReadingText, keyboardType: .decimalPad)
                        VdTextField(title: "Rate per unit", text: $viewModel.electricityRateText, keyboardType: .decimalPad)
                    }
                }
            }

            Section("Utilities") {
                ForEach($viewModel.utilityCharges) { $charge in
                    VStack(alignment: .leading) {
                        Text(charge.category.title)
                        Picker("Type", selection: Binding(get: {
                            switch charge.mode {
                            case .flat: 0
                            case .variable: 1
                            }
                        }, set: { mode in
                            charge.mode = mode == 0 ? .flat(amount: 0) : .variable(quantity: 0, rate: 0)
                        })) {
                            Text("Flat").tag(0)
                            Text("Variable").tag(1)
                        }

                        switch charge.mode {
                        case .flat(let amount):
                            VdTextField(title: "Amount", text: Binding(
                                get: { NSDecimalNumber(decimal: amount).stringValue },
                                set: { charge.mode = .flat(amount: Decimal(string: $0) ?? 0) }
                            ), keyboardType: .decimalPad)
                        case .variable(let quantity, let rate):
                            VdTextField(title: "Quantity", text: Binding(
                                get: { NSDecimalNumber(decimal: quantity).stringValue },
                                set: { charge.mode = .variable(quantity: Decimal(string: $0) ?? 0, rate: rate) }
                            ), keyboardType: .decimalPad)
                            VdTextField(title: "Rate", text: Binding(
                                get: { NSDecimalNumber(decimal: rate).stringValue },
                                set: { charge.mode = .variable(quantity: quantity, rate: Decimal(string: $0) ?? 0) }
                            ), keyboardType: .decimalPad)
                        }
                    }
                }
            }

            amountNotesSection(title: "Other charges", notes: $viewModel.otherCharges)
            amountNotesSection(title: "Deductions", notes: $viewModel.deductions)
            amountNotesSection(title: "Credits", notes: $viewModel.credits)

            Section("Notes") {
                TextEditor(text: $viewModel.note)
                    .frame(minHeight: 80)
            }
        }
        .baseraListBackground()
        .navigationTitle(actor == .owner ? "Create Invoice" : "Bill Draft")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Preview") {
                    Task {
                        await viewModel.loadPreview(tenancy: tenancy, actor: actor, repository: environment.billingRepository, userID: userID)
                        showPreview = viewModel.previewInvoice != nil
                    }
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button(actor == .owner ? "Generate Invoice" : "Submit Draft") {
                    Task {
                        if await viewModel.submit(tenancy: tenancy, actor: actor, repository: environment.billingRepository, userID: userID) != nil {
                            dismiss()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showPreview) {
            if let invoice = viewModel.previewInvoice {
                NavigationView {
                    InvoicePreviewView(invoice: invoice)
                }
            }
        }
    }

    private func amountNotesSection(title: String, notes: Binding<[InvoiceDraftInput.AmountNote]>) -> some View {
        Section(title) {
            ForEach(notes) { note in
                VStack(alignment: .leading) {
                    VdTextField(title: "Title", text: Binding(get: { note.wrappedValue.title }, set: { note.wrappedValue.title = $0 }))
                    VdTextField(title: "Amount", text: Binding(
                        get: { NSDecimalNumber(decimal: note.wrappedValue.amount).stringValue },
                        set: { note.wrappedValue.amount = Decimal(string: $0) ?? 0 }
                    ), keyboardType: .decimalPad)
                }
            }
            Button("Add") {
                notes.wrappedValue.append(.init(id: UUID().uuidString, title: "", amount: 0))
            }
        }
    }
}

struct InvoicePreviewView: View {
    let invoice: InvoiceRecord

    var body: some View {
        List {
            Section("Header") {
                Text(invoice.header.listingTitle)
                Text(invoice.header.billingMonth.formatted(.dateTime.year().month()))
                Text("Due: \(invoice.header.dueDate.formatted(date: .abbreviated, time: .omitted))")
            }
            Section("Line items") {
                ForEach(invoice.items) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.title)
                            if let detail = item.detail {
                                Text(detail).foregroundStyle(Color.vdContentDefaultSecondary)
                            }
                        }
                        Spacer()
                        Text("Rs. \(NSDecimalNumber(decimal: item.amount).stringValue)")
                    }
                }
            }
            Section("Totals") {
                Text("Subtotal: Rs. \(NSDecimalNumber(decimal: invoice.subtotal).stringValue)")
                Text("Carry forward: Rs. \(NSDecimalNumber(decimal: invoice.carryForwardBalance).stringValue)")
                Text("Total: Rs. \(NSDecimalNumber(decimal: invoice.totalAmount).stringValue)")
            }
        }
        .baseraListBackground()
        .navigationTitle("Invoice Preview")
    }
}

struct InvoiceDetailView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @State private var invoice: InvoiceRecord?
    @State private var errorMessage: String?

    let invoiceID: String
    let userID: String

    var body: some View {
        Group {
            if let invoice {
                InvoicePreviewView(invoice: invoice)
                    .toolbar {
                        if invoice.status == .pendingOwnerApproval && invoice.header.ownerID == userID {
                            ToolbarItemGroup(placement: .bottomBar) {
                                Button("Reject") {
                                    Task { await reject() }
                                }
                                Button("Approve") {
                                    Task { await approve() }
                                }
                            }
                        }
                    }
            } else {
                VdLoadingState(title: "Loading invoice")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .task {
            do {
                invoice = try await environment.billingRepository.fetchInvoice(id: invoiceID, userID: userID)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        .alert("Error", isPresented: errorAlertIsPresented, actions: {
            Button("OK") { errorMessage = nil }
        }, message: { Text(errorMessage ?? "") })
    }

    private func approve() async {
        do {
            invoice = try await environment.billingRepository.approveInvoice(invoiceID: invoiceID, ownerID: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func reject() async {
        do {
            invoice = try await environment.billingRepository.rejectInvoice(invoiceID: invoiceID, ownerID: userID, reason: "Please revise utility entries")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private var errorAlertIsPresented: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if isPresented == false {
                    errorMessage = nil
                }
            }
        )
    }
}

#Preview {
    NavigationView {
        InvoiceListView(
            tenancy: PreviewData.mockTenancies[0],
            userID: "owner-100",
            actor: .owner
        )
        .environmentObject(AppEnvironment.bootstrap())
    }
}
