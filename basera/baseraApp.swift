import SwiftUI
import VroxalDesign

@main
struct BaseraApp: App {
    
    @StateObject private var environment = AppEnvironment.bootstrap()

    init() {
        VdFont.register()

        BaseraFontRegistrar.registerIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(environment)
        }
    }
}
