#!/usr/bin/env swift

import Foundation

guard CommandLine.argc == 3 else {
    print("❌ ERROR: You must provide the package name and modules as a comma separated string.")
    exit(1)
}

let packageName = CommandLine.arguments[1]
let moduleList = CommandLine.arguments[2]

let modules = moduleList.components(separatedBy: ",")

// Set up
try shell("rm", "-rf", "public/")
try shell("mkdir", "-p", ".build/symbol-graphs")
try shell("mkdir", "-p", "public/\(packageName)")

for module in modules {
    print("Generating api-docs for package: \(packageName), module: \(module)")
    try generateDocs(
        package: packageName, 
        module: module
    )
}

print("✅ Finished generating api-docs for package: \(packageName)")

// MARK: Functions

func generateDocs(package: String, module: String) throws {
    do {
        // Build package
        print("🔨 Building \(package):\(module)")
        try shell(
            "swift", "build",
            "--target", module, 
            "-Xswiftc", "-emit-symbol-graph",
            "-Xswiftc", "-emit-symbol-graph-dir",
            "-Xswiftc", ".build/symbol-graphs"
        )
        print("📝 Generating docs")
        let docCExecutablePath: String 
        #if os(Linux)
        docCExecutablePath = "/usr/bin/docc"
        #else
        docCExecutablePath = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/docc"
        #endif
        try shell(
            docCExecutablePath,
            "convert", "Sources/\(module)/Docs.docc",
            "--fallback-display-name", module,
            "--fallback-bundle-identifier", "codes.vapor.\(package).\(module.lowercased())",
            "--fallback-bundle-version", "1.0.0",
            "--additional-symbol-graph-dir", ".build/symbol-graphs",
            "--transform-for-static-hosting",
            "--output-path", "public/\(package)/\(module.lowercased())",
            "--hosting-base-path", "/\(package)/\(module.lowercased())"
        )
        print("🖨️ Copying files")
        try FileManager.default.copyItemIfPossible(
            atPath: "theme-settings.json",
            toPath: "public/\(package)/\(module)/theme-settings.json"
        )
    } catch let error as ShellError {
        throw error
    }
}

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
