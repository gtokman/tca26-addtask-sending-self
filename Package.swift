// swift-tools-version: 6.3
import PackageDescription

// Swift 6 language mode, nothing else: no upcoming features. Turning on
// `NonisolatedNonsendingByDefault` (part of Xcode 26's "approachable concurrency") makes the
// error go away — see the README.
let package = Package(
    name: "Repro",
    platforms: [.iOS(.v18), .macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/TCA26", branch: "main"),
    ],
    targets: [
        .target(name: "Repro", dependencies: [.product(name: "ComposableArchitecture2", package: "TCA26")]),
    ]
)
