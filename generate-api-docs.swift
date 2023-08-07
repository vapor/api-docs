#!/usr/bin/env swift

import Foundation

let packages: [String: [String]] = [
    "vapor": ["Vapor", "XCTVapor"],

    "async-kit": ["AsyncKit"],
    "routing-kit": ["RoutingKit"],
    "console-kit": ["ConsoleKit"],
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

let htmlMenu = packages.values.flatMap { $0 }
    .sorted()
    .map { "<option value=\"\($0.lowercased())/documentation/\($0.lowercased())\">\($0)</option>" }
    .joined(separator: "\n")

do {
    let publicDirUrl = URL(fileURLWithPath: "./public", isDirectory: true)
    try FileManager.default.removeItemIfExists(at: publicDirUrl)
    try FileManager.default.createDirectory(at: publicDirUrl, withIntermediateDirectories: true)

    var htmlIndex = try String(contentsOf: URL(fileURLWithPath: "./index.html", isDirectory: false), encoding: .utf8)
    htmlIndex.replace("{{Options}}", with: "\(htmlMenu)\n", maxReplacements: 1)

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
