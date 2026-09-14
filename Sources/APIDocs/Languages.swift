import Kiln

let languages: [Language] = [
    Language(
        .english,
        isDefault: true,
        customStrings: [
            "siteId": "apiDocs",
            // Announcement banner (shared partials/announce.leaf). announceMessage
            // shows the banner; clear it to hide. Bump announceId when the copy
            // changes so visitors who dismissed the old notice see the new one.
            "announceId": "ten-years-of-vapor",
            "announceMessage": "It's Vapor Week! Celebrating 10 Years of Vapor",
            "announceLink": "https://blog.vapor.codes/posts/ten-years-of-vapor/",
            "announceLinkText": "Read more",
            "head.defaultOgType": "article",
            "head.homeSuffix": "",
            "head.titleSeparator": " · ",
            "tagline": "Reference documentation for Vapor and its ecosystem.",
            "footer.tagline": "Reference documentation for Vapor and its ecosystem.",
            "joinDiscord": "Join our Discord",
            "footer.joinDiscord": "Join our Discord",
            "supporters": "Supporters",
            "footer.supporters": "Supporters",
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
        image: "assets/api-og-2x.png"
    )
]
