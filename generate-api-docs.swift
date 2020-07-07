#!/usr/bin/env swift

import Foundation

let packages: [String: [String]] = [
    "vapor": ["Vapor", "XCTVapor"],

    "async-kit": ["AsyncKit"],
    "routing-kit": ["RoutingKit"],
    "console-kit": ["ConsoleKit"],
    "websocket-kit": ["WebSocketKit"],

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
    "redis-kit": ["RedisKit"],
    "queues-redis-driver": ["QueuesRedisDriver"],
    "queues": ["Queues", "XCTQueues"],

    "leaf-kit": ["LeafKit"],
    "leaf": ["Leaf"],

    "jwt-kit": ["JWTKit"],
    "jwt": ["JWT"],
    "apns": ["APNS"],
]

func shell(_ args: String...) throws {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    guard task.terminationStatus == 0 else {
        throw ShellError(terminationStatus: task.terminationStatus)
    }
}
struct ShellError: Error {
    var terminationStatus: Int32
}

func gitClone(_ package: String) throws {
    try shell("git", "clone", "https://github.com/vapor/\(package).git", "packages/\(package)")
}

func gitPullMaster(_ package: String) throws {
    try shell("git", "-C", "packages/\(package)", "checkout", "master")
    try shell("git", "-C", "packages/\(package)", "pull")
}

func getNewestRepoVersion(_ package: String) throws {
    do {
        try gitClone(package)
    } catch let error as ShellError {
        if error.terminationStatus == 128 {
            // repo already exists, get newest version
            try gitPullMaster(package)
        } else {
            throw error
        }
    }
}

func updateSwiftDoc() throws {
    do {
        try shell("git", "clone", "https://github.com/SwiftDocOrg/swift-doc.git",
                  "swift-doc")
    } catch let error as ShellError {
        if error.terminationStatus == 128 {
            // repo already exists, get newest version
            try shell("git", "-C", "swift-doc/", "checkout", "master")
            try shell("git", "-C", "swift-doc/", "pull")
        } else {
            throw error
        }
    }
}

func recursiveChmod(path: String) throws {
    try shell("chmod", "-R", "u+rwX,go+rX,go-w", "\(path)")
}

func generateDocs(package: String, module: String) throws {
    do {
        try shell("rm", "-rf", "public/\(package)/master/\(module)")
        try shell("swift", "run", "--package-path", "swift-doc", "swift-doc", "generate", "packages/\(package)/Sources/\(module)", "--module-name", "\(module)", "--output", "public/\(package)/master/\(module)", "--base-url", "\(package)/master/\(module)/", "--format", "html")
    } catch let error as ShellError {
        throw error
    }
}

// update swift doc
try updateSwiftDoc()
try shell("swift", "build", "--package-path", "swift-doc")

for (package, modules) in packages {
    try getNewestRepoVersion(package)
    for module in modules {
        print("Generating api-docs for package: \(package), module: \(module)")
        try generateDocs(package: package, module: module)
    }
    try recursiveChmod(path: "public/\(package)")
    print("Finished generating all api-docs for package: \(package)")
}
