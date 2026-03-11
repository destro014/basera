import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = AppRootViewModel()

    var body: some View {
        Group {
            switch viewModel.route {
            case .loading:
                BasraLoadingView(message: "Preparing Basra...")
            case .signedOut:
                AuthWelcomeView(
                    onContinue: { role in
                        Task {
                            await viewModel.signInPreviewUser(role: role, environment: environment)
                        }
                    }
                )
            case .signedIn(let user):
                HomeShellView(
                    user: user,
                    onSwitchRole: { role in
                        viewModel.switchRole(role)
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
