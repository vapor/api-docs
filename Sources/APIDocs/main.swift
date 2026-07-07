import Kiln
import VaporDesignTheme

let site = KilnSite(
    name: "Vapor API Docs",
    url: "https://api.vapor.codes",
    author: "Vapor Community",
    description: "API reference documentation for Vapor and its ecosystem (web framework for Swift).",
    image: "assets/api-og-2x.png",
    twitterSite: "@codevapor",
    repository: .init(
        name: "Vapor GitHub",
        url: "https://github.com/vapor/vapor"
    ),
    copyright: "API Documentation © 2026 Vapor.",
    theme: .default(
        sharedLayers: [VaporDesignTheme.directory],
        palette: .autoLightDark(primary: .black, accent: .blue),
        logo: "assets/logo.png",
        favicon: "assets/favicon.png",
        fonts: Fonts(text: "Roboto", code: "Roboto Mono")
    ),
    social: [
        .init(icon: .github, link: "https://github.com/vapor"),
        .init(icon: .discord, link: "https://discord.gg/vapor"),
        .init(icon: .twitter, link: "https://twitter.com/codevapor"),
        .init(icon: .mastodon, link: "https://hachyderm.io/@codevapor"),
    ],
    languages: languages,
    docc: DocCSite(
        packages: [
            APIPackage("vapor/jwt", group: "Authentication",
                       modules: [Module("JWT", description: "JWT signing and verification for Vapor.")],
                       versions: [PackageVersion("default", name: "5.1.2", ref: "main", isDefault: true)]),
            APIPackage("vapor/jwt-kit", group: "Authentication",
                       modules: [Module("JWTKit", description: "JSON Web Token signing and verification.")],
                       versions: [PackageVersion("default", name: "5.6.0", ref: "main", isDefault: true)]),
            APIPackage("vapor/apns", group: "Push Notifications",
                       modules: [Module("VaporAPNS", title: "APNS", description: "Apple Push Notification Service for Vapor.")],
                       versions: [PackageVersion("default", name: "4.0.0-beta.2", ref: "main", isDefault: true)]),
            APIPackage("vapor/fluent", group: "Database",
                       modules: [Module("Fluent", description: "Vapor's ORM integration.")],
                       versions: [PackageVersion("default", name: "4.12.0", ref: "main", isDefault: true)]),
            APIPackage("vapor/fluent-kit", group: "Database",
                       modules: [Module("FluentKit", description: "Vapor's type-safe, Swift-first ORM.")],
                       versions: [PackageVersion("default", name: "1.52.2", ref: "main", isDefault: true)]),
            APIPackage("vapor/postgres-nio", group: "Database",
                       modules: [Module("PostgresNIO", description: "Non-blocking PostgreSQL client built on SwiftNIO.")],
                       versions: [PackageVersion("default", name: "1.23.0", ref: "main", isDefault: true)]),
            APIPackage("vapor/routing-kit", group: "Core",
                       modules: [Module("RoutingKit", description: "High-performance routing engine for HTTP requests.")],
                       versions: [
                           PackageVersion("4", name: "4.x", ref: "v4", isDefault: true),
                           PackageVersion("5-beta", name: "5.0 (beta)", ref: "main", isPrerelease: true),
                       ]),
            APIPackage("vapor/queues", group: "Queues",
                       modules: [
                           Module("Queues", description: "A queuing system for Vapor that offloads work to background workers."),
                           Module("XCTQueues", group: "Testing", description: "Testing helpers for Vapor's Queues."),
                       ],
                       versions: [PackageVersion("default", name: "1.18.0", ref: "main", isDefault: true)]),
        ],
        groupOrder: ["Core", "Authentication", "Database", "Queues", "Push Notifications", "Templating", "Testing"]
    )
)

let contentDirectory = "Content"
let outputDirectory = "site"

// Which DocC archives to (re)generate this run:
//   (no flag)              → build only missing archives (fast once populated)
//   --rebuild <Module> …   → force-rebuild the named module(s), reuse the rest
//   --rebuild-all          → rebuild every archive from scratch
// CI restores cached archives (from S3) before the run, then passes the flag for
// whichever package changed; everything else is served from the restored cache.
let arguments = Array(CommandLine.arguments.dropFirst())
let rebuild: DocCArchiveBuilder.Rebuild
if arguments.contains("--rebuild-all") {
    rebuild = .all
} else {
    var modules = Set<String>()
    var iterator = arguments.makeIterator()
    while let argument = iterator.next() {
        if argument == "--rebuild", let module = iterator.next() { modules.insert(module.lowercased()) }
    }
    rebuild = modules.isEmpty ? .missing : .modules(modules)
}

print("Ensuring DocC archives …")
try Kiln.buildDocCArchives(site, contentDirectory: contentDirectory, rebuild: rebuild)

print("Building Vapor API docs into ./\(outputDirectory) …")
try await Kiln.build(site, contentDirectory: contentDirectory, outputDirectory: outputDirectory, incremental: true)
print("Done. Serve it with:  kiln serve")
