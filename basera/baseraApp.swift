import SwiftUI

@main
struct BaseraApp: App {
    @StateObject private var environment = AppEnvironment.bootstrap()

    init() {
        BaseraFontRegistrar.registerIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(environment)
        }
    }
}
