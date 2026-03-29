import SwiftUI
import VroxalDesign

@main
struct BaseraApp: App {
    
    @StateObject private var environment = AppEnvironment.bootstrap()

    init() {
        VdFont.register()
        applyVdNavigationBarAppearance()
        SupabaseConfigurationWarmup.seedCacheFromRuntimeIfAvailable()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(environment)
        }
    }
}


private func applyVdNavigationBarAppearance() {
    let titleAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Poppins-SemiBold", size: 17) ?? .systemFont(ofSize: 17, weight: .semibold)
    ]
    let largeTitleAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Poppins-SemiBold", size: 34) ?? .systemFont(ofSize: 34, weight: .semibold)
    ]

    let standardAppearance = UINavigationBarAppearance()
    standardAppearance.configureWithDefaultBackground()
    standardAppearance.titleTextAttributes = titleAttributes
    standardAppearance.largeTitleTextAttributes = largeTitleAttributes

    let scrollEdgeAppearance = UINavigationBarAppearance()
    scrollEdgeAppearance.configureWithTransparentBackground()
    scrollEdgeAppearance.titleTextAttributes = titleAttributes
    scrollEdgeAppearance.largeTitleTextAttributes = largeTitleAttributes

    let navigationBar = UINavigationBar.appearance()
    navigationBar.standardAppearance = standardAppearance
    navigationBar.compactAppearance = standardAppearance
    navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
}
