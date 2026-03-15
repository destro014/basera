import SwiftUI

struct ProfileHubView: View {
    @StateObject private var viewModel: ProfileHubViewModel

    init(user: AppUser, repository: ProfileRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: ProfileHubViewModel(user: user, repository: repository))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                BaseraLoadingView(message: "Loading profiles...")
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.large) {
                        ProfileSectionView(
                            title: "Account role",
                            subtitle: "Your role is fixed for this account."
                        ) {
                            Text(viewModel.role.title)
                                .baseraTextStyle(AppTheme.Typography.titleMedium)
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        VStack(spacing: AppTheme.Spacing.medium) {
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
                    .baseraTextStyle(AppTheme.Typography.labelLarge)
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
                .baseraTextStyle(AppTheme.Typography.bodyMedium)
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
