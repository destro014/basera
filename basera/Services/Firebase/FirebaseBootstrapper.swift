import Foundation

#if canImport(FirebaseCore)
import FirebaseCore
#endif

enum FirebaseBootstrapper {
    static func configureIfNeeded() {
        #if canImport(FirebaseCore)
        guard AppRuntimeConfiguration.useFirebaseInfrastructure else { return }
        guard FirebaseApp.app() == nil else { return }
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            #if DEBUG
            print("[Basera] Skipping Firebase configuration because GoogleService-Info.plist is missing.")
            #endif
            return
        }
        FirebaseApp.configure()

        if AppRuntimeConfiguration.shouldEnableFirebaseDebugLogs {
            // TODO: Add Firebase logger tuning once observability baseline is finalized.
            print("[Basera] Firebase configured with debug logs enabled.")
        }
        #endif
    }
}
