import Combine
import Foundation
import SwiftUI

@MainActor
final class AppRootViewModel: ObservableObject {
    struct BiometricPrompt: Identifiable {
        let id = UUID()
        let biometryDisplayName: String
    }

    @Published private(set) var route: AppRoute = .loading
    @Published private(set) var biometricPrompt: BiometricPrompt?
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    private var pendingBiometricCredentials: AuthCredentials?

    func load(environment: AppEnvironment) async {
        route = .loading

        do {
            let user = try await environment.authRepository.restoreSession()
            environment.currentUser = user
            if let user {
                route = .signedIn(user)
            } else {
                route = hasSeenOnboarding ? .signedOut(.login) : .onboarding
            }
        } catch {
            route = hasSeenOnboarding ? .signedOut(.login) : .onboarding
        }
    }

    func handleAuthenticatedUser(_ user: AppUser, credentials: AuthCredentials?, environment: AppEnvironment) {
        environment.currentUser = user
        route = .signedIn(user)

        guard let credentials else { return }

        let biometricManager = environment.biometricLoginManager
        guard biometricManager.isBiometryAvailable else { return }

        let normalizedEmail = normalized(email: credentials.email)
        if biometricManager.enrolledBiometricEmail == normalizedEmail {
            do {
                try biometricManager.enableBiometricLogin(with: credentials)
            } catch {
                biometricManager.disableBiometricLogin()
            }
            return
        }

        guard biometricManager.hasPromptedForEnrollment(for: normalizedEmail) == false else { return }

        pendingBiometricCredentials = credentials
        biometricPrompt = BiometricPrompt(biometryDisplayName: biometricManager.biometryDisplayName)
    }

    func enableBiometricLogin(environment: AppEnvironment) async {
        defer {
            pendingBiometricCredentials = nil
            biometricPrompt = nil
        }

        guard let pendingBiometricCredentials else {
            return
        }

        do {
            try await environment.biometricLoginManager.authenticateForEnrollment()
            try environment.biometricLoginManager.enableBiometricLogin(with: pendingBiometricCredentials)
        } catch {
            return
        }
    }

    func dismissBiometricPrompt(environment: AppEnvironment) {
        if let pendingBiometricCredentials {
            environment.biometricLoginManager.markEnrollmentPromptShown(for: pendingBiometricCredentials.email)
        }
        pendingBiometricCredentials = nil
        biometricPrompt = nil
    }

    func switchRole(_ role: UserRole, environment: AppEnvironment) {
        guard case .signedIn(let user) = route else { return }
        guard user.availableRoles.contains(role) else { return }

        let updated = user.updatingActiveRole(role)
        environment.currentUser = updated
        route = .signedIn(updated)
    }

    func signOut(environment: AppEnvironment) async {
        try? await environment.authRepository.signOut()
        environment.currentUser = nil
        route = hasSeenOnboarding ? .signedOut(.login) : .onboarding
    }

    func continueFromOnboarding(to entryPoint: AuthEntryPoint) {
        hasSeenOnboarding = true
        route = .signedOut(entryPoint)
    }

    private func normalized(email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
