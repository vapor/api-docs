#!/usr/bin/env swift

import Foundation

// let packages: [String: [String]] = [
//     "vapor": ["Vapor", "XCTVapor"],

//     "async-kit": ["AsyncKit"],
//     "routing-kit": ["RoutingKit"],
//     "console-kit": ["ConsoleKit"],
//     "websocket-kit": ["WebSocketKit"],
//     "multipart-kit": ["MultipartKit"],

//     "postgres-nio": ["PostgresNIO"],
//     "mysql-nio": ["MySQLNIO"],
//     "sqlite-nio": ["SQLiteNIO"],

//     "sql-kit": ["SQLKit"],
//     "postgres-kit": ["PostgresKit"],
//     "mysql-kit": ["MySQLKit"],
//     "sqlite-kit": ["SQLiteKit"],

//     "fluent-kit": ["FluentKit", "FluentSQL", "XCTFluent"],
//     "fluent": ["Fluent"],
//     "fluent-postgres-driver": ["FluentPostgresDriver"],
//     "fluent-mongo-driver": ["FluentMongoDriver"],
//     "fluent-mysql-driver": ["FluentMySQLDriver"],
//     "fluent-sqlite-driver": ["FluentSQLiteDriver"],

//     "redis": ["Redis"],
//     "queues-redis-driver": ["QueuesRedisDriver"],
//     "queues": ["Queues", "XCTQueues"],

//     "leaf-kit": ["LeafKit"],
//     "leaf": ["Leaf"],

//     "jwt-kit": ["JWTKit"],
//     "jwt": ["JWT"],
//     "apns": ["APNS"],
// ]

 let packages: [String: [String]] = [
    "postgres-nio": ["PostgresNIO"],
 ]

let url = URL(fileURLWithPath: "index.html")
var htmlString = try String(contentsOf: url)
var optionsString = ""
var allModules: [(package: String, module: String)] = []

for (package, modules) in packages {
    try getNewestRepoVersion(package)
    for module in modules {
        print("Generating api-docs for package: \(package), module: \(module)")
        try generateDocs(
            package: package, 
            module: module
        )
        allModules.append((package: package, module: module))
    }
    print("✅ Finished generating api-docs for package: \(package)")
}

let sortedModules = allModules.sorted { $0.module < $1.module }
for object in sortedModules {
    let package = object.package
    let module = object.module
    optionsString += "<option value=\"/\(package)/documentation/\(module.lowercased())\">\(module)</option>\n"
}

htmlString = htmlString.replacingOccurrences(of: "{{Options}}", with: optionsString)

try htmlString.write(toFile: "public/index.html", atomically: true, encoding: .utf8)
try shell("cp", "api-docs.png", "public/api-docs.png")

// MARK: Functions

func generateDocs(package: String, module: String) throws {
    do {
        try shell("rm", "-rf", "public/\(package)/main/\(module)")
        try shell("mkdir", "-p", "packages/\(package)/.build/symbol-graphs")
        // Build package
        print("🔨 Building package \(package)")
        try shell(
            "swift", "build", "--package-path", "packages/\(package)",
            "--target", module, 
            "-Xswiftc", "-emit-symbol-graph",
            "-Xswiftc", "-emit-symbol-graph-dir",
            "-Xswiftc", ".build/symbol-graphs"
        )
        // Create custom directory for package-specifi symbol-graphs
        try shell(
            "mkdir", "-p", "packages/\(package)/.build/\(package)-symbol-graphs"
        )
        // Copy package-specific symbol-graphs to custom directory
        let enumerator = FileManager.default.enumerator(
            atPath: "packages/\(package)/.build/symbol-graphs"
        )
        let files = (enumerator?.allObjects as! [String]).filter{ $0.starts(with: module) }
        for file in files {
            try FileManager.default.copyItemIfPossible(
                atPath: "packages/\(package)/.build/symbol-graphs/\(file)", 
                toPath: "packages/\(package)/.build/\(package)-symbol-graphs/\(file)"
            )
        }
        print("📝 Generating docs")
        let docCExecutablePath: String 
        #if os(Linux)
        docCExecutablePath = "/usr/bin/docc"
        #else
        docCExecutablePath = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/docc"
        #endif
        try shell("mkdir", "-p", "public/\(package)")
        try shell(
            docCExecutablePath,
            "convert", "packages/\(package)/Sources/\(module)/Docs.docc",
            "--fallback-display-name", module,
            "--fallback-bundle-identifier", "nio.postgres",
            "--fallback-bundle-version", "1.0.0",
            "--additional-symbol-graph-dir", "packages/\(package)/.build/\(package)-symbol-graphs",
            "--transform-for-static-hosting",
            "--output-path", "public/\(package)",
            "--hosting-base-path", "/\(package)"
        )
        try FileManager.default.copyItemIfPossible(
            atPath: "theme-settings.json",
            toPath: "packages/\(package)/Sources/PostgresNIO/Docs.docc/theme-settings.json"
        )
    } catch let error as ShellError {
        throw error
    }
}

func gitClone(_ package: String) throws {
    print("📦 Updating \(package)")
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

@discardableResult
func shell(_ args: String..., returnStdOut: Bool = false, stdIn: Pipe? = nil) throws -> Pipe {
    let task = Process()
    task.executableURL = URL(filePath: "/usr/bin/env")
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
                atPath: atPath,
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
