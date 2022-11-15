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
    "postgres-nio": ["PostgresNIO"]
]

try updateSwiftDocC()
try updateSwiftDocCRenderer()
try shell("swift", "build", "--package-path", "swift-docc", "-c", "release")
setenv("DOCC_HTML_DIR", "swift-docc-render-artifact/dist", 1)

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
        try copyHTMLData(package: package, module: module)
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

// MARK: Functions

func updateSwiftDocC() throws {
    do {
        try shell("git", "clone", "https://github.com/apple/swift-docc.git", "swift-docc")
    } catch let error as ShellError {
        if error.terminationStatus == 128 {
            // repo already exists, get newest version
            try shell("git", "-C", "swift-docc/", "checkout", "main")
            try shell("git", "-C", "swift-docc/", "reset", "--hard")
            try shell("git", "-C", "swift-docc/", "pull")
        } else {
            throw error
        }
    }
}

func updateSwiftDocCRenderer() throws {
    do {
        try shell("git", "clone", "https://github.com/apple/swift-docc-render-artifact.git", "swift-docc-render-artifact")
    } catch let error as ShellError {
        if error.terminationStatus == 128 {
            try shell("git", "-C", "swift-docc-render-artifact/", "checkout", "main")
            try shell("git", "-C", "swift-docc-render-artifact/", "reset", "--hard")
            try shell("git", "-C", "swift-docc-render-artifact/", "pull")
        } else {
            throw error
        }
    }
}

func generateDocs(package: String, module: String) throws {
    do {
        // try shell("rm", "-rf", "public/\(package)/main/\(module)")
        // Create symbol-graphs directory for package
        try shell(
            "mkdir", "-p", "packages/\(package)/.build/symbol-graphs"
        )
        // Build package
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
        var isDirectory: ObjCBool = false
        for file in files {
            guard FileManager.default.fileExists(
                atPath: "packages/\(package)/.build/\(package)-symbol-graphs/\(file)",
                isDirectory: &isDirectory
            ) == false else {
                continue
            }
            try FileManager.default.copyItem(
                atPath: "packages/\(package)/.build/symbol-graphs/\(file)", 
                toPath: "packages/\(package)/.build/\(package)-symbol-graphs/\(file)"
            )
        }
        // Preview docs
        try shell(
            "swift-docc/.build/arm64-apple-macosx/release/docc",
            "convert", "packages/\(package)/Sources/\(module)/Docs.docc",
            "--fallback-display-name", module,
            "--fallback-bundle-identifier", "nio.postgres",
            "--fallback-bundle-version", "1.0.0",
            "--additional-symbol-graph-dir", "packages/\(package)/.build/\(package)-symbol-graphs"
        )
    } catch let error as ShellError {
        throw error
    }
}

func copyHTMLData(package: String, module: String) throws {
    let sourceDir = "packages/\(package)/Sources/\(module)/Docs.docc/.docc-build"
    let destinationDir = "public/\(package)/"
    try shell("rm", "-rf", destinationDir)
    try shell("mkdir", "-p", destinationDir)
    let items = try FileManager.default.contentsOfDirectory(
        atPath: sourceDir
    )
    for item in items {
        try FileManager.default.copyItem(
            atPath: "\(sourceDir)/\(item)", 
            toPath: "\(destinationDir)/\(item)"
        )
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
