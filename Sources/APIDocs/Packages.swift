import Kiln

// Modules shared across a package's versions are declared once and reused, so a
// version that changes its target set (e.g. console-kit's 5.0 line adding
// ConsoleLogger) is the only place the difference appears.
private let routingKit = Module("RoutingKit", description: "High-performance routing engine for HTTP requests.")
private let consoleKit = Module("ConsoleKit", description: "APIs for creating interactive CLI tools.")
private let consoleLogger = Module("ConsoleLogger", description: "A SwiftLog LogHandler implementation for customizable logging to a console.")
private let multipartKit = Module("MultipartKit", description: "Multipart form data parsing and encoding.")

let packages: [APIPackage] = [
    APIPackage("vapor/vapor", group: "Core", versions: [
        .single(ref: "vapor4", modules: [
            Module("Vapor", description: "Core web framework for building server-side Swift applications."),
            Module("XCTVapor", group: "Testing", description: "Testing utilities for Vapor applications when using XCTest."),
            Module("VaporTesting", group: "Testing", description: "Modern testing framework for Vapor apps when using Swift Testing."),
        ]),
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
        .single(ref: "main", modules: [Module("JWT", description: "JWT integration for Vapor authentication.")]),
    ]),
    APIPackage("vapor/jwt-kit", group: "Authentication", versions: [
        .single(ref: "main", modules: [Module("JWTKit", description: "JSON Web Token signing and verification framework.")]),
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

    // MARK: Queues
    APIPackage("vapor/queues", group: "Queues", versions: [
        .single(ref: "main", modules: [
            Module("Queues", description: "Job queue system for background processing."),
            Module("XCTQueues", group: "Testing", description: "Testing utilities for queue system."),
        ]),
    ]),
    APIPackage("vapor/queues-redis-driver", group: "Queues", versions: [
        .single(ref: "main", modules: [Module("QueuesRedisDriver", description: "Redis driver for job queue system.")]),
    ]),

    // MARK: Push Notifications
    APIPackage("vapor/apns", group: "Push Notifications", versions: [
        .single(ref: "main", modules: [Module("VaporAPNS", title: "APNS", description: "Apple Push Notification Service integration.")]),
    ]),
]
