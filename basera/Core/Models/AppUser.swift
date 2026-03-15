import Foundation

struct AppUser: Identifiable, Equatable {
    let id: String
    let fullName: String?
    let phoneNumber: String
    let email: String
    let role: UserRole
    let profilePhotoURL: URL?

    init(
        id: String,
        fullName: String?,
        phoneNumber: String,
        email: String = "",
        role: UserRole,
        profilePhotoURL: URL?
    ) {
        self.id = id
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.email = email
        self.role = role
        self.profilePhotoURL = profilePhotoURL
    }

    var displayName: String {
        guard let fullName, fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return "Basera Account"
        }

        return fullName
    }

}
