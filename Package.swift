// swift-tools-version:6.2
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
        // Shared Vapor design system (header/footer chrome, brand CSS), the same
        // layer docs.vapor.codes uses — so the API docs match visually.
        .package(url: "https://github.com/vapor/design.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "APIDocs",
            dependencies: [
                .product(name: "Kiln", package: "kiln"),
                .product(name: "VaporDesignTheme", package: "design"),
            ]
        ),
    ]
)
