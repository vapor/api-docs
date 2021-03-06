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
    "apns": ["APNS"],
]


try updateSwiftDoc()
try shell("swift", "build", "--package-path", "swift-doc", "-c", "release")

let url = URL(fileURLWithPath: "index.html")
var htmlString = try String(contentsOf: url)
var optionsString = ""
var allModules: [(package: String, module: String)] = []

for (package, modules) in packages {
    try getNewestRepoVersion(package)
    for module in modules {
        print("Generating api-docs for package: \(package), module: \(module)")
        try generateDocs(package: package, module: module)
        allModules.append((package: package, module: module))
    }

    print("Finished generating all api-docs for package: \(package)")
}

let sortedModules = allModules.sorted { $0.module < $1.module }
for object in sortedModules {
    let package = object.package
    let module = object.module
    optionsString += "<option value=\"/\(package)/main/\(module)\">\(module)</option>\n"
}

htmlString = htmlString.replacingOccurrences(of: "{{Options}}", with: optionsString)

try htmlString.write(toFile: "public/index.html", atomically: true, encoding: .utf8)
try shell("cp", "api-docs.png", "public/api-docs.png")
try shell("chmod", "755", "-R", "public")

// MARK: Functions

func updateSwiftDoc() throws {
    do {
        try shell("git", "clone", "https://github.com/SwiftDocOrg/swift-doc.git", "swift-doc")
    } catch let error as ShellError {
        if error.terminationStatus == 128 {
            // repo already exists, get newest version
            try shell("git", "-C", "swift-doc/", "checkout", "master")
            try shell("git", "-C", "swift-doc/", "reset", "--hard")
            try shell("git", "-C", "swift-doc/", "pull")
        } else {
            throw error
        }
    }
}

func generateDocs(package: String, module: String) throws {
    do {
        try shell("rm", "-rf", "public/\(package)/main/\(module)")
        try shell(
            "./swift-doc/.build/release/swift-doc",
            "generate", "packages/\(package)/Sources/\(module)",
            "--module-name", "\(module)",
            "--output", "public/\(package)/main/\(module)",
            "--base-url", "/\(package)/main/\(module)/",
            "--format", "html"
        )
        try shell("chmod", "755", "-R", "public/\(package)/main/\(module)")
    } catch let error as ShellError {
        throw error
    }
}

func gitClone(_ package: String) throws {
    try shell("git", "clone", "https://github.com/vapor/\(package).git", "packages/\(package)")
}

func getNewestRepoVersion(_ package: String) throws {
    do {
        try gitClone(package)
    } catch let error as ShellError {
        if error.terminationStatus == 128 {
            // repo already exists, get newest version
            try gitPullMain(package)
        } else {
            throw error
        }
    }
}

func gitPullMain(_ package: String) throws {
    try shell("git", "-C", "packages/\(package)", "fetch")
    try shell("git", "-C", "packages/\(package)", "checkout", "main")
    try shell("git", "-C", "packages/\(package)", "pull")
}

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
