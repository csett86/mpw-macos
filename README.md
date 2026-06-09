# Master Password in Swift

The Master Password algorithm as AuthenticationServices credential provider extension for macOS and iOS, implemented in pure Swift.

The awesome [Master Password algorithm](https://spectre.app/spectre-algorithm.pdf) was created by Maarten Billemont under GPLv3, this would not be possible without! See more of him at https://spectre.app/

## Download

Download the latest release for macOS: [Master Password.app.zip](https://github.com/csett86/mpw-swift/releases/latest/download/Master.Password.app.zip)

## Project contents

- `mpw-swift` macOS host app target
- `mpw-ios` iOS host app target
- `CredentialProviderExtension` app extension target shared by both host apps

## Open in Xcode

Open `mpw-swift.xcodeproj` in Xcode 16 or newer and build either `mpw-swift` (macOS) or `mpw-ios` (iOS).

After installing the app, enable the bundled credential provider from:
- macOS: **System Settings → General -> Autofill & Passwords**
- iOS: **Settings → General → Autofill & Passwords**
