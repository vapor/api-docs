// swift-tools-version:6.3
import PackageDescription

let package = Package(
    name: "APIDocs",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/brokenhandsio/kiln.git", from: "1.8.2"),
        // Shared Vapor design system — the same layer docs.vapor.codes uses, so
        // the API docs match visually (header/footer chrome, brand CSS, docs layout).
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
