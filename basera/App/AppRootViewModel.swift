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

    private var pendingBiometricCredentials: AuthCredentials?

    func load(environment: AppEnvironment) async {
        route = .loading

        do {
            let user = try await environment.authRepository.restoreSession()
            environment.currentUser = user
            if let user {
                route = .signedIn(user)
            } else {
                route = .onboarding
            }
        } catch {
            route = .onboarding
        }
    }

    func handleAuthenticatedUser(_ user: AppUser, credentials: AuthCredentials?, environment: AppEnvironment) {
        environment.currentUser = user
        biometricPrompt = nil
        pendingBiometricCredentials = nil

        if let credentials {
            let biometricManager = environment.biometricLoginManager

            if biometricManager.isBiometryAvailable {
                let normalizedEmail = normalized(email: credentials.email)
                if biometricManager.enrolledBiometricEmail == normalizedEmail {
                    do {
                        try biometricManager.enableBiometricLogin(with: credentials)
                    } catch {
                        biometricManager.disableBiometricLogin()
                    }
                } else if biometricManager.hasPromptedForEnrollment(for: normalizedEmail) == false {
                    pendingBiometricCredentials = credentials
                    biometricPrompt = BiometricPrompt(biometryDisplayName: biometricManager.biometryDisplayName)
                }
            }
        }

        route = .signedIn(user)
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

    func signOut(environment: AppEnvironment) async {
        try? await environment.authRepository.signOut()
        environment.currentUser = nil
        route = .onboarding
    }

    func continueFromOnboarding(to entryPoint: AuthEntryPoint) {
        route = .signedOut(entryPoint)
    }

    private func normalized(email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
