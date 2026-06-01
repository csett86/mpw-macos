#if canImport(SwiftUI)
import SwiftUI

@main
struct MPWMacOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}

private struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MPW macOS Credential Provider")
                .font(.title2)
                .bold()

            Text("This sample app embeds a credential provider extension that can be enabled from System Settings.")
                .fixedSize(horizontal: false, vertical: true)

            Text("The bundled extension returns demo credentials so the project can serve as a basic starting point.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(minWidth: 480, minHeight: 220)
    }
}
#endif
