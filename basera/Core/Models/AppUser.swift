import Foundation

struct AppUser: Identifiable, Equatable {
    let id: String
    let fullName: String?
    let phoneNumber: String
    let availableRoles: Set<UserRole>
    let activeRole: UserRole
    let profilePhotoURL: URL?

    var displayName: String {
        guard let fullName, fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return "Basera Account"
        }

        return fullName
    }

    var canSwitchRoles: Bool {
        availableRoles.count > 1
    }

    func updatingActiveRole(_ role: UserRole) -> AppUser {
        AppUser(
            id: id,
            fullName: fullName,
            phoneNumber: phoneNumber,
            availableRoles: availableRoles,
            activeRole: role,
            profilePhotoURL: profilePhotoURL
        )
    }
}
