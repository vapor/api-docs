import Foundation

guard CommandLine.argc == 3 else {
    print("❌  ERROR: You must provide the package name and modules as a comma separated string.")
    exit(1)
}

let packageName = CommandLine.arguments[1]
let moduleList = CommandLine.arguments[2]

let modules = moduleList.components(separatedBy: ",")

let currentDirectoryUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
let publicDirectoryUrl = currentDirectoryUrl.appendingPathComponent("public", isDirectory: true)

try run()

// MARK: Functions

func run() throws {
    // Set up
    try FileManager.default.removeItemIfExists(at: publicDirectoryUrl)
    try FileManager.default.createDirectory(at: publicDirectoryUrl, withIntermediateDirectories: true)

    try ensurePluginAvailable()

    // Run
    for module in modules {
        print("⚙️  Generating api-docs for package: \(packageName), module: \(module)")
        try generateDocs(module: module)
    }

    print("✅  Finished generating api-docs for package: \(packageName)")
}

func ensurePluginAvailable() throws {
    let manifestUrl = currentDirectoryUrl.appendingPathComponent("Package.swift", isDirectory: false)
    var manifestContents = try String(contentsOf: manifestUrl, encoding: .utf8)
    if !manifestContents.contains(".package(url: \"https://github.com/apple/swift-docc-plugin") {
        // This is freely admitted to be quick and dirty. When SE-0301 gets into a release, we can use that.
        print("🧬  Injecting missing DocC plugin dependency")
        guard let depsArrayRange = manifestContents.firstRange(of: "dependencies: [") else {
            print("❌  ERROR: Can't inject swift-docc-plugin dependency (can't find deps array).")
            exit(1)
        }
        manifestContents.insert(
            contentsOf: "\n.package(url: \"https://github.com/apple/swift-docc-plugin.git\", from: \"1.3.0\"),\n",
            at: depsArrayRange.upperBound
        )
        try manifestContents.write(to: manifestUrl, atomically: true, encoding: .utf8)
    }
}

func generateDocs(module: String) throws {
    print("🔎  Finding DocC catalog")
    let doccCatalogs = try FileManager.default.contentsOfDirectory(
        at: currentDirectoryUrl.appendingPathComponent("Sources", isDirectory: true).appendingPathComponent(module, isDirectory: true),
        includingPropertiesForKeys: nil,
        options: [.skipsSubdirectoryDescendants]
    ).filter { $0.hasDirectoryPath && $0.pathExtension == "docc" }
    guard !doccCatalogs.isEmpty else {
        print("❌  ERROR: No DocC catalog found for \(module)")
        exit(1)
    }
    guard doccCatalogs.count == 1 else {
        print("❌  ERROR: More than one DocC catalog found for \(module):\n\(doccCatalogs.map(\.lastPathComponent))")
        exit(1)
    }
    let doccCatalogUrl = doccCatalogs[0]
    print("🗂️  Using DocC catalog \(doccCatalogUrl.lastPathComponent)")

    print("📐  Copying theme")
    do {
        try FileManager.default.copyItemIfExistsWithoutOverwrite(
            at: currentDirectoryUrl.appendingPathComponent("theme-settings.json", isDirectory: false),
            to: doccCatalogUrl.appendingPathComponent("theme-settings.json", isDirectory: false)
        )
    } catch CocoaError.fileReadNoSuchFile, CocoaError.fileWriteFileExists {
		// ignore
    }
    
    print("📝  Generating docs")
    try shell([
        "swift", "package",
        "--allow-writing-to-directory", publicDirectoryUrl.path,
        "generate-documentation",
        "--target", module,
        "--disable-indexing",
        "--experimental-skip-synthesized-symbols",
        "--fallback-display-name", module,
        "--fallback-bundle-identifier", "codes.vapor.\(packageName.lowercased()).\(module.lowercased())",
        "--fallback-bundle-version", "1.0.0",
        "--transform-for-static-hosting",
        "--hosting-base-path", "/\(module.lowercased())",
        "--output-path", publicDirectoryUrl.appendingPathComponent(module.lowercased(), isDirectory: true).path,
    ])
}

func shell(_ args: String...) throws { try shell(args) }
func shell(_ args: [String]) throws {
    // For fun, echo the command:
    var sawXOpt = false, seenOpt = false, lastWasOpt = false
    print("+ /usr/bin/env \\\n     ", terminator: "")
    for arg in (args.dropLast() + [args.last! + "\n"]) {
        if (seenOpt && !lastWasOpt) || ((!seenOpt || (lastWasOpt && !sawXOpt)) && arg.starts(with: "-")) {
            print(" \\\n     ", terminator: "")
        }
        print(" \(arg)", terminator: "")
        lastWasOpt = arg.starts(with: "-")
        (seenOpt, sawXOpt) = (seenOpt || lastWasOpt, arg.starts(with: "-X"))
    }

    // Run the command:
    let task = try Process.run(URL(fileURLWithPath: "/usr/bin/env", isDirectory: false), arguments: args)
    task.waitUntilExit()
    guard task.terminationStatus == 0 else {
        throw ShellError(terminationStatus: task.terminationStatus)
    }
}

struct ShellError: Error {
    var terminationStatus: Int32
}

extension FileManager {
    func removeItemIfExists(at url: URL) throws {
        do {
            try self.removeItem(at: url)
        } catch let error as NSError where error.domain == CocoaError.errorDomain && error.code == CocoaError.fileNoSuchFile.rawValue {
            // ignore
        }
    }
    
    func copyItemIfExistsWithoutOverwrite(at src: URL, to dst: URL) throws {
        do {
            try self.copyItem(at: src, to: dst)
        } catch let error as NSError where error.domain == CocoaError.errorDomain && error.code == CocoaError.fileReadNoSuchFile.rawValue {
            // ignore
        } catch let error as NSError where error.domain == CocoaError.errorDomain && error.code == CocoaError.fileWriteFileExists.rawValue {
            // ignore
        }
    }
}
