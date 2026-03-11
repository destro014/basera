import SwiftUI

struct ProfileHubView: View {
    @StateObject private var viewModel: ProfileHubViewModel
    let onSwitchRole: (UserRole) -> Void

    init(user: AppUser, repository: ProfileRepositoryProtocol, onSwitchRole: @escaping (UserRole) -> Void) {
        _viewModel = StateObject(wrappedValue: ProfileHubViewModel(user: user, repository: repository))
        self.onSwitchRole = onSwitchRole
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                BaseraLoadingView(message: "Loading profiles...")
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.large) {
                        ProfileSectionView(
                            title: "Active role",
                            subtitle: "One account can hold renter and owner profiles."
                        ) {
                            Picker("Role", selection: $viewModel.selectedRole) {
                                ForEach(viewModel.availableRoles, id: \.self) { role in
                                    Text(role.title).tag(role)
                                }
                            }
                            .pickerStyle(.segmented)

                            BaseraButton(title: "Switch to \(viewModel.selectedRole.title)", style: .secondary) {
                                onSwitchRole(viewModel.selectedRole)
                            }
                        }

                        VStack(spacing: AppTheme.Spacing.medium) {
                            ForEach(viewModel.availableRoles, id: \.self) { role in
                                ProfileCompletionStatusView(status: viewModel.completionStatus(for: role))
                            }
                        }

                        if viewModel.selectedRole == .renter {
                            RenterProfileFormView(profile: viewModel.renterProfile, isSaving: viewModel.isSaving) { profile in
                                Task { await viewModel.saveRenterProfile(profile) }
                            }
                        } else {
                            OwnerProfileFormView(profile: viewModel.ownerProfile, isSaving: viewModel.isSaving) { profile in
                                Task { await viewModel.saveOwnerProfile(profile) }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Profile Setup")
        .task { await viewModel.load() }
        .alert("Profile Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    NavigationStack {
        ProfileHubView(
            user: PreviewData.user(activeRole: .owner),
            repository: MockProfileRepository(),
            onSwitchRole: { _ in }
        )
    }
}
