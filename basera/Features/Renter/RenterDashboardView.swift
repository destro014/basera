import SwiftUI

struct RenterDashboardView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = RenterDashboardViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    BaseraLoadingView(message: "Loading listings")
                } else if viewModel.listings.isEmpty {
                    BaseraEmptyStateView(
                        title: "No listings",
                        message: "Basera will show available rentals here."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppTheme.Spacing.medium) {
                            ForEach(viewModel.listings) { listing in
                                BaseraCard {
                                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                                        Text(listing.title)
                                            .font(AppTheme.Typography.subtitle)
                                        Text(listing.approximateLocation)
                                            .foregroundStyle(AppTheme.Colors.textSecondary)
                                        BaseraChip(text: "Rs. \(listing.monthlyRent)/month")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Basera Explore")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .task {
            await viewModel.load(using: environment.listingsRepository)
        }
    }
}

#Preview {
    RenterDashboardView()
        .environmentObject(AppEnvironment.bootstrap())
}
