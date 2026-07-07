import ArgumentParser
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

@main
struct APIDocs: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "api-docs",
        abstract: "Build the Vapor API reference site (api.vapor.codes) from DocC archives.",
        discussion: """
        Generates any DocC archives that aren't already present (checking each \
        package out at its ref and running `swift package generate-documentation`), \
        then renders the whole site. In CI, restore the archive cache first, pass \
        --rebuild for the package that changed, and the rest is served from cache.
        """
    )

    @Option(
        name: .customLong("rebuild"),
        help: ArgumentHelp(
            "Force-rebuild the DocC archive for this module, reusing the rest.",
            discussion: "Repeatable, e.g. --rebuild JWTKit --rebuild Fluent."
        )
    )
    var rebuildModules: [String] = []

    @Flag(name: .customLong("rebuild-all"), help: "Rebuild every DocC archive from scratch.")
    var rebuildAll = false

    @Option(help: "The content directory (DocC archives live under <content>/archives).")
    var content = "Content"

    @Option(help: "The output directory (the `kiln serve` default).")
    var output = "site"

    func run() async throws {
        let rebuild: DocCArchiveBuilder.Rebuild
        if rebuildAll {
            rebuild = .all
        } else if !rebuildModules.isEmpty {
            rebuild = .modules(Set(rebuildModules.map { $0.lowercased() }))
        } else {
            rebuild = .missing
        }

        print("Ensuring DocC archives …")
        try Kiln.buildDocCArchives(site, contentDirectory: content, rebuild: rebuild)

        print("Building Vapor API docs into ./\(output) …")
        try await Kiln.build(site, contentDirectory: content, outputDirectory: output, incremental: true)
        print("Done. Serve it with:  kiln serve")
    }
}
