import Foundation

@MainActor
final class AppRootViewModel: ObservableObject {
    @Published private(set) var route: AppRoute = .loading

    func load(environment: AppEnvironment) async {
        route = .loading

        do {
            let user = try await environment.authRepository.restoreSession()
            environment.currentUser = user
            if let user {
                route = .signedIn(user)
            } else {
                route = .signedOut
            }
        } catch {
            route = .signedOut
        }
    }

    func signInPreviewUser(role: UserRole, environment: AppEnvironment) async {
        do {
            let user = try await environment.authRepository.signInPreviewUser(activeRole: role)
            environment.currentUser = user
            route = .signedIn(user)
        } catch {
            route = .signedOut
        }
    }

    func switchRole(_ role: UserRole) {
        guard case .signedIn(let user) = route else { return }
        guard user.availableRoles.contains(role) else { return }

        let updated = user.updatingActiveRole(role)
        route = .signedIn(updated)
    }

    func signOut(environment: AppEnvironment) async {
        try? await environment.authRepository.signOut()
        environment.currentUser = nil
        route = .signedOut
    }
}
