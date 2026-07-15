// swift-tools-version:6.3
import PackageDescription

let package = Package(
    name: "APIDocs",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // TEMPORARY local override to validate the topic-fragment / sidebar-home
        // features; revert to github/brokenhandsio once released.
        .package(path: "../../BrokenHands/kiln"),
        .package(url: "https://github.com/vapor/design.git", from: "1.0.0-rc.1"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "APIDocs",
            dependencies: [
                .product(name: "Kiln", package: "kiln"),
                .product(name: "VaporDesignTheme", package: "design"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
