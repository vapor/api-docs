import Kiln

private let routingKit = Module("RoutingKit", description: "High-performance routing engine for HTTP requests.")
private let consoleKit = Module("ConsoleKit", description: "APIs for creating interactive CLI tools.")
private let consoleLogger = Module("ConsoleLogger", description: "A SwiftLog LogHandler implementation for customizable logging to a console.")
private let multipartKit = Module("MultipartKit", description: "Multipart form data parsing and encoding.")

// Vapor modules shared across its version lines (v5 drops XCTVapor and adds VaporMacros).
private let vapor = Module("Vapor", description: "Core web framework for building server-side Swift applications.")
private let xctVapor = Module("XCTVapor", group: "Testing", description: "Testing utilities for Vapor applications when using XCTest.")
private let vaporTesting = Module("VaporTesting", group: "Testing", description: "Modern testing framework for Vapor apps when using Swift Testing.")
private let vaporMacros = Module("VaporMacros", description: "Macros used by Vapor.")

// JWT ships a v4 line (with Vapor 4) and a 5 line on `main` (with Vapor 5).
private let jwt = Module("JWT", description: "JWT integration for Vapor authentication.")
private let jwtKit = Module("JWTKit", description: "JSON Web Token signing and verification framework.")

let packages: [APIPackage] = [
    APIPackage("vapor/vapor", group: "Core", versions: [
        PackageVersion("4", name: "4.x", ref: "vapor4", isDefault: true, dependencies: [
            DependencyPin("vapor/routing-kit", "4"),
            DependencyPin("vapor/console-kit", "4"),
            DependencyPin("vapor/multipart-kit", "4"),
            DependencyPin("vapor/websocket-kit"),
            DependencyPin("vapor/async-kit"),
        ], modules: [vapor, xctVapor, vaporTesting]),
        // Vapor 5 (main) requires a 6.4 Swift dev-snapshot that CI doesn't have yet,
        // so it's disabled until CI is on that toolchain. Every other pre-release
        // below builds on the current stable Swift release. Re-enable this together
        // with the jwt → vapor "5-beta" pin further down.
        // Vapor 5 uses the 5.x lines of these and no longer depends on
        // websocket-kit or async-kit.
        // PackageVersion("5-beta", name: "5.0 (beta)", ref: "main", isPrerelease: true, dependencies: [
        //     DependencyPin("vapor/routing-kit", "5-beta"),
        //     DependencyPin("vapor/console-kit", "5-beta"),
        //     DependencyPin("vapor/multipart-kit", "5-alpha"),
        // ], modules: [vapor, vaporTesting, vaporMacros]),
    ]),
    APIPackage("vapor/async-kit", group: "Core", versions: [
        .single(ref: "main", modules: [Module("AsyncKit", description: "Async/await utilities and helpers for concurrent programming.")]),
    ]),
    APIPackage("vapor/routing-kit", group: "Core", versions: [
        PackageVersion("4", name: "4.x", ref: "v4", isDefault: true, modules: [routingKit]),
        PackageVersion("5-beta", name: "5.0 (beta)", ref: "main", isPrerelease: true, modules: [routingKit]),
    ]),
    APIPackage("vapor/console-kit", group: "Core", versions: [
        PackageVersion("4", name: "4.x", ref: "v4", isDefault: true, modules: [consoleKit]),
        PackageVersion("5-beta", name: "5.0 (beta)", ref: "main", isPrerelease: true, modules: [consoleKit, consoleLogger]),
    ]),
    APIPackage("vapor/websocket-kit", group: "Core", versions: [
        .single(ref: "main", modules: [Module("WebSocketKit", description: "WebSocket client and server implementation.")]),
    ]),
    APIPackage("vapor/multipart-kit", group: "Core", versions: [
        PackageVersion("4", name: "4.x", ref: "v4", isDefault: true, modules: [multipartKit]),
        PackageVersion("5-alpha", name: "5.0 (alpha)", ref: "main", isPrerelease: true, modules: [multipartKit]),
    ]),

    APIPackage("vapor/jwt", group: "Authentication", versions: [
        PackageVersion("4", name: "4.x", ref: "v4", isDefault: true, dependencies: [
            DependencyPin("vapor/vapor", "4"),
            DependencyPin("vapor/jwt-kit", "4"),
        ], modules: [jwt]),
        PackageVersion("5-beta", name: "5.0 (beta)", ref: "main", isPrerelease: true, dependencies: [
            // Re-enable alongside vapor/vapor "5-beta" above. jwt@main currently
            // builds against Vapor 4 (from: 4.110.2), so until then its Vapor links
            // fall back to the vapor default (4.x), which matches what it compiles.
            // DependencyPin("vapor/vapor", "5-beta"),
            DependencyPin("vapor/jwt-kit", "5-beta"),
        ], modules: [jwt]),
    ]),
    APIPackage("vapor/jwt-kit", group: "Authentication", versions: [
        PackageVersion("4", name: "4.x", ref: "v4", isDefault: true, modules: [jwtKit]),
        PackageVersion("5-beta", name: "5.0 (beta)", ref: "main", isPrerelease: true, modules: [jwtKit]),
    ]),
    APIPackage("vapor/authentication", group: "Authentication", versions: [
        .single(ref: "main", modules: [Module("Authentication", description: "Authentication framework for Swift applications.")]),
    ]),

    APIPackage("vapor/leaf", group: "Templating", versions: [
        .single(ref: "main", modules: [Module("Leaf", description: "Vapor integration for LeafKit.")]),
    ]),
    APIPackage("vapor/leaf-kit", group: "Templating", versions: [
        .single(ref: "main", modules: [Module("LeafKit", description: "Core templating engine framework.")]),
    ]),

    APIPackage("vapor/fluent", group: "Database", versions: [
        .single(ref: "main", modules: [Module("Fluent", description: "Vapor integration package for FluentKit.")]),
    ]),
    APIPackage("vapor/fluent-kit", group: "Database", versions: [
        .single(ref: "main", modules: [
            Module("FluentKit", description: "Core ORM framework for database operations."),
            Module("FluentSQL", description: "SQL dialect support for Fluent ORM."),
            Module("XCTFluent", group: "Testing", description: "Testing utilities for Fluent ORM."),
        ]),
    ]),
    APIPackage("vapor/fluent-postgres-driver", group: "Database", versions: [
        .single(ref: "main", modules: [Module("FluentPostgresDriver", description: "PostgreSQL driver for Fluent ORM.")]),
    ]),
    APIPackage("vapor/fluent-mongo-driver", group: "Database", versions: [
        .single(ref: "main", modules: [Module("FluentMongoDriver", description: "MongoDB driver for Fluent ORM.")]),
    ]),
    APIPackage("vapor/fluent-mysql-driver", group: "Database", versions: [
        .single(ref: "main", modules: [Module("FluentMySQLDriver", description: "MySQL driver for Fluent ORM.")]),
    ]),
    APIPackage("vapor/fluent-sqlite-driver", group: "Database", versions: [
        .single(ref: "main", modules: [Module("FluentSQLiteDriver", description: "SQLite driver for Fluent ORM.")]),
    ]),
    APIPackage("vapor/sql-kit", group: "Database", versions: [
        .single(ref: "main", modules: [Module("SQLKit", description: "SQL query building and execution framework.")]),
    ]),
    APIPackage("vapor/postgres-kit", group: "Database", versions: [
        .single(ref: "main", modules: [Module("PostgresKit", description: "PostgreSQL integration for SQLKit.")]),
    ]),
    APIPackage("vapor/mysql-kit", group: "Database", versions: [
        .single(ref: "main", modules: [Module("MySQLKit", description: "MySQL integration for SQLKit.")]),
    ]),
    APIPackage("vapor/sqlite-kit", group: "Database", versions: [
        .single(ref: "main", modules: [Module("SQLiteKit", description: "SQLite integration for SQLKit.")]),
    ]),
    APIPackage("vapor/postgres-nio", group: "Database", versions: [
        .single(ref: "main", modules: [Module("PostgresNIO", description: "Non-blocking PostgreSQL client built on SwiftNIO.")]),
    ]),
    APIPackage("vapor/mysql-nio", group: "Database", versions: [
        .single(ref: "main", modules: [Module("MySQLNIO", description: "Non-blocking MySQL client built on SwiftNIO.")]),
    ]),
    APIPackage("vapor/sqlite-nio", group: "Database", versions: [
        .single(ref: "main", modules: [Module("SQLiteNIO", description: "Non-blocking SQLite client built on SwiftNIO.")]),
    ]),
    APIPackage("vapor/redis", group: "Database", versions: [
        .single(ref: "main", modules: [Module("Redis", description: "Vapor wrapper for using Redis.")]),
    ]),

    APIPackage("vapor/queues", group: "Queues", versions: [
        .single(ref: "main", modules: [
            Module("Queues", description: "Job queue system for background processing."),
            Module("XCTQueues", group: "Testing", description: "Testing utilities for queue system."),
        ]),
    ]),
    APIPackage("vapor/queues-redis-driver", group: "Queues", versions: [
        .single(ref: "main", modules: [Module("QueuesRedisDriver", description: "Redis driver for job queue system.")]),
    ]),

    APIPackage("vapor/apns", group: "Push Notifications", versions: [
        .single(ref: "main", modules: [Module("VaporAPNS", title: "APNS", description: "Apple Push Notification Service integration.")]),
    ]),
]
