import Foundation

guard CommandLine.argc == 3 else {
    print("❌  ERROR: You must provide the package name and modules as a comma separated string.")
    exit(1)
}

let packageName = CommandLine.arguments[1]
let moduleList = CommandLine.arguments[2]

let modules = moduleList.components(separatedBy: ",")

let publicDirectoryUrl = URL.currentDirectory().appending(component: "public/")

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
    for manifestName in ["Package@swift-5.9.swift", "Package@swift-5.8.swift", "Package@swift-5.7.swift", "Package@swift-5.10.swift", "Package@swift-6.0.swift", "Package.swift"] {
        let manifestUrl = URL.currentDirectory().appending(component: manifestName)
        var manifestContents: String
        do { manifestContents = try String(contentsOf: manifestUrl, encoding: .utf8) }
        catch let error as NSError where error.isCocoaError(.fileReadNoSuchFile) { continue }
        catch let error as NSError where error.isPOSIXError(.ENOENT) { continue }

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
        return
    }
    print("❌  ERROR: Can't inject swift-docc-plugin dependency (no usable manifest found).")
    exit(1)
}

func generateDocs(module: String) throws {
    print("🔎  Finding DocC catalog")
    let doccCatalogs = try FileManager.default.contentsOfDirectory(
        at: URL.currentDirectory().appending(components: "Sources", "\(module)/"),
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
    try FileManager.default.copyItemIfExistsWithoutOverwrite(
        at: URL.currentDirectory().appending(component: "theme-settings.json"),
        to: doccCatalogUrl.appending(component: "theme-settings.json")
    )
    
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
        "--output-path", publicDirectoryUrl.appending(component: "\(module.lowercased())/").path,
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
    let task = try Process.run(URL(filePath: "/usr/bin/env"), arguments: args)
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
        } catch let error as NSError where error.isCocoaError(.fileNoSuchFile) {
            // ignore
        }
    }
    
    func copyItemIfExistsWithoutOverwrite(at src: URL, to dst: URL) throws {
        do {
            // https://github.com/apple/swift-corelibs-foundation/pull/4808
            #if !canImport(Darwin)
            do {
                _ = try dst.checkResourceIsReachable()
                throw NSError(domain: CocoaError.errorDomain, code: CocoaError.fileWriteFileExists.rawValue)
            } catch let error as NSError where error.isCocoaError(.fileReadNoSuchFile) {}
            #endif
            try self.copyItem(at: src, to: dst)
        } catch let error as NSError where error.isCocoaError(.fileReadNoSuchFile) {
            // ignore
        } catch let error as NSError where error.isCocoaError(.fileWriteFileExists) {
            // ignore
        }
    }
}

extension NSError {
    func isCocoaError(_ code: CocoaError.Code) -> Bool {
        self.domain == CocoaError.errorDomain && self.code == code.rawValue
    }
    func isPOSIXError(_ code: POSIXError.Code) -> Bool {
        self.domain == POSIXError.errorDomain && self.code == code.rawValue
    }
}

#if !canImport(Darwin)
extension URL {
    public enum DirectoryHint: Equatable { case isDirectory, notDirectory, inferFromPath }
    static func isDirFlag(_ path: some StringProtocol, _ hint: DirectoryHint) -> Bool {
        hint == .inferFromPath ? path.last == "/" : hint == .isDirectory
    }
    public init(filePath: String, directoryHint hint: DirectoryHint = .inferFromPath, relativeTo base: URL? = nil) {
        self = URL(fileURLWithPath: filePath, isDirectory: Self.isDirFlag(filePath, hint), relativeTo: base)
    }
    public func appending(component: some StringProtocol, directoryHint hint: DirectoryHint = .inferFromPath) -> URL {
        self.appendingPathComponent(String(component), isDirectory: Self.isDirFlag(component, hint))
    }
    public func appending<S: StringProtocol>(components: S..., directoryHint hint: DirectoryHint = .inferFromPath) -> URL {
        components.dropLast().reduce(self) { $0.appending(component: $1, directoryHint: .isDirectory) }
            .appending(component: components.last!, directoryHint: hint)
    }
    public static func currentDirectory() -> URL { .init(filePath: FileManager.default.currentDirectoryPath, directoryHint: .isDirectory) }
}
#endif
