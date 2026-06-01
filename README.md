# mpw-macos

Basic macOS sample app with a bundled AuthenticationServices credential provider extension.

## Project contents

- `mpw-macos` macOS host app target
- `CredentialProviderExtension` app extension target that returns a demo credential
- Required `Info.plist` and entitlement files for the AutoFill credential provider capability

## Open in Xcode

Open `mpw-macos.xcodeproj` in Xcode 16 or newer and build the `mpw-macos` scheme on macOS.

After installing the app, enable the bundled credential provider from **System Settings → Passwords** (or the relevant AutoFill settings on your macOS version).
