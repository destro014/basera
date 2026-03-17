import SwiftUI

struct ContentView: View {
    var body: some View {
//        VdPreviewApp()
        AppRootView()
    }
}

#Preview {
    ContentView()
        .environmentObject(AppEnvironment.bootstrap())
}
