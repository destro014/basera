import Foundation

enum AuthEntryPoint {
    case login
    case registration
}

enum AppRoute {
    case loading
    case onboarding
    case signedOut(AuthEntryPoint)
    case signedIn(AppUser)
}
