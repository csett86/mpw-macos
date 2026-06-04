import SwiftUI

@main
struct MPWiOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

private struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MPW iOS Credential Provider")
                .font(.title2)
                .bold()

            Text("This sample iOS app bundles the credential provider extension shared with the macOS host app.")
                .fixedSize(horizontal: false, vertical: true)

            Text("Install and enable the credential provider from iOS Settings → Passwords → Password Options.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
    }
}
