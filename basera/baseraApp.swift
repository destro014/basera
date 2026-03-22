import SwiftUI
import VroxalDesign

@main
struct BaseraApp: App {
    
    @StateObject private var environment = AppEnvironment.bootstrap()

    init() {
        VdFont.register()
        SupabaseConfigurationWarmup.seedCacheFromRuntimeIfAvailable()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(environment)
        }
    }
}
