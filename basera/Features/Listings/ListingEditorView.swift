import SwiftUI
import VroxalDesign

struct ListingEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ListingEditorViewModel

    let onSave: (Listing) -> Void

    init(ownerID: String, listing: Listing? = nil, onSave: @escaping (Listing) -> Void) {
        _viewModel = StateObject(wrappedValue: ListingEditorViewModel(ownerID: ownerID, listing: listing))
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: VdSpacing.smMd) {
            Text("Step \(viewModel.step.rawValue + 1) of \(ListingEditorViewModel.Step.allCases.count): \(viewModel.step.title)")
                .vdFont(VdFont.bodySmall)
                .foregroundStyle(Color.vdContentDefaultSecondary)

            Form {
                switch viewModel.step {
                case .basics: basicsStep
                case .media: mediaStep
                case .pricing: pricingStep
                case .amenities: amenitiesStep
                case .rules: rulesStep
                case .preview:
                    ListingPreviewView(listing: viewModel.buildListing(status: .draft))
                }
            }
            .baseraListBackground()

            HStack(spacing: VdSpacing.sm) {
                VdButton(title: "Back", style: .secondary, isDisabled: viewModel.step == .basics) {
                    viewModel.goBack()
                }
                VdButton(title: viewModel.step == .preview ? (viewModel.isEditing ? "Save Changes" : "Save Draft") : "Next", style: .primary) {
                    if viewModel.step == .preview {
                        onSave(viewModel.buildListing(status: .draft))
                        dismiss()
                    } else {
                        viewModel.goNext()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, VdSpacing.sm)
        }
        .navigationTitle(viewModel.isEditing ? "Edit Listing" : "Create Listing")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var basicsStep: some View {
        Group {
            TextField("Title", text: $viewModel.form.title)
            TextField("Description", text: $viewModel.form.description, axis: .vertical)
            Picker("Property Type", selection: $viewModel.form.propertyType) {
                ForEach(Listing.PropertyType.allCases) { Text($0.rawValue).tag($0) }
            }
            Picker("Listing Scope", selection: $viewModel.form.listingScope) {
                ForEach(Listing.ListingScope.allCases) { Text($0.rawValue).tag($0) }
            }
            TextField("Exact Address", text: $viewModel.form.exactAddress)
            TextField("Public Approximate Location", text: $viewModel.form.approximateLocation)
            Stepper("Rooms: \(viewModel.form.rooms)", value: $viewModel.form.rooms, in: 1...20)
            Stepper("Floor: \(viewModel.form.floor)", value: $viewModel.form.floor, in: 0...20)
            DatePicker("Available From", selection: $viewModel.form.availableDate, displayedComponents: .date)
            Stepper("Minimum Stay: \(viewModel.form.minimumStayMonths) months", value: $viewModel.form.minimumStayMonths, in: 1...36)
        }
    }

    private var mediaStep: some View {
        Group {
            ForEach(viewModel.form.media) { media in
                HStack {
                    Label(media.title, systemImage: media.kind == .image ? "photo" : "video")
                    Spacer()
                    Text(media.uploadState == .placeholder ? "Placeholder" : "Ready")
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                    Button("Mock Upload") {
                        viewModel.markMediaReady(media.id)
                    }
                }
            }
        }
    }

    private var pricingStep: some View {
        Group {
            Stepper("Rent: NPR \(viewModel.form.monthlyRent)", value: $viewModel.form.monthlyRent, in: 5_000...250_000, step: 500)
            Stepper("Security Deposit: NPR \(viewModel.form.securityDeposit)", value: $viewModel.form.securityDeposit, in: 0...500_000, step: 1_000)
            Toggle("Electricity Included", isOn: $viewModel.form.includesElectricity)
            Toggle("Water Included", isOn: $viewModel.form.includesWater)
            Toggle("Internet Included", isOn: $viewModel.form.includesInternet)
        }
    }

    private var amenitiesStep: some View {
        Group {
            Toggle("Parking", isOn: $viewModel.form.hasParking)
            Toggle("Wi-Fi", isOn: $viewModel.form.hasWifi)
            Toggle("Pet Allowed", isOn: $viewModel.form.petAllowed)
            Picker("Preferred Tenant", selection: $viewModel.form.preferredTenantType) {
                ForEach(Listing.TenantPreference.allCases) { Text($0.rawValue).tag($0) }
            }
            Picker("Furnishing", selection: $viewModel.form.furnishing) {
                ForEach(Listing.Furnishing.allCases) { Text($0.rawValue).tag($0) }
            }
        }
    }

    private var rulesStep: some View {
        Group {
            Toggle("Smoking Allowed", isOn: $viewModel.form.smokingAllowed)
            Toggle("Visitors Allowed", isOn: $viewModel.form.visitorsAllowed)
            TextField("Quiet Hours", text: $viewModel.form.quietHours)
        }
    }
}

#Preview {
    NavigationView {
        ListingEditorView(ownerID: "preview-user-001") { _ in }
    }
}
