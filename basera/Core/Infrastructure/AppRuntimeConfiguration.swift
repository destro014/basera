import Foundation

enum AppRuntimeConfiguration {
    static var useFirebaseInfrastructure: Bool {
        ProcessInfo.processInfo.environment["BASERA_USE_FIREBASE"] == "1"
    }

    static var shouldEnableFirebaseDebugLogs: Bool {
        ProcessInfo.processInfo.environment["BASERA_FIREBASE_DEBUG"] == "1"
    }
}
