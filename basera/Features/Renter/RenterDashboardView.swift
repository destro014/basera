import SwiftUI

struct RenterDashboardView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = RenterDashboardViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    BasraLoadingView(message: "Loading listings")
                } else if viewModel.listings.isEmpty {
                    BasraEmptyStateView(
                        title: "No listings",
                        message: "Basra will show available rentals here."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppTheme.Spacing.medium) {
                            ForEach(viewModel.listings) { listing in
                                BasraCard {
                                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                                        Text(listing.title)
                                            .font(AppTheme.Typography.subtitle)
                                        Text(listing.approximateLocation)
                                            .foregroundStyle(AppTheme.Colors.textSecondary)
                                        BasraChip(text: "Rs. \(listing.monthlyRent)/month")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Basra Explore")
        }
        .task {
            await viewModel.load(using: environment.listingsRepository)
        }
    }
}

#Preview {
    RenterDashboardView()
        .environmentObject(AppEnvironment.bootstrap())
}
