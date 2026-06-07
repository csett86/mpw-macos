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
            Text("Master Password macOS Credential Provider")
                .font(.title2)
                .bold()

            Text("This macOS app bundles a credential provider extension that provides the Master Password algorithm.")
                .fixedSize(horizontal: false, vertical: true)

            Text("Enable the credential provider from System Settings → General → Autofill & Password Options.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(minWidth: 480, minHeight: 220)
    }
}
#endif
