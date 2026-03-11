import Foundation

@MainActor
final class HomeShellViewModel: ObservableObject {
    @Published var user: AppUser

    init(user: AppUser) {
        self.user = user
    }

    func switchRole(_ role: UserRole) {
        guard user.availableRoles.contains(role) else { return }
        user = user.updatingActiveRole(role)
    }
}
