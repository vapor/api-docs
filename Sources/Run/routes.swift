import Vapor

func routes(_ r: Routes, _ c: Container) throws {
    r.get(.catchall) { req -> String in
        print(req)
        return "Hello"
    }

    r.post("hooks", "github") { req -> HTTPStatus in
        let options = try req.query.decode(GitHubHookOptions.self)
        let payload = try req.content.decode(GitHubHookPayload.self)

        if payload.action == "edited" || payload.action == "published" {
            for module in options.modulesArray {
                generateDocs(repo: payload.repository.name, tag: payload.release.tag_name, module: module)
            }
        }
        return .ok
    }
}

func generateDocs(repo: String, tag: String, module: String) {
    print("Generating \(repo).\(module)@\(tag)")
    let dir = DirectoryConfiguration.detect()
    let process = Process()
    process.environment = ProcessInfo.processInfo.environment
    process.launchPath = "/bin/sh"
    process.arguments = [
        "-c", "\(dir.workingDirectory + "generate.sh") \(repo) \(module) \(tag)"
    ]
    process.standardOutput = FileHandle.standardOutput
    process.standardError = FileHandle.standardError
    process.launch()
    process.waitUntilExit()
}

struct GitHubHookOptions: Codable {
    var modules: String

    var modulesArray: [String] {
        return self.modules.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
    }
}

struct GitHubHookPayload: Codable {
    struct Release: Codable {
        var tag_name: String
    }

    struct Repository: Codable {
        var name: String
    }

    var action: String
    var release: Release
    var repository: Repository
}
