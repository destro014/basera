import Foundation

enum AppRoute {
    case loading
    case signedOut
    case signedIn(AppUser)
}
