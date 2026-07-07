// swift-tools-version:6.3
import PackageDescription

let package = Package(
    name: "APIDocs",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // Local Kiln checkout on the `docc-support` branch, for the new DocC
        // API-reference rendering. Switch to a released version once these land.
        .package(path: "../../BrokenHands/kiln"),
        // Shared Vapor design system (header/footer chrome, brand CSS, and now the
        // shared docs layout: base.leaf, theme.css, docc.css, docs.js), the same
        // layer docs.vapor.codes uses — so the API docs match visually.
        // TEMPORARY local override for the shared-theme migration; revert to the
        // github/main dependency once the design package is published.
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
