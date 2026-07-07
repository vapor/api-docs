import Kiln

let packages: [APIPackage] = [
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
]
