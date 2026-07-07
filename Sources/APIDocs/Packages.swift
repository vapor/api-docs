import Kiln

let packages: [APIPackage] = [
    APIPackage("vapor/vapor", group: "Core",
               modules: [
                   Module("Vapor", description: "Core web framework for building server-side Swift applications."),
                   Module("XCTVapor", group: "Testing", description: "Testing utilities for Vapor applications when using XCTest."),
                   Module("VaporTesting", group: "Testing", description: "Modern testing framework for Vapor apps when using Swift Testing."),
               ],
               versions: [PackageVersion("4", name: "4.x", ref: "vapor4", isDefault: true)]),
    APIPackage("vapor/async-kit", ref: "main", group: "Core",
               modules: [Module("AsyncKit", description: "Async/await utilities and helpers for concurrent programming.")]),
    APIPackage("vapor/routing-kit", group: "Core",
               modules: [Module("RoutingKit", description: "High-performance routing engine for HTTP requests.")],
               versions: [
                   PackageVersion("4", name: "4.x", ref: "v4", isDefault: true),
                   PackageVersion("5-beta", name: "5.0 (beta)", ref: "main", isPrerelease: true),
               ]),
    APIPackage("vapor/console-kit", group: "Core",
               modules: [
                   Module("ConsoleKit", description: "APIs for creating interactive CLI tools."),
                   Module("ConsoleLogger", description: "A SwiftLog LogHandler implementation for customizable logging to a console."),
               ],
               versions: [
                   PackageVersion("4", name: "4.x", ref: "v4", isDefault: true),
                   PackageVersion("5-beta", name: "5.0 (beta)", ref: "main", isPrerelease: true),
               ]),
    APIPackage("vapor/websocket-kit", ref: "main", group: "Core",
               modules: [Module("WebSocketKit", description: "WebSocket client and server implementation.")]),
    APIPackage("vapor/multipart-kit", group: "Core",
               modules: [Module("MultipartKit", description: "Multipart form data parsing and encoding.")],
               versions: [
                   PackageVersion("4", name: "4.x", ref: "v4", isDefault: true),
                   PackageVersion("5-alpha", name: "5.0 (alpha)", ref: "main", isPrerelease: true),
               ]),

    APIPackage("vapor/jwt", ref: "main", group: "Authentication",
               modules: [Module("JWT", description: "JWT integration for Vapor authentication.")]),
    APIPackage("vapor/jwt-kit", ref: "main", group: "Authentication",
               modules: [Module("JWTKit", description: "JSON Web Token signing and verification framework.")]),
    APIPackage("vapor/authentication", ref: "main", group: "Authentication",
               modules: [Module("Authentication", description: "Authentication framework for Swift applications.")]),

    APIPackage("vapor/leaf", ref: "main", group: "Templating",
               modules: [Module("Leaf", description: "Vapor integration for LeafKit.")]),
    APIPackage("vapor/leaf-kit", ref: "main", group: "Templating",
               modules: [Module("LeafKit", description: "Core templating engine framework.")]),

    APIPackage("vapor/fluent", ref: "main", group: "Database",
               modules: [Module("Fluent", description: "Vapor integration package for FluentKit.")]),
    APIPackage("vapor/fluent-kit", ref: "main", group: "Database",
               modules: [
                   Module("FluentKit", description: "Core ORM framework for database operations."),
                   Module("FluentSQL", description: "SQL dialect support for Fluent ORM."),
                   Module("XCTFluent", group: "Testing", description: "Testing utilities for Fluent ORM."),
               ]),
    APIPackage("vapor/fluent-postgres-driver", ref: "main", group: "Database",
               modules: [Module("FluentPostgresDriver", description: "PostgreSQL driver for Fluent ORM.")]),
    APIPackage("vapor/fluent-mongo-driver", ref: "main", group: "Database",
               modules: [Module("FluentMongoDriver", description: "MongoDB driver for Fluent ORM.")]),
    APIPackage("vapor/fluent-mysql-driver", ref: "main", group: "Database",
               modules: [Module("FluentMySQLDriver", description: "MySQL driver for Fluent ORM.")]),
    APIPackage("vapor/fluent-sqlite-driver", ref: "main", group: "Database",
               modules: [Module("FluentSQLiteDriver", description: "SQLite driver for Fluent ORM.")]),
    APIPackage("vapor/sql-kit", ref: "main", group: "Database",
               modules: [Module("SQLKit", description: "SQL query building and execution framework.")]),
    APIPackage("vapor/postgres-kit", ref: "main", group: "Database",
               modules: [Module("PostgresKit", description: "PostgreSQL integration for SQLKit.")]),
    APIPackage("vapor/mysql-kit", ref: "main", group: "Database",
               modules: [Module("MySQLKit", description: "MySQL integration for SQLKit.")]),
    APIPackage("vapor/sqlite-kit", ref: "main", group: "Database",
               modules: [Module("SQLiteKit", description: "SQLite integration for SQLKit.")]),
    APIPackage("vapor/postgres-nio", ref: "main", group: "Database",
               modules: [Module("PostgresNIO", description: "Non-blocking PostgreSQL client built on SwiftNIO.")]),
    APIPackage("vapor/mysql-nio", ref: "main", group: "Database",
               modules: [Module("MySQLNIO", description: "Non-blocking MySQL client built on SwiftNIO.")]),
    APIPackage("vapor/sqlite-nio", ref: "main", group: "Database",
               modules: [Module("SQLiteNIO", description: "Non-blocking SQLite client built on SwiftNIO.")]),
    APIPackage("vapor/redis", ref: "main", group: "Database",
               modules: [Module("Redis", description: "Vapor wrapper for using Redis.")]),

    // MARK: Queues
    APIPackage("vapor/queues", ref: "main", group: "Queues",
               modules: [
                   Module("Queues", description: "Job queue system for background processing."),
                   Module("XCTQueues", group: "Testing", description: "Testing utilities for queue system."),
               ]),
    APIPackage("vapor/queues-redis-driver", ref: "main", group: "Queues",
               modules: [Module("QueuesRedisDriver", description: "Redis driver for job queue system.")]),

    // MARK: Push Notifications
    APIPackage("vapor/apns", ref: "main", group: "Push Notifications",
               modules: [Module("VaporAPNS", title: "APNS", description: "Apple Push Notification Service integration.")]),
]
