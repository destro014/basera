import SwiftUI
import VroxalDesign

struct ContentView: View {
    public var body: some View {
       

        AppRootView()
            .baseraScreenBackground()
        
    }
}

#Preview {
    ContentView()
        .environmentObject(AppEnvironment.bootstrap())
}

#Preview("Onboarding") {
    OnboardingView(
        notice: nil,
        onLogin: {},
        onRegister: {},
        isPreviewMode: false
    )
}
