import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = AppRootViewModel()

    var body: some View {
        Group {
            switch viewModel.route {
            case .loading:
                BaseraLoadingView(message: "Preparing Basera...")
            case .signedOut:
                AuthFlowView(
                    authRepository: environment.authRepository,
                    onAuthenticated: { user in
                        viewModel.handleAuthenticatedUser(user, environment: environment)
                    }
                )
            case .signedIn(let user):
                HomeShellView(
                    user: user,
                    onSwitchRole: { role in
                        viewModel.switchRole(role, environment: environment)
                    },
                    onSignOut: {
                        Task {
                            await viewModel.signOut(environment: environment)
                        }
                    }
                )
            }
        }
        .task {
            await viewModel.load(environment: environment)
        }
    }
}

#Preview {
    AppRootView()
        .environmentObject(AppEnvironment.bootstrap())
}
