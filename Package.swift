// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SpectreCore",
    platforms: [
        .macOS(.v14)
        .iOS(.v13)
    ],
    products: [
        .library(name: "SpectreCore", targets: ["SpectreCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0" ..< "5.0.0")
    ],
    targets: [
        .target(
            name: "SpectreCore",
            dependencies: [
                .product(name: "CryptoExtras", package: "swift-crypto")
            ],
            path: "CredentialProviderExtension",
            exclude: [
                "CredentialProviderExtension.entitlements",
                "CredentialProviderViewController.swift",
                "Info.plist"
            ],
            sources: [
                "SpectreAlgorithm.swift",
                "SpectreTemplates.swift"
            ]
        ),
        .testTarget(
            name: "SpectreCoreTests",
            dependencies: ["SpectreCore"],
            path: "Tests/SpectreCoreTests"
        )
    ]
)
