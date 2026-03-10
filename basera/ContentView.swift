import SwiftUI

struct ContentView: View {
    var body: some View {
        AppRootView()
            .environmentObject(AppEnvironment.bootstrap())
    }
}

#Preview {
    ContentView()
}
