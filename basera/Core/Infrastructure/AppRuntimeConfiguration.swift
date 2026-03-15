import Foundation

enum AppRuntimeConfiguration {
    static var useMockInfrastructure: Bool {
        ProcessInfo.processInfo.environment["BASERA_USE_MOCK_SERVICES"] == "1"
    }

    static var shouldEnableSupabaseDebugLogs: Bool {
        ProcessInfo.processInfo.environment["BASERA_SUPABASE_DEBUG"] == "1"
    }
}
