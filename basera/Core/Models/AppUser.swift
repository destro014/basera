import Foundation

struct AppUser: Identifiable, Equatable {
    let id: String
    let fullName: String?
    let phoneNumber: String
    let email: String
    let availableRoles: Set<UserRole>
    let activeRole: UserRole
    let profilePhotoURL: URL?

    init(
        id: String,
        fullName: String?,
        phoneNumber: String,
        email: String = "",
        availableRoles: Set<UserRole>,
        activeRole: UserRole,
        profilePhotoURL: URL?
    ) {
        self.id = id
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.email = email
        self.availableRoles = availableRoles
        self.activeRole = activeRole
        self.profilePhotoURL = profilePhotoURL
    }

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
            email: email,
            availableRoles: availableRoles,
            activeRole: role,
            profilePhotoURL: profilePhotoURL
        )
    }
}
