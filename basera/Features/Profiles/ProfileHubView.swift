import SwiftUI
import VroxalDesign

struct ProfileHubView: View {
    @StateObject private var viewModel: ProfileHubViewModel

    init(user: AppUser, repository: ProfileRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: ProfileHubViewModel(user: user, repository: repository))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                VdLoadingState(title: "Loading profiles...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                    VStack(spacing: VdSpacing.md) {
                        ProfileSectionView(
                            title: "Account role",
                            subtitle: "Your role is fixed for this account."
                        ) {
                            Text(viewModel.role.title)
                                .vdFont(VdFont.titleMedium)
                                .foregroundStyle(Color.vdContentDefaultBase)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        VStack(spacing: VdSpacing.smMd) {
                            ProfileCompletionStatusView(status: viewModel.completionStatus(for: viewModel.role))
                        }

                        if viewModel.role == .renter {
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
            Button(role: .cancel) {} label: {
                Text("OK")
                    .vdFont(VdFont.labelLarge)
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
                .vdFont(VdFont.bodyMedium)
        }
    }
}

#Preview {
    NavigationView {
        ProfileHubView(
            user: PreviewData.user(role: .owner),
            repository: MockProfileRepository()
        )
    }
    .navigationViewStyle(StackNavigationViewStyle())
}
