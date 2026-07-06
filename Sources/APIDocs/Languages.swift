import Kiln

// The API docs are single-language (English) for now. These custom strings feed
// the shared Vapor design partials (head/header/footer) via `#localise("key")` —
// the same keys docs.vapor.codes defines, so the shared chrome renders correctly.
let languages: [Language] = [
    Language(
        .english,
        isDefault: true,
        customStrings: [
            // Shared design-partial config.
            "siteId": "api-docs",             // footer link-target branching
            "head.defaultOgType": "article",  // og:type for reference pages
            "head.homeSuffix": "",
            "head.titleSeparator": " · ",
            "tagline": "Reference documentation for Vapor and its ecosystem.",
            "footer.tagline": "Reference documentation for Vapor and its ecosystem.",
            "joinDiscord": "Join our Discord",
            "footer.joinDiscord": "Join our Discord",
            "supporters": "Supporters",
            "footer.supporters": "Supporters",
            // Framework/API documentation switcher (in the shared navbar).
            "frameworkDocs": "Framework Docs",
            "footer.frameworkDocs": "Framework Docs",
            "apiDocs": "API Docs",
            "footer.apiDocs": "API Docs",
            "frameworkDocsCaption": "Learn how to use Vapor",
            "apiDocsCaption": "Reference documentation for Vapor",
            "selectLanguage": "Select language",
            "selectVersion": "Select documentation version",
            "selectTheme": "Select theme",
            "closeMenu": "Close menu",
            "skipToContent": "Skip to content",
        ],
        image: "assets/social-card.png"
    )
]
