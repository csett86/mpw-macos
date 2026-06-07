# Master Password in Swift

The Master Password algorithm as AuthenticationServices credential provider extension for macOS and iOS, implemented in pure Swift.

## Project contents

- `mpw-swift` macOS host app target
- `mpw-ios` iOS host app target
- `CredentialProviderExtension` app extension target shared by both host apps

## Open in Xcode

Open `mpw-swift.xcodeproj` in Xcode 16 or newer and build either `mpw-swift` (macOS) or `mpw-ios` (iOS).

After installing the app, enable the bundled credential provider from:
- macOS: **System Settings → General -> Autofill & Passwords**
- iOS: **Settings → General → Autofill & Passwords**
