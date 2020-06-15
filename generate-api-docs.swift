#!/usr/bin/env swift

import Foundation

let packages: [String: [String]] = [
    "vapor": ["Vapor", "XCTVapor"],
    "fluent-kit": ["FluentKit", "FluentSQL"]
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
    try shell("git", "clone", "https://github.com/vapor/\(package).git", "/root/api-docs/packages/\(package)")
}

func gitPullMaster(_ package: String) throws {
    try shell("git", "-C", "/root/api-docs/packages/\(package)", "checkout", "master")
    try shell("git", "-C", "/root/api-docs/packages/\(package)", "pull")
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
                  "/root/api-docs/swift-doc")
    } catch let error as ShellError {
        if error.terminationStatus == 128 {
            // repo already exists, get newest version
            try shell("git", "-C", "/root/api-docs/swift-doc/", "checkout", "master")
            try shell("git", "-C", "/root/api-docs/swift-doc", "pull")
        } else {
            throw error
        }
    }
}

func generateDocs(package: String, module: String) throws {
    do {
        try shell("rm", "-rf", "/var/www/api-docs/\(package)/master/\(module)")
        try shell("swift", "run", "--package-path", "/root/api-docs/swift-doc", "swift-doc", "generate", "/root/api-docs/packages/\(package)/Sources/\(module)", "--module-name", "\(module)", "--output", "/var/www/api-docs/\(package)/master/\(module)")
    } catch let error as ShellError {
        throw error
    }
}

// update swift doc
try updateSwiftDoc()
try shell("swift", "build", "--package-path", "/root/api-docs/swift-doc")

for (package, modules) in packages {
    try getNewestRepoVersion(package)
    for module in modules {
        print("Generating api-docs for package: \(package), module: \(module)")
        try generateDocs(package: package, module: module)
    }
}
