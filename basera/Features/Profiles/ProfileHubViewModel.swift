import Combine
import Foundation

@MainActor
final class ProfileHubViewModel: ObservableObject {
    @Published var selectedRole: UserRole
    @Published private(set) var profileBundle: UserProfileBundle = .init(renterProfile: nil, ownerProfile: nil)
    @Published private(set) var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let user: AppUser
    private let repository: ProfileRepositoryProtocol

    init(user: AppUser, repository: ProfileRepositoryProtocol) {
        self.user = user
        self.repository = repository
        self.selectedRole = user.activeRole
    }

    var availableRoles: [UserRole] {
        Array(user.availableRoles).sorted { $0.rawValue < $1.rawValue }
    }

    var renterProfile: RenterProfile {
        profileBundle.renterProfile ?? RenterProfile.empty.withDefaults(name: user.fullName, phone: user.phoneNumber)
    }

    var ownerProfile: OwnerProfile {
        profileBundle.ownerProfile ?? OwnerProfile.empty.withDefaults(name: user.fullName, phone: user.phoneNumber)
    }

    func completionStatus(for role: UserRole) -> ProfileCompletionStatus {
        profileBundle.completionStatus(for: role)
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            profileBundle = try await repository.fetchProfiles(for: user.id)
        } catch {
            errorMessage = "Unable to load profiles right now."
        }
    }

    func saveRenterProfile(_ profile: RenterProfile) async {
        isSaving = true
        defer { isSaving = false }

        do {
            try await repository.saveRenterProfile(profile, for: user.id)
            profileBundle.renterProfile = profile
            errorMessage = nil
        } catch {
            errorMessage = "Unable to save renter profile."
        }
    }

    func saveOwnerProfile(_ profile: OwnerProfile) async {
        isSaving = true
        defer { isSaving = false }

        do {
            try await repository.saveOwnerProfile(profile, for: user.id)
            profileBundle.ownerProfile = profile
            errorMessage = nil
        } catch {
            errorMessage = "Unable to save owner profile."
        }
    }
}

private extension RenterProfile {
    func withDefaults(name: String?, phone: String) -> RenterProfile {
        var copy = self
        if copy.fullName.isEmpty { copy.fullName = name ?? "" }
        if copy.phoneNumber.isEmpty { copy.phoneNumber = phone }
        return copy
    }
}

private extension OwnerProfile {
    func withDefaults(name: String?, phone: String) -> OwnerProfile {
        var copy = self
        if copy.fullName.isEmpty { copy.fullName = name ?? "" }
        if copy.phoneNumber.isEmpty { copy.phoneNumber = phone }
        return copy
    }
}
