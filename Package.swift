// swift-tools-version:6.3
import PackageDescription

let package = Package(
    name: "APIDocs",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/brokenhandsio/kiln.git", from: "1.7.0"),
        // Shared Vapor design system (header/footer chrome, brand CSS, and the
        // shared docs layout), the same layer docs.vapor.codes uses — so the API
        // docs match visually. TEMPORARY local override while the `#designResource`
        // local-asset changes are validated; revert to github/main once published.
        .package(path: "../design"),
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
