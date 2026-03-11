import Foundation

struct MockAuthRepository: AuthRepositoryProtocol {
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func restoreSession() async throws -> AppUser? {
        guard let id = try await authService.currentUserID() else { return nil }
        return PreviewData.user(id: id, activeRole: .renter)
    }

    func signInPreviewUser(activeRole: UserRole) async throws -> AppUser {
        let id = try await authService.signInPreviewUser()
        return PreviewData.user(id: id, activeRole: activeRole)
    }

    func signOut() async throws {
        try await authService.signOut()
    }
}

struct MockListingsRepository: ListingsRepositoryProtocol {
    func fetchFeaturedListings() async throws -> [Listing] {
        PreviewData.featuredListings
    }
}
