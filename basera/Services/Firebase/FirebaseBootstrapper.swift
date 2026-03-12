import Foundation

#if canImport(FirebaseCore)
import FirebaseCore
#endif

enum FirebaseBootstrapper {
    static func configureIfNeeded() {
        #if canImport(FirebaseCore)
        guard FirebaseApp.app() == nil else { return }
        FirebaseApp.configure()

        if AppRuntimeConfiguration.shouldEnableFirebaseDebugLogs {
            // TODO: Add Firebase logger tuning once observability baseline is finalized.
            print("[Basera] Firebase configured with debug logs enabled.")
        }
        #endif
    }
}
