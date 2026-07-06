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
    image: "assets/social-card.png",
    twitterSite: "@codevapor",
    repository: .init(
        name: "Vapor GitHub",
        url: "https://github.com/vapor/vapor"
    ),
    copyright: "API Documentation © 2026 Vapor.",
    theme: .custom(
        directory: "Theme",
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
        packages: [
            APIPackage("vapor/queues", ref: "main", group: "Queues", modules: [
                Module("Queues", description: "A queuing system for Vapor that offloads work to background workers."),
                Module("XCTQueues", description: "Testing helpers for Vapor's Queues."),
            ]),
        ]
    )
)

let contentDirectory = "Content"
let outputDirectory = "public"

print("Building Vapor API docs into ./\(outputDirectory) …")
try await Kiln.build(site, contentDirectory: contentDirectory, outputDirectory: outputDirectory)
print("Done. Serve it with:  kiln serve --directory \(outputDirectory)")
