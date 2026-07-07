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
        packages: packages,
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
