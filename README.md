# mpw-macos

Basic Apple platform sample apps with a bundled AuthenticationServices credential provider extension.

## Project contents

- `mpw-macos` macOS host app target
- `mpw-ios` iOS host app target
- `CredentialProviderExtension` app extension target shared by both host apps
- Required `Info.plist` and entitlement files for the AutoFill credential provider capability

## Open in Xcode

Open `mpw-macos.xcodeproj` in Xcode 16 or newer and build either `mpw-macos` (macOS) or `mpw-ios` (iOS).

After installing the app, enable the bundled credential provider from:
- macOS: **System Settings → Passwords**
- iOS: **Settings → Passwords → Password Options**
