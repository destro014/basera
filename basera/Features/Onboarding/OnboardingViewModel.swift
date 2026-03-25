import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    struct Slide: Identifiable, Equatable {
        let id: String
        let title: String
        let message: String
        let imageAssetName: String
    }

    static let slideDuration: TimeInterval = 4
    static let timerStep: TimeInterval = 0.05

    @Published private(set) var slides: [Slide] = [
        Slide(
            id: "find-home",
            title: "Find Your Next Home",
            message: "Browse verified listings across Nepal. Filter by location, price, and room type to find your perfect fit.",
            imageAssetName: "onboarding-slide-1"
        ),
        Slide(
            id: "list-fast",
            title: "List in a Few Minutes",
            message: "Publish your property quickly. Set availability, price, and house rules to attract serious renters.",
            imageAssetName: "onboarding-slide-2"
        ),
        Slide(
            id: "connect-direct",
            title: "Connect Without Agents",
            message: "Send interest requests directly to owners. No middlemen, no commissions, just straightforward renting.",
            imageAssetName: "onboarding-slide-3"
        ),
        Slide(
            id: "track-records",
            title: "Track Rent and Payments",
            message: "Sign agreements digitally and monitor every payment — all your rental records in one place.",
            imageAssetName: "onboarding-slide-4"
        )
    ]

    @Published private(set) var currentIndex = 0
    @Published private(set) var currentProgress: Double = 0

    private var elapsed: TimeInterval = 0
    private var isPlaybackActive = true

    var progressValues: [Double] {
        slides.indices.map { index in
            if index < currentIndex {
                return 1
            }

            if index == currentIndex {
                return currentProgress
            }

            return 0
        }
    }

    func tick() {
        guard isPlaybackActive else { return }
        guard slides.isEmpty == false else { return }

        if currentIndex == slides.count - 1, currentProgress >= 1 {
            return
        }

        elapsed += Self.timerStep

        if elapsed >= Self.slideDuration {
            if currentIndex < slides.count - 1 {
                currentIndex += 1
                elapsed = 0
                currentProgress = 0
            } else {
                elapsed = Self.slideDuration
                currentProgress = 1
            }
            return
        }

        currentProgress = min(elapsed / Self.slideDuration, 0.999)
    }

    func selectSlide(_ index: Int) {
        guard slides.indices.contains(index) else { return }
        guard index != currentIndex else { return }

        currentIndex = index
        elapsed = 0
        currentProgress = 0
    }

    func setPlaybackActive(_ isActive: Bool) {
        isPlaybackActive = isActive
    }
}
