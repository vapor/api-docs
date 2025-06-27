#!/usr/bin/env swift

import Foundation

let packages: [String: [String]] = [
    "vapor": ["Vapor", "XCTVapor", "VaporTesting"],

    "async-kit": ["AsyncKit"],
    "routing-kit": ["RoutingKit"],
    "console-kit": ["ConsoleKit", "ConsoleKitCommands", "ConsoleKitTerminal"],
    "websocket-kit": ["WebSocketKit"],
    "multipart-kit": ["MultipartKit"],

    "postgres-nio": ["PostgresNIO"],
    "mysql-nio": ["MySQLNIO"],
    "sqlite-nio": ["SQLiteNIO"],

    "sql-kit": ["SQLKit"],
    "postgres-kit": ["PostgresKit"],
    "mysql-kit": ["MySQLKit"],
    "sqlite-kit": ["SQLiteKit"],

    "fluent-kit": ["FluentKit", "FluentSQL", "XCTFluent"],
    "fluent": ["Fluent"],
    "fluent-postgres-driver": ["FluentPostgresDriver"],
    "fluent-mongo-driver": ["FluentMongoDriver"],
    "fluent-mysql-driver": ["FluentMySQLDriver"],
    "fluent-sqlite-driver": ["FluentSQLiteDriver"],

    "redis": ["Redis"],
    "queues-redis-driver": ["QueuesRedisDriver"],
    "queues": ["Queues", "XCTQueues"],

    "leaf-kit": ["LeafKit"],
    "leaf": ["Leaf"],

    "jwt-kit": ["JWTKit"],
    "jwt": ["JWT"],
    "apns": ["VaporAPNS"],
]

// Package descriptions
let packageDescriptions: [String: String] = [
    "Vapor": "Core web framework for building server-side Swift applications",
    "XCTVapor": "Testing utilities for Vapor applications",
    "VaporTesting": "Advanced testing framework for Vapor apps",
    "AsyncKit": "Async/await utilities and helpers for concurrent programming",
    "RoutingKit": "High-performance routing engine for HTTP requests",
    "ConsoleKit": "Terminal UI and command-line tools framework",
    "ConsoleKitCommands": "Command parsing and execution for CLI apps",
    "ConsoleKitTerminal": "Terminal formatting and interaction utilities",
    "WebSocketKit": "WebSocket client and server implementation",
    "MultipartKit": "Multipart form data parsing and encoding",
    "PostgresNIO": "Non-blocking PostgreSQL client built on SwiftNIO",
    "MySQLNIO": "Non-blocking MySQL client built on SwiftNIO",
    "SQLiteNIO": "Non-blocking SQLite client built on SwiftNIO",
    "SQLKit": "SQL query building and execution framework",
    "PostgresKit": "PostgreSQL integration for SQLKit",
    "MySQLKit": "MySQL integration for SQLKit",
    "SQLiteKit": "SQLite integration for SQLKit",
    "FluentKit": "Core ORM framework for database operations",
    "FluentSQL": "SQL dialect support for Fluent ORM",
    "XCTFluent": "Testing utilities for Fluent ORM",
    "Fluent": "Swift ORM for SQL and NoSQL databases",
    "FluentPostgresDriver": "PostgreSQL driver for Fluent ORM",
    "FluentMongoDriver": "MongoDB driver for Fluent ORM",
    "FluentMySQLDriver": "MySQL driver for Fluent ORM",
    "FluentSQLiteDriver": "SQLite driver for Fluent ORM",
    "Redis": "Swift client for Redis key-value store",
    "QueuesRedisDriver": "Redis driver for job queue system",
    "Queues": "Job queue system for background processing",
    "XCTQueues": "Testing utilities for queue system",
    "LeafKit": "Core templating engine framework",
    "Leaf": "Templating language for generating dynamic HTML",
    "JWTKit": "JSON Web Token signing and verification framework",
    "JWT": "JWT integration for Vapor authentication",
    "VaporAPNS": "Apple Push Notification Service integration"
]

// Generate package cards HTML
let allModules = packages.values.flatMap { $0 }.sorted()
let packageCards = allModules.map { module in
    let description = packageDescriptions[module] ?? "API documentation for \(module)"
    let href = "\(module.lowercased())/documentation/\(module.lowercased())"
    
    return """
            <a href="\(href)" class="package-card" tabindex="0">
                <h2 class="package-name">\(module)</h2>
                <p class="package-description">\(description)</p>
            </a>
"""
}.joined(separator: "\n")

do {
    let publicDirUrl = URL(fileURLWithPath: "./public", isDirectory: true)
    try FileManager.default.removeItemIfExists(at: publicDirUrl)
    try FileManager.default.createDirectory(at: publicDirUrl, withIntermediateDirectories: true)

    var htmlIndex = try String(contentsOf: URL(fileURLWithPath: "./index.html", isDirectory: false), encoding: .utf8)
    htmlIndex.replace("{{PackageCards}}", with: packageCards, maxReplacements: 1)

    try htmlIndex.write(to: publicDirUrl.appendingPathComponent("index.html", isDirectory: false), atomically: true, encoding: .utf8)
    try FileManager.default.copyItem(at: URL(fileURLWithPath: "./api-docs.png", isDirectory: false), into: publicDirUrl)
    try FileManager.default.copyItem(at: URL(fileURLWithPath: "./error.html", isDirectory: false), into: publicDirUrl)
} catch let error as NSError {
    print("❌  ERROR: \(String(reflecting: error)): \(error.userInfo)")
    exit(1)
}

extension NSError {
    func isCocoaError(_ code: CocoaError.Code) -> Bool {
        self.domain == CocoaError.errorDomain && self.code == code.rawValue
    }
}

extension FileManager {
    func removeItemIfExists(at url: URL) throws {
        do {
            try self.removeItem(at: url)
        } catch let error as NSError where error.isCocoaError(.fileNoSuchFile) {
            // ignore
        }
    }

    func copyItem(at src: URL, into dst: URL) throws {
        assert(dst.hasDirectoryPath)

        let dstItem = dst.appendingPathComponent(src.lastPathComponent, isDirectory: dst.hasDirectoryPath)
        try self.copyItem(at: src, to: dstItem)
    }
}