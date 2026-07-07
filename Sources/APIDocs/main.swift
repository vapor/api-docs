import Kiln
import VaporDesignTheme

// api.vapor.codes — the Vapor ecosystem's API reference, rendered from DocC
// archives by Kiln's DocC support. This first cut hosts the Queues package
// (its `Queues` and `XCTQueues` modules); more packages are added to
// `DocCSite.packages` as their archives are produced.
//
// The look mirrors docs.vapor.codes: the shared Vapor design system provides the
// header/footer chrome and brand CSS, a thin local Theme/ layer adds the docs
// layout (sidebar/TOC/article), and Theme/css/docc.css styles the API-reference
// specifics (declarations, symbol cards, relationships).
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
    // The whole docs layout (base.leaf, theme.css, docc.css, docs.js) now lives in
    // the shared VaporDesignTheme package, so there's no local Theme/ override —
    // just the bundled Kiln default plus the shared design layer.
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
    // The docs layout layer (`/_kiln/css/theme.css`) then the DocC-reference
    // styles (`/_kiln/css/docc.css`), both loaded after the shared design CSS.
    extraCSS: ["_kiln/css/theme.css", "_kiln/css/docc.css"],
    languages: languages,
    docc: DocCSite(
        // Every package builds from `main`; the version name is its latest GitHub
        // release, ready for the (upcoming) version switcher.
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
            // Two versions, to exercise the version switcher: v4 (stable, the
            // default served at the module root) and v5 beta (from main).
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
        // Catalog + switcher section order (concern-based; testing helpers last).
        groupOrder: ["Core", "Authentication", "Database", "Queues", "Push Notifications", "Templating", "Testing"]
    )
)

let contentDirectory = "Content"
// `site` is the `kiln` CLI's default output directory, so `kiln serve` builds and
// previews this project with no extra flags.
let outputDirectory = "site"

print("Building Vapor API docs into ./\(outputDirectory) …")
// Incremental: reuse the previous output for modules whose archives are
// unchanged (a fresh checkout has no manifest, so CI still does a full build).
try await Kiln.build(site, contentDirectory: contentDirectory, outputDirectory: outputDirectory, incremental: true)
print("Done. Serve it with:  kiln serve")
