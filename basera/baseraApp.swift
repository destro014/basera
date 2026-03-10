import SwiftUI

@main
struct BaseraApp: App {
    @StateObject private var environment = AppEnvironment.bootstrap()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(environment)
        }
    }
}
