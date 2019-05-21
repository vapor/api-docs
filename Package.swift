// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "api-docs",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .branch("master")),
    ],
    targets: [
        .target(name: "Run", dependencies: ["Vapor"]),
    ]
)
