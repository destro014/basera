import Foundation

struct AppUser: Identifiable, Equatable {
    let id: String
    let fullName: String
    let phoneNumber: String
    let availableRoles: Set<UserRole>
    let activeRole: UserRole

    var canSwitchRoles: Bool {
        availableRoles.count > 1
    }

    func updatingActiveRole(_ role: UserRole) -> AppUser {
        AppUser(
            id: id,
            fullName: fullName,
            phoneNumber: phoneNumber,
            availableRoles: availableRoles,
            activeRole: role
        )
    }
}
