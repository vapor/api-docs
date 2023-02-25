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
//     "fluent-sqlite-driver": ["FluentSQLiteDriver"],

    "redis": ["Redis"],
    "queues-redis-driver": ["QueuesRedisDriver"],
    "queues": ["Queues", "XCTQueues"],

    "leaf-kit": ["LeafKit"],
    "leaf": ["Leaf"],

    "jwt-kit": ["JWTKit"],
    "jwt": ["JWT"],
    "apns": ["APNS"],
]

try shell("rm", "-rf", "public/")
let url = URL(fileURLWithPath: "index.html")
var htmlString = try String(contentsOf: url)
var optionsString = ""
var allModules: [(package: String, module: String)] = []

for (package, modules) in packages {
    for module in modules {
        allModules.append((package: package, module: module))
    }
}

let sortedModules = allModules.sorted { $0.module < $1.module }
for object in sortedModules {
    let module = object.module
    optionsString += "<option value=\"/\(module.lowercased())/documentation/\(module.lowercased())\">\(module)</option>\n"
}

htmlString = htmlString.replacingOccurrences(of: "{{Options}}", with: optionsString)

try shell("mkdir", "public")
try htmlString.write(toFile: "public/index.html", atomically: true, encoding: .utf8)
try shell("cp", "api-docs.png", "public/api-docs.png")

// MARK: Functions
@discardableResult
func shell(_ args: String..., returnStdOut: Bool = false, stdIn: Pipe? = nil) throws -> Pipe {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    let pipe = Pipe()
    if returnStdOut {
        task.standardOutput = pipe
    }
    if let stdIn = stdIn {
        task.standardInput = stdIn
    }
    try task.run()
    task.waitUntilExit()
    guard task.terminationStatus == 0 else {
        throw ShellError(terminationStatus: task.terminationStatus)
    }
    return pipe
}

struct ShellError: Error {
    var terminationStatus: Int32
}

extension Pipe {
    func string() throws -> String? {
        let data = try self.fileHandleForReading.readToEnd()!
        let result: String?
        if let string = String(
            data: data, 
            encoding: String.Encoding.utf8
        ) {
            result = string
        } else {
            result = nil
        }
        return result
    }
} 

extension FileManager {
    func copyItemIfPossible(atPath: String, toPath: String) throws {
        var isDirectory: ObjCBool = false
        guard self.fileExists(
                atPath: toPath,
                isDirectory: &isDirectory
            ) == false else {
                return
            }
        return try self.copyItem(
            atPath: atPath,
            toPath: toPath
        )
    }
}
